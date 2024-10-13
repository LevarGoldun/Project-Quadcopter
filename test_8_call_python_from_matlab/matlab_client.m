% Создание TCP-соединения с Python
tcpClient = tcpclient('localhost', 65432, 'ConnectTimeout', 10);

while true
    % Чтение данных, отправленных с MuJoCo
    rawData = read(tcpClient);
    
    % Преобразование строки в числовой массив
    data = native2unicode(rawData, "UTF-8");

    % Вывод данных
    disp("Данные из MuJoCo:");
    disp(data)
    
    % Отправка подтверждения в Python
    % confirmationMessage = 'Data received';
    % writeline(tcpClient, confirmationMessage);

    % Задержка
    pause(1);
end

% Закрытие соединения
clear tcpClient;
