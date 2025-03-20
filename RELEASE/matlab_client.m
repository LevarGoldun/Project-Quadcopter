% 18.03.2025, Praha
% MATLAB R2024b, PYTHON 3.12
% Asynchronni komunikace

% Perioda dotazu na server (lze korigovat)
PollingPeriod = 0.025;

% Nastaveni Kalmanova filtru
load('LinSystemMatrix.mat')
Ac = LinSystem.Ac;
Bc = LinSystem.Bc;
Cc = LinSystem.Cc;
Dc = LinSystem.Dc;

% Kovariance sumu procesu
Q = 1e-3;
% Kovariance sumu mereni
R = 1e-4;
% Sampling time
Ts = PollingPeriod; %[s]

l = 0.2051; %[m] polovicni delka kvadrokoptery (rameno od hmotneho bodu)
k_thrust = 2.3e-3; % koeficient umernosti pro generovani tahove sily
b_moment = 5.4e-6; % koeficient umernosti odporoveho momentu vrtule



% Matlab/Simulink je klient, Python je server (v nem bezi MuJoCo)
% V Python byla realizovana asynchronni komunikace, po prredani dat
% simulace mujoco pokracuje.

%===========!!! Kontrola verze Simulink !!!================================
v = version;
if contains(v, 'R2024a')
    simulink_file_name = 'simulink_control_client_2024a'; %verze 2024a    
elseif contains(v, 'R2024b')
    simulink_file_name = 'simulink_control_client'; %verze 2024b (autor)
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


%-------------------------Nastaveni simulace-------------------------------
% Cteme krok simulace a celkovy cas simulace z Python
while true
    if tcpObj.NumBytesAvailable > 0
        get = read(tcpObj);
        timeData = jsondecode( native2unicode(get, 'UTF-8') );
        simtime = timeData.SimTime;
        timestep = timeData.TimeStep;
        disp(['Cas simulace: ', num2str(simtime), ' s'])
        disp(['Krok simulace modelu: ', num2str(timestep), ' s'])
        break
    end
end

% Nastavujeme 'Fixed-step size' v Simulink a metodu reseni
set_param(gcs,'SolverType','Fixed-step','FixedStep',num2str(PollingPeriod))
set_param(gcs,'Solver','ode4') % Runge-Kutta


% Nastavujeme 'Stop Time' v Simulink a pocatecni cas v bloku
set_param(gcs,'StopTime', num2str(simtime))
set_param([smfn,'/time'],'Value', '0')

% !!! TOHLE JE KLICOVA VEC PRO POUZITI SIMULINK !!!
% start simulation and pause simulation, waiting for signal from python
set_param(gcs,'SimulationCommand','start','SimulationCommand','pause');
%--------------------------------------------------------------------------



%======================HLAVNI PROGRAM======================================
% Ziskava cas simulace z promenne data.time v Python (jako realny svet)
% a meni parametry vrtule kvadrokoptery (signal) kazde 2 sekundy. 
% Rizeni probiha v Simulink

i = 1;
matrix_pendpos = [];
matrix_time = [];
while true
    tic
    % Проверка состояния симулин
    modelState = get_param(smfn, 'SimulationStatus');
    if strcmp(modelState, 'stopped') || strcmp(modelState, 'terminated')
        disp('Модель Simulink остановлена или закрыта. Прерывание цикла.');
        break;
    end
    % Vystupni data z Simulink
    Rotor_RPS_square = out.Rotor_RPS_square(end,:);

    data_to_send = struct('Rotor_RPS_square', Rotor_RPS_square);

    json_str_send = jsonencode(data_to_send);
    send = unicode2native(json_str_send, 'UTF-8');
    write(tcpObj, send, 'uint8');

     % TCP receiving
        if tcpObj.NumBytesAvailable > 0
            get = read(tcpObj);
            json_str = native2unicode(get, 'UTF-8');
            % disp('Received JSON string:');
            % disp(json_str);

            if isValidJSON(json_str)
                data = jsondecode(json_str);
    
                time = data.SimulationTime;
                DronPos = data.DronPos;
                PendPos = data.PendPos;

                DronRotM = reshape(data.DronRotM, 3,3);
                PendRotM = reshape(data.PendRotM, 3,3);


                % matrix_pendpos = [matrix_pendpos, PendPos];
                % matrix_time = [matrix_time, time];

    
                % set parameter in the simulink model using the data from python
                set_param([smfn,'/time'],'Value', num2str(time))
                set_param([smfn,'/DronRotM'],'Value', mat2str(DronRotM))
                set_param([smfn,'/PendRotM'],'Value', mat2str(PendRotM))
                
                set_param([smfn,'/DronPos'],'Value', mat2str(DronPos))
                set_param([smfn,'/PendPos'],'Value', mat2str(PendPos))

                % run the simulink model for one step
                set_param(simulink_file_name, 'SimulationCommand','step');
            else
                % warning('Invalid JSON received: %s', json_str);
            end
        end


    % disp(out)

    % disp(['Cyklus ', num2str(i)])
    i=i+1;
    
    pause(PollingPeriod) % tohle ridi rychlost Matlab/Simulink
    % jak casto delame dotazy na server
    
    toc
    % disp("------")
end

disp("Konec zpracovani")

set_param(gcs,'SimulationCommand','stop');
set_param([smfn,'/time'],'Value', '0');
set_param([smfn,'/DronRotM'],'Value', mat2str([1 0 0;0 1 0; 0 0 1]));
set_param([smfn,'/PendPos'],'Value', mat2str([0;0;0]))

% Функция для контроля правильности json строки
function isValid = isValidJSON(str)
    isValid = true;
    try
        jsondecode(str);
    catch
        isValid = false;
    end
end