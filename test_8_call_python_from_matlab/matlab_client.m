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
    % Cteni dat z MuJoCo kazdou 1 s
    pause(0.5);
    if tcpObj.NumBytesAvailable > 0
        response = read(tcpObj);
        response_text = native2unicode(response, 'UTF-8');
        disp(['Python: ', response_text]);

        % Posilame potvrzeni prijeti serveru
        write(tcpObj, unicode2native('OK', 'UTF-8'), 'uint8');
    end
    % Kazde 2 sekundy simulace menime velikost momentu na motorech kvadrokoptery
    if floor(mod(str2double(response_text), 2))
        write(tcpObj, unicode2native('10', 'UTF-8'), 'uint8');
    else
        write(tcpObj, unicode2native('5', 'UTF-8'), 'uint8');
    end

end
catch exception
    disp(exception.message);
end


% Uzavreni spojeni
clear tcpClient;
