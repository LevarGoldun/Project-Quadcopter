% 18.03.2025, Praha
% MATLAB R2024b, PYTHON 3.12
% v2 - asynchronni komunikace

% Matlab/Simulink je klient, Python je server (v nem bezi MuJoCo)
% V Python byla realizovana asynchronni komunikace, po prredani dat
% simulace mujoco pokracuje.

%===========!!! Kontrola verze Simulink !!!================================
v = version;
if contains(v, 'R2024a')
    simulink_file_name = 'async_simulink_control_client_2024a'; %verze 2024a    
elseif contains(v, 'R2024b')
    simulink_file_name = 'async_simulink_control_client'; %verze 2024b (autor)
else
    disp('Save the file async_simulink_control_client.slx to your version')
end
clear v
open_system([simulink_file_name, '.slx']);
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
% Cteme krok simulace MuJoCo z Python
while true
    if tcpObj.NumBytesAvailable > 0
        timestep = str2double( native2unicode(read(tcpObj), 'UTF-8') );
        timestep = 0.5;
        disp(['Krok simulace mujoco: ', num2str(timestep), ' s'])
        break
    end
end

% Nastavujeme 'Fixed-step size' v Simulink a metodu reseni
set_param(gcs,'SolverType','Fixed-step','FixedStep',num2str(timestep))
set_param(gcs,'Solver','ode4') % Runge-Kutta


% Posilame celkovy cas simulace do Python
simtime = 100; %[s]
write(tcpObj, unicode2native(num2str(simtime), 'UTF-8'), 'uint8');
disp(['Cas simulace: ', num2str(simtime), ' s'])

% Nastavujeme 'Stop Time' v Simulink a pocatecni cas v bloku
set_param(gcs,'StopTime', num2str(simtime))
set_param([simulink_file_name,'/time'],'Value', '0')

% !!! TOHLE JE KLICOVA VEC PRO POUZITI SIMULINK !!!
% start simulation and pause simulation, waiting for signal from python
set_param(gcs,'SimulationCommand','start','SimulationCommand','pause');
%--------------------------------------------------------------------------



%======================HLAVNI PROGRAM======================================
% Ziskava cas simulace z promenne data.time v Python (jako realny svet)
% a meni parametry vrtule kvadrokoptery (signal) kazde 2 sekundy. 
% Rizeni probiha v Simulink

i = 1;
while true
    % Проверка состояния симулин
    modelState = get_param(simulink_file_name, 'SimulationStatus');
    if strcmp(modelState, 'stopped') || strcmp(modelState, 'terminated')
        disp('Модель Simulink остановлена или закрыта. Прерывание цикла.');
        break;
    end

    moment = out.moment(end,:);
    RandomText = out.RandomText.Data(end, :);

    data_to_send = struct('MotorSignal', moment, 'RandomText', RandomText);
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
    
                % set parameter in the simulink model using the data from python
                set_param([simulink_file_name,'/time'],'Value', num2str(time))
                % run the simulink model for one step
                set_param(simulink_file_name, 'SimulationCommand','step');
            else
                % warning('Invalid JSON received: %s', json_str);
            end
        end


    % disp(out)

    disp(['Симулинк завершен! Цикл ', num2str(i)])
    i=i+1;
    disp("------")
    pause(0.25)
end

disp("Конец обработки")

set_param([simulink_file_name,'/time'],'Value', '0')
set_param(gcs,'SimulationCommand','stop');


% Функция для контроля правильности json строки
function isValid = isValidJSON(str)
    isValid = true;
    try
        jsondecode(str);
    catch
        isValid = false;
    end
end