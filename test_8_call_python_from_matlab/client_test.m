% Параметры подключения
host = 'localhost';  % IP-адрес сервера (Python)
port = 65432;        % Порт сервера
% Создаем TCP-клиент
tcpObj = tcpclient(host, port);

% %% Вроде передача только строк, но разные языки
% % Преобразуем строку в байты с кодировкой UTF-8
% data = unicode2native("Данные от Матлаб", 'UTF-8');
% % Отправляем байты на Python-сервер
% write(tcpObj, data, 'uint8');
% 
% 
% % Получение ответа от сервера
% pause(1);  % Небольшая пауза для синхронизации
% 
% response = read(tcpObj);
% disp(native2unicode(response, "UTF-8"))
% 
% % Закрытие соединения
% %clear tcpObj;
% 
% %% Попробуем более сложную структуру
% data_to_send = struct('name', 'MATLAB', 'values', [1, 2, 3, 4], 'flag', true);
% % Преобразуем структуру в JSON-строку
% json_str = jsonencode(data_to_send);
% % Преобразуем строку в байты и отправляем на сервер
% write(tcpObj, unicode2native(json_str, 'UTF-8'), 'uint8');
% 
% % Получение ответа от сервера
% pause(1);  % Небольшая пауза для синхронизации
% response = read(tcpObj);
% response_str = native2unicode(response, 'UTF-8');
% 
% % Декодируем JSON-ответ в MATLAB структуру
% response_data = jsondecode(response_str);
% disp(response_data);

%% Попробуем передачу с времеными задержками, чтобы не наваливалось куча данных
try
    while true
        % Чтение данных каждые 1 секунду
        pause(1);  % Задержка в 1 секунду
        
        % Чтение данных из сокета
        if tcpObj.NumBytesAvailable > 0
            response = read(tcpObj);
            disp(['Получено: ', native2unicode(response, 'UTF-8')]);
            
            % Отправляем подтверждение серверу
            write(tcpObj, unicode2native('OK', 'UTF-8'), 'uint8');
        end
    end

catch exception
    disp(exception.message);
end