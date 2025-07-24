% 24.03.2025 Praha
% MATLAB R2024b, PYTHON 3.12
% Synchronni komunikace
% Verze pro rizeni Pole Placement, VERZE SILA A MOMENTY

% od 16.05 -> zmena poradi vymenu dat
% od 12.07 -> drobna zmena kodu (asi finalni, pisu DP)

%===================!!! Kontrola verze Simulink !!!========================
v = version;
if contains(v, 'R2024a')
    simulink_file_name = 'PP_simulink_Sily_2024a'; %verze 2024a    
elseif contains(v, 'R2024b')
    simulink_file_name = 'PP_simulink_Sily'; %verze 2024b (autor)
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

%---------------------Nutne hodnoty parametru------------------------------
run('../parametry_soustavy.m');
load('../LinSystemMatrix.mat');
Ac = LinSystem.Ac;
Bc = LinSystem.Bc; % matice pro vstypy tahova sila/momenty
% Bmc = LinSystem.Bmc; % matice pro vstupy otacky^2 do KF 
Cc = LinSystem.Cc;
Dc = LinSystem.Dc;
%--------------------------------------------------------------------------

%---------------------Koeficienty stavoveho regulatoru---------------------
% nutne zvolit sadu polu
index = 'smo'; % plynula
% index = 'agr'; % agresivni
disp("Zvolena sada polu: "+index)

run("PP_koeficienty.m")
% pocatecni honoty integratoru pro integracni cleny v pp=[0;0;2]
xss=Xs_p;
uss = Us_p;
% ussm = Ums_p;

init_int_ref = -Ki\(Kp*xss+uss); % pro vstup sily a momenty
set_param([smfn,'/Integrator_ref'],'InitialCondition', mat2str(init_int_ref));
%--------------------------------------------------------------------------

% Nastavujeme 'Fixed-step size' v Simulink a metodu reseni
set_param(gcs,'SolverType','Fixed-step','FixedStep',num2str(timestep))
set_param(gcs,'Solver','ode4') % Runge-Kutta
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
tic
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
                    
                    % set parameter in the simulink model using the data from python
                    set_param([smfn,'/time'],'Value', num2str(time))
                    set_param([smfn,'/DronRotM'],'Value', mat2str(DronRotM))
                    set_param([smfn,'/PendRotM'],'Value', mat2str(PendRotM))
                    set_param([smfn,'/DronPos'],'Value', mat2str(DronPos))
                    % set_param([smfn,'/PendPos'],'Value', mat2str(PendPos))
                    
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
        Rotor_AngVel_square = out.Rotor_AngVel_square(:,end);

        % Send data to Python
        data_to_send = struct('Rotor_AngVel_square', Rotor_AngVel_square);
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
disp("Cas behu programu: "+num2str(toc)+" s")

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