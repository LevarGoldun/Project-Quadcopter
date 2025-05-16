% 20.03.2025 Praha
% MATLAB R2024b, PYTHON 3.12
% Synchronni komunikace
% Verze pro rizeni pomoci LQR, VERZE SILA A MOMENTY

% od 16.05 -> zmena poradi vymenu dat; 

%===================!!! Kontrola verze Simulink !!!========================
v = version;
if contains(v, 'R2024a')
    simulink_file_name = 'LQR_simulink_Sily_2024a'; %verze 2024a    
elseif contains(v, 'R2024b')
    simulink_file_name = 'LQR_simulink_Sily'; %verze 2024b (autor)
else
    disp('Save the file async_simulink_control_client.slx to your version')
end
clear v
open_system([simulink_file_name, '.slx']);
smfn = simulink_file_name;

%==========================================================================

% Vytvoreni TCP komunikace
tcpObj = tcpclient('localhost', 65432, 'ConnectTimeout', 5);

% Testove spojeni s Python
send = "Hello";
write(tcpObj, unicode2native(send, 'UTF-8'), 'uint8');
while true
    %pause(0.5);
    try
    if tcpObj.NumBytesAvailable > 0
        get = native2unicode(read(tcpObj), 'UTF-8');
        if get == "Ahoj"
            disp(['Python: ', get]);
            break % Pokud je vsechno ok, tak vystupujeme z cyklu
        end
    end
    %disp("Waiting...")
    catch exception
        disp(exception.message);
    end
end


%=============================NASTAVENI====================================
% Cteme krok simulace a celkovy cas simulace z Python
while true
    if tcpObj.NumBytesAvailable > 0
        get = read(tcpObj);
        timeData = jsondecode( native2unicode(get, 'UTF-8') );
        simtime = timeData.SimTime; % cas simulace
        timestep = timeData.TimeStep; % krok (.xml)
        disp(['Cas simulace: ', num2str(simtime), ' s'])
        disp(['Krok simulace modelu: ', num2str(timestep), ' s'])
        break
    end
end
% Pausa programu
pauseT = 0;

%---------------------Nastaveni Kalmanova filtru---------------------------
load('../LinSystemMatrix.mat')
Ac = LinSystem.Ac;
Bc = LinSystem.Bc;
Bmc = LinSystem.Bmc; % matice pro vstupy otacky^2 do KF
Cc = LinSystem.Cc;
Dc = LinSystem.Dc;


% Kovariance sumu procesu
Q = 1e-3;
% Kovariance sumu mereni
R = 1e-4;
% Sampling time
Ts = timestep; %[s]

l = 0.2051; %[m] polovicni delka kvadrokoptery (rameno od hmotneho bodu)
k_thrust = 2.3e-3; % koeficient umernosti pro generovani tahove sily
b_moment = 5.4e-6; % koeficient umernosti odporoveho momentu vrtule

% Pracovni bod pro linearni state-space (v Kalmanovem filtru)
M = 2;
m = 1;
g = 9.81;

Xs_p = [0;0;0; 0;0;0; 0;0; 0;0;0; 0;0;0; 0;0];
Us_p = [(M+m)*g; 0; 0; 0];
%--------------------------------------------------------------------------


%-------------------------Koeficienty LQR----------------------------------
run("LQR_koeficienty.m")
% pocatecni honoty integratoru pro integracni cleny v pp=[0;0;2]
xss=[0;0;2;0;0;0;0;0;0;0;0;0;0;0;0;0];
uss = Us_p;

init_int_ref = -ki_lqr\(kp_lqr*xss+uss); % pro vstup sily a momenty
set_param([smfn,'/Integrator_ref'],'InitialCondition', mat2str(init_int_ref));
%--------------------------------------------------------------------------

% Nastavujeme 'Fixed-step size' v Simulink a metodu reseni
set_param(gcs,'SolverType','Fixed-step','FixedStep',num2str(timestep))
% set_param(gcs,'Solver','ode4') % Runge-Kutta
% set_param(gcs,'Solver','ode1') % Euler

% Nastavujeme 'Stop Time' v Simulink a pocatecni cas v bloku
set_param(gcs,'StopTime', num2str(simtime))
set_param([smfn,'/time'],'Value', '0')

% !!! TOHLE JE KLICOVA VEC PRO POUZITI SIMULINK !!!
% start simulation and pause simulation, waiting for signal from python
% set_param(gcs,'SimulationCommand','start','SimulationCommand','pause');
% ---> premistena dovnitrz cyklu while()
pause(0.5)
%==========================================================================


%======================HLAVNI PROGRAM======================================
time=0;
try
    while true && time<simtime
        % tic

        % Get data from Python
        while true
            if tcpObj.NumBytesAvailable > 0
                get = read(tcpObj);
                json_str = native2unicode(get, 'UTF-8');

                if isValidJSON(json_str)
                    data = jsondecode(json_str);

                    time = data.SimulationTime;
                    DronPos = data.DronPos;
                    PendPos = data.PendPos;

                    DronRotM = transpose(reshape(data.DronRotM, 3, 3));
                    PendRotM = transpose(reshape(data.PendRotM, 3, 3));
                    
                    % Немного гемор с системами отсчета, но вкратце блок в
                    % симулинк требует систему NED, в mujoco другое,
                    % поэтому меняю знаки
                    imuAccel = [data.imuAccel(1), -data.imuAccel(2), -data.imuAccel(3)];
                    imuGyro = [data.imuGyro(1), -data.imuGyro(2), -data.imuGyro(3)];
                    imuMag = [data.imuMag(1), -data.imuMag(2), -data.imuMag(3)];
                    
                    % set parameter in the simulink model using the data from python
                    set_param([smfn,'/time'],'Value', num2str(time))
                    set_param([smfn,'/DronRotM'],'Value', mat2str(DronRotM))
                    set_param([smfn,'/PendRotM'],'Value', mat2str(PendRotM))
                    set_param([smfn,'/DronPos'],'Value', mat2str(DronPos))
                    set_param([smfn,'/PendPos'],'Value', mat2str(PendPos))

                    % nastaveni dat pro sensor fusion
                    % set_param([smfn,'/imuAccel'],'Value', mat2str(imuAccel))
                    % set_param([smfn,'/imuGyro'],'Value', mat2str(imuGyro))
                    % set_param([smfn,'/imuMag'],'Value', mat2str(imuMag))
                    
                    % run the simulink model for ONE STEP
                    if time == 0
                        set_param(gcs,'SimulationCommand','start', ...
                            'SimulationCommand','pause')
                    else
                        set_param(simulink_file_name, 'SimulationCommand','step');
                    end

                    break
                else
                    warning('Invalid JSON received: %s', json_str);
                end
            end
        end

        % Vystupni data z Simulink
        Rotor_RPS_square = out.Rotor_RPS_square(end,:);
        
        % Send data to Python
        data_to_send = struct('Rotor_RPS_square', Rotor_RPS_square);
        json_str_send = jsonencode(data_to_send);
        send = unicode2native(json_str_send, 'UTF-8');
        write(tcpObj, send, 'uint8');

        pause(pauseT)
        % toc
    end
catch exception
    disp(exception.message);
    % Uzavreni spojeni
    clear tcpObj;
end
disp("Konec zpracovani")
%======================KONEC HLAVNIHO PROGRAMU=============================

%%
% Smazani komunikace a zastaveni Simulink
clear tcpObj
set_param(gcs,'SimulationCommand','stop');

% Funkce pro kontrolu spravnosti JSON retezce
function isValid = isValidJSON(str)
    isValid = true;
    try
        jsondecode(str);
    catch
        isValid = false;
    end
end