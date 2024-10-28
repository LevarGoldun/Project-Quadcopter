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

% Hlavni program:
% Ziskava cas simulace z promenne data.time v Python a meni parametry
% vrtule kvadrokoptery (moment) kazde 2 sekundy.

try
while true
    % Cteni dat z MuJoCo kazdou ? s
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

    % Kazde 2 sekundy simulace menime velikost momentu na motorech kvadrokoptery
    if floor(mod(data.simulationTime, 2))
        moment = 10;
    else
        moment = 5;
    end
    
    data_to_send = struct('MotorSignal', moment, 'RandomText', 'Wanna know how i got these scars?');
    json_str_send = jsonencode(data_to_send);
    send = unicode2native(json_str_send, 'UTF-8');
    write(tcpObj, send, 'uint8');

end
catch exception
    disp(exception.message);
    % Uzavreni spojeni
    clear tcpClient;
end

clear response_text % pro kontrolu...
