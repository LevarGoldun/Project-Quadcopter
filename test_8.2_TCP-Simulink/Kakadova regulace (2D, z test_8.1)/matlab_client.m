% 01.11.2024, Praha
% MATLAB R2024b, PYTHON 3.12

% Matlab/Simulink je klient, Python je server (v nem bezi MuJoCo)

%===========!!! Kontrola verze Simulink !!!================================
v = version;
if contains(v, 'R2024a')
    simulink_file_name = 'simulink_control_client_2024a'; %verze 2024a    
elseif contains(v, 'R2024b')
    simulink_file_name = 'simulink_control_client'; %verze 2024b (autor)
else
    disp('Save the file simulink_control_client.slx to your version')
end
clear v
%==========================================================================

open_system([simulink_file_name, '.slx']);
pause(1)

% Vytvoreni TCP komunikace
tcpObj = tcpclient('localhost', 65432, 'ConnectTimeout', 10);

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
% Cteme krok simulace z Python
while true
    if tcpObj.NumBytesAvailable > 0
        timestep = str2double( native2unicode(read(tcpObj), 'UTF-8') );
        disp(['Krok simulace: ', num2str(timestep), ' s'])
        break
    end
end

% Nastavujeme 'Fixed-step size' v Simulink a resic
set_param(gcs,'SolverType','Fixed-step','FixedStep',num2str(timestep))
set_param(gcs,'Solver','ode4') % Runge-Kutta

% Posilame celkovy cas simulace do Python
simtime = 50; %[s]
write(tcpObj, unicode2native(num2str(simtime), 'UTF-8'), 'uint8');
disp(['Cas simulace: ', num2str(simtime), ' s'])

% Nstavujeme 'Stop Time' v Simulink
set_param(gcs,'StopTime', num2str(simtime))

% !!! TOHLE JE KLICOVA VEC PRO POUZITI SIMULINK !!!
% start simulation and pause simulation, waiting for signal from python
set_param(gcs,'SimulationCommand','start','SimulationCommand','pause');
%--------------------------------------------------------------------------



%======================HLAVNI PROGRAM======================================
% Kaskadova regulace kvadrokoptery, pohyb v 2D prostoru
% Rizeni probiha v Simulink

tic
try
for i=0:timestep:simtime
    % Tato pauze reguluje rychlost simulace
    % pause(60/size(0:timestep:simtime, 2));
    
    % TCP sending
    F1 = out.F1.Data(end,:);
    F2 = out.F2.Data(end,:);

    data_to_send = struct('F1', F1, 'F2', F2);
    json_str_send = jsonencode(data_to_send);
    send = unicode2native(json_str_send, 'UTF-8');
    write(tcpObj, send, 'uint8');
    
    % TCP receiving
    while true
        if tcpObj.NumBytesAvailable > 0
            get = read(tcpObj);
            json_str = native2unicode(get, 'UTF-8');
            % Transformace JSON string v strukturu Matlab
            data = jsondecode(json_str);
            
            % disp('Python:')
            % disp(data);
            break
        end
    end
    
    time = data.SimulationTime;
    x_actual = data.Position(1);
    y_actual = data.Position(2);
    z_actual = data.Position(3);
    quaternions = transpose(data.Quaternions);

    % set parameter in the simulink model using the data from python
    set_param([simulink_file_name,'/time'],'Value', num2str(time))
    set_param([simulink_file_name,'/x_actual'],'Value', num2str(x_actual))
    set_param([simulink_file_name,'/y_actual'],'Value', num2str(y_actual))
    set_param([simulink_file_name,'/z_actual'],'Value', num2str(z_actual))
    set_param([simulink_file_name,'/quaternions'],'Value', ['[',num2str(quaternions),']'])
    
    % run the simulink model for one step
    set_param(gcs, 'SimulationCommand','step');
end
catch exception
    disp(exception.message);
    % Uzavreni spojeni
    clear tcpClient;
end

realtime = toc;
disp("Konec")
disp("Celkovy cas programu "+num2str(realtime)+" s")

set_param([simulink_file_name,'/time'],'Value', '0')
set_param([simulink_file_name,'/x_actual'],'Value', '0')
set_param([simulink_file_name,'/y_actual'],'Value', '0')
set_param([simulink_file_name,'/z_actual'],'Value', '0')
set_param([simulink_file_name,'/quaternions'],'Value', '[1 0 0 0]')

clear response_text % pro kontrolu...
set_param(gcs,'SimulationCommand','stop');