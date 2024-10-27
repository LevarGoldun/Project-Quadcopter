% Vytvoreni TCP komunikace
tcpObj = tcpclient('localhost', 65432, 'ConnectTimeout', 10);

% Testove spojeni s Python
send = "Hello";
write(tcpObj, unicode2native(send, 'UTF-8'), 'uint8');
while true
    pause(1);
    try
    if tcpObj.NumBytesAvailable > 0
        get = native2unicode(read(tcpObj), 'UTF-8');
        if get == "Ahoj"
            disp(['Python: ', get]);
            break % Pokud je vsechno ok, tak vystupujeme z cyklu
        end
    end
    disp("Waiting...")
    catch exception
        disp(exception.message);
    end
end
%==============NEJAKA POCATECNI NASTAVENI==================================
% Cekame na dt z Python (jeste nevim k cemu budu potrebovat)
while true
    pause(1)
    try
    if tcpObj.NumBytesAvailable > 0
        get = native2unicode(read(tcpObj), 'UTF-8');
        dt = str2double(get);
        disp(['Perioda modelu dt=', num2str(dt), ' s']);
        break
    end
    disp("Waiting dt...")
    catch exception
        disp(exception.message);
    end
end
% Matice pro ukladani dat z MuJoCo
m_positions = [];
m_times = [];
m_angles = [];
m_accel = [];
m_speed = [];
m_angspeed = [];
m_force = [];
m_torque = [];
m_z_distance = [];
m_pid_out = [];

% Inicializace pid regulatoru, vlastni trida
PID_F_cmd = my_function_pid(dt, 8.92390432404577, 2.25471500348612, 8.67284220431323, 20, 0);
PID_phi_desired = my_function_pid(dt, -0.00323096272986417, -1.0967929328284e-05, -0.0313597401851494, pi/2, -pi/2);
PID_angle_cmd = my_function_pid(dt, 0.122982000274937, 0.00445840861689157, 0.833002920844437, 5, -5);

% ПОКА ЕСТЬ МЫСЛЬ...А С КАКОЙ dt ПРОВОДИТЬ РАСЧЕТ? МАТЛАБ И ПАЙТОН 
% РАБОТАЮТ АСИНХРОННО... -->использовать вообще другое dt и компенировать
% его с помощью tic, toc !!! Разобраться !!!

%======================HLAVNI PROGRAM======================================
try
while true
    %-----------------Cteni dat z MuJoCo kazdou ? s------------------------
    pause(0.5);
    while true
        if tcpObj.NumBytesAvailable > 0
            get = read(tcpObj);
            json_str = native2unicode(get, 'UTF-8');
            % Transformace JSON string v strukturu Matlab
            data = jsondecode(json_str);
            
            disp('Python:')
            disp(data);
    
            % Posilame potvrzeni prijeti serveru
            write(tcpObj, unicode2native(jsonencode(struct('command', 'OK')), 'UTF-8'), 'uint8');
            break
        end
    end
    
    %----------------------Ridici cast-------------------------------------
    % "Merena" data ze simulace MuJoCo
    position = data.position;
    x_actual = position(1);
    y_actual = position(2);
    z_actual = position(3);
    
    sim_time = data.time; % Cas v simulaci MuJoCo

    % Menime pozadovanou polohu kvadrokoptery
    if sim_time < 10
        zref = 8;
        xref = 0;
    elseif sim_time < 20
        zref = 15;
        xref = 10;
    elseif sim_time < 25
        zref = 8;
        xref = 10;
    elseif sim_time < 30
        zref = 10;
        xref = -5;
    elseif sim_time < 40
        zref = 12;
        xref = -5;
    end

    % Kaskadova smycka
    F_cmd = PID_F_cmd.control(z_ref, z_actual);
    phi_desired = -1*PID_phi_desired.control(x_ref, x_actual);
    [roll, pitch] = roll_pitch_calculation(data.quaternions);
    angle_cmd = PID_angle_cmd.control(phi_desired, pitch*pi/180);
    % Sily na motorech kvadrokoptery (posilame do Python)
    F1 = F_cmd + angle_cmd;
    F2 = F_cmd - angle_cmd;   
    %------------------Konec Ridici cast-----------------------------------

    %------------------Odesilani dat Python--------------------------------
    data_to_send = struct('F1', F1, 'F2', F2);
    json_str_send = jsonencode(data_to_send);
    send = unicode2native(json_str_send, 'UTF-8');
    write(tcpObj, send, 'uint8');

    %--------------------Ukladani dat--------------------------------------
    m_time = [m_time, sim_time];
    m_positions = [m_positions; position];
    m_angles = [m_angles; [roll, pitch]];
    m_pid_out = [m_pid_out; [F_cmd, phi_desired, angle_cmd]];
end
catch exception
    disp(exception.message);
    % Uzavreni spojeni
    clear tcpClient;
end
%=====================KONEC HLAVNI PROGRAM=================================

% Vizualizace vysledku