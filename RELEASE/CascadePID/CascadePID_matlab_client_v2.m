% 12.05.2025 Praha
% MATLAB R2024b, PYTHON 3.12
% Synchronni komunikace
% Verze pro Kaskadovou regulaci. Neni zpetna vazba pro zavazi !!!

% 06.07.2025 -> verze 2 s trochu upravenym kodem
% 26.07.2025 -> nahrazeni set_param([smfn,'/time'],'Value', num2str(time))
% a dalsich prikazu primym ctenim probennych z Workspace
% -> rychlejsi simulace

%===================!!! Kontrola verze Simulink !!!========================
v = version;
if contains(v, 'R2024a')
    simulink_file_name = 'CascadePID_sim_v2_2024a'; %verze 2024a    
elseif contains(v, 'R2024b')
    simulink_file_name = 'CascadePID_sim_v2'; %verze 2024b (autor)
else
    disp('Save the file async_simulink_control_client.slx to your version')
end
clear v
disp("Opening Simulink")
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
        timestep = timeData.TimeStep; % krok (v souboru .xml)
        disp(['Cas simulace: ', num2str(simtime), ' s'])
        disp(['Krok simulace modelu: ', num2str(timestep), ' s'])
        break
    end
end
% Pausa programu
pauseT = 0;

%---------------------Nutne hodnoty parametru------------------------------
run('../parametry_soustavy.m');
%--------------------------------------------------------------------------

% Nastavujeme 'Fixed-step size' v Simulink a metodu reseni
set_param(gcs,'SolverType','Fixed-step','FixedStep',num2str(timestep))
% set_param(gcs,'Solver','ode4') % Runge-Kutta
set_param(gcs,'Solver','ode1') % Euler

% Nastavujeme 'Stop Time' v Simulink a pocatecni cas v bloku
set_param(gcs,'StopTime', num2str(simtime))
% set_param([smfn,'/time'],'Value', '0')
time=0;

% !!! TOHLE JE KLICOVA VEC PRO POUZITI SIMULINK !!!
% start simulation and pause simulation, waiting for signal from python
% set_param(gcs,'SimulationCommand','start','SimulationCommand','pause');
% ---> premistena dovnitrz cyklu while()
pause(0.5)
%==========================================================================


%======================HLAVNI PROGRAM======================================
tic
try
    while true && time<simtime
        % tic
        % Kontrola stavu Simulink
        % modelState = get_param(smfn, 'SimulationStatus');
        % if strcmp(modelState, 'stopped') || strcmp(modelState, 'terminated')
        %     disp('Simulink model is stopped or closed. Cycle interrupted.');
        %     break;
        % end

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
                    % set_param([smfn,'/time'],'Value', num2str(time))
                    % set_param([smfn,'/DronRotM'],'Value', mat2str(DronRotM))
                    % set_param([smfn,'/PendRotM'],'Value', mat2str(PendRotM))
                    % set_param([smfn,'/DronPos'],'Value', mat2str(DronPos))
                    % set_param([smfn,'/PendPos'],'Value', mat2str(PendPos))
                    % -> uz nepotrebuju
                    
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
        Rotor_AngVel_square = out.Rotor_AngVel_square(end,:);
        dron_angles = rad2deg(out.dron_angles.Data(end, :));
        pend_angles = rad2deg(out.pend_angles.data(end, :));
        ref_xyz = out.ref.Data(:, end)';
        
        % Send data to Python
        data_to_send = struct('Rotor_AngVel_square', Rotor_AngVel_square, ...
            'dron_angles', dron_angles, ...
            'pend_angles', pend_angles,...
            'ref_xyz', ref_xyz);
        
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