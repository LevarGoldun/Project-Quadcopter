% Создание TCP-соединения с Python
tcpClient = tcpclient('localhost', 65432, 'ConnectTimeout', 10);

while true
    % Чтение данных, отправленных с MuJoCo
    rawData = read(tcpClient,1, "char");
    
    % Преобразование строки в числовой массив
    data = str2double(strsplit(char(rawData), ','));

    % Вывод данных
    disp("Данные из MuJoCo:");
    disp(data)
    
    % Отправка подтверждения в Python
    % confirmationMessage = 'Data received';
    % writeline(tcpClient, confirmationMessage);

    % Задержка
    pause(0.01);
end

% Закрытие соединения
clear tcpClient
