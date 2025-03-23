% 20.03.2025 Praha
% MATLAB R2024b, PYTHON 3.12
% Synchronni komunikace

%===================!!! Kontrola verze Simulink !!!========================
v = version;
if contains(v, 'R2024a')
    simulink_file_name = 'LQR_simulink_control_client_2024a'; %verze 2024a    
elseif contains(v, 'R2024b')
    simulink_file_name = 'LQR_simulink_control_client'; %verze 2024b (autor)
else
    disp('Save the file async_simulink_control_client.slx to your version')
end
% if contains(v, 'R2024a')
%     simulink_file_name = 'LQR_simulink_control_client_2_2024a'; %verze 2024a    
% elseif contains(v, 'R2024b')
%     simulink_file_name = 'LQR_simulink_control_client_2'; %verze 2024b (autor)
% else
%     disp('Save the file async_simulink_control_client.slx to your version')
% end
clear v
open_system([simulink_file_name, '.slx']);
smfn = simulink_file_name;

% Smazani info ze scopu - zpomaluji opakovanou simulaci
% scopesClear(smfn)
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
Cc = LinSystem.Cc;
Dc = LinSystem.Dc;
% resp. pokud vstupy do KF otacky^2
Bmc = LinSystem.Bmc;

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
% pracovni bod pro vstupy ve tvaru otacek^2 rotoru - jmenovite otacky^2 
% pro rovnovaznou polohu
ms2 = (M+m)*g/(4*k_thrust); %[RPS^2]
Ums_p = [ms2; ms2; ms2; ms2];
%--------------------------------------------------------------------------


%-------------------------Koeficienty LQR----------------------------------
run("LQR_koeficienty.m")
% pocatecni honoty integratoru pro integracni cleny v pp=[0;0;2]
xss=[0;0;2;0;0;0;0;0;0;0;0;0;0;0;0;0];
uss = Us_p;
ussm = Ums_p;

% init_int_ref = -ki_lqr\(kp_lqr*xss+uss); % pro vstup sily a momenty
% set_param([smfn,'/Integrator_ref'],'InitialCondition', mat2str(init_int_ref));

init_int_ref_m = -kimot_lqr\(kpmot_lqr*xss+ussm); % pro vstup otacky^2
set_param([smfn,'/Integrator_ref_m'],'InitialCondition', mat2str(init_int_ref_m));
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
set_param(gcs,'SimulationCommand','start','SimulationCommand','pause');
%==========================================================================


%======================HLAVNI PROGRAM======================================
i = 1;
matrix_pendpos = [];
matrix_time = [];
time=0;
try
    while true && time<simtime
        % tic
        % Kontrola stavu Simulink
        modelState = get_param(smfn, 'SimulationStatus');
        if strcmp(modelState, 'stopped') || strcmp(modelState, 'terminated')
            disp('Simulink model is stopped or closed. Cycle interrupted.');
            break;
        end

        % Vystupni data z Simulink
        Rotor_RPS_square = out.Rotor_RPS_square(end,:);

        data_to_send = struct('Rotor_RPS_square', Rotor_RPS_square);

        json_str_send = jsonencode(data_to_send);
        send = unicode2native(json_str_send, 'UTF-8');
        write(tcpObj, send, 'uint8');

        % TCP receiving
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
                    
                    % set parameter in the simulink model using the data from python
                    set_param([smfn,'/time'],'Value', num2str(time))
                    set_param([smfn,'/DronRotM'],'Value', mat2str(DronRotM))
                    set_param([smfn,'/PendRotM'],'Value', mat2str(PendRotM))
                    set_param([smfn,'/DronPos'],'Value', mat2str(DronPos))
                    set_param([smfn,'/PendPos'],'Value', mat2str(PendPos))
                    
                    % run the simulink model for one step
                    set_param(simulink_file_name, 'SimulationCommand','step');
                    break
                else
                    warning('Invalid JSON received: %s', json_str);
                end
            end
        end

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
% Smazani a nastaveni vychozich hodnot v Simulink
clear tcpObj
set_param(gcs,'SimulationCommand','stop');
set_param([smfn,'/time'],'Value', '0');
set_param([smfn,'/DronRotM'],'Value', mat2str([1 0 0;0 1 0; 0 0 1]));
set_param([smfn,'/DronPos'],'Value', mat2str([0;0;2]));

set_param([smfn,'/PendPos'],'Value', mat2str([0;0;1]));
set_param([smfn,'/PendRotM'],'Value', mat2str([1 0 0;0 1 0; 0 0 1]));


% Funkce pro kontrolu spravnosti JSON retezce
function isValid = isValidJSON(str)
    isValid = true;
    try
        jsondecode(str);
    catch
        isValid = false;
    end
end
% Функция для закрытия о очистки scope
function scopesClear(smfn)
    scopes = find_system(smfn, 'BlockType', 'Scope');
    for i = 1:length(scopes)
        % Закрытие окна Scope
        set_param(scopes{i}, 'Open', 'off');
        % Очистка данных в Scope
    end
end