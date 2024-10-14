import socket
import time
import select

# Vytvoreni soketu
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind(('localhost', 65432))
server_socket.listen(1)

print("Cekame spojeni s MATLAB...")
client_socket, addr = server_socket.accept()
print(f"Pripojeno k {addr}")
# Установка неблокирующего режима
client_socket.setblocking(False)

data_counter = 0
last_time = time.time()
acknowledged = True  # Флаг подтверждения, что данные можно отправлять

while True:
    # Время начала шага цикла
    step_start = time.time()

    if step_start - last_time > 0.1 and acknowledged:
        last_time = step_start
        # Отправляем данные клиенту
        data_to_send = f"Данные {data_counter}"
        client_socket.sendall(data_to_send.encode('utf-8'))
        acknowledged = False  # Ждем подтверждения после отправки
        # Инкремент счетчика данных
        data_counter += 1

    # Проверяем, пришло ли подтверждение от клиента
    print("Проверяем если ли что-то от клиента")
    ready_to_read, _, _ = select.select([client_socket], [], [], 0)
    print("Поебень выполнилась")
    if ready_to_read:
        print("if прошел")
        acknowledgment = client_socket.recv(1024).decode('utf-8')
        if acknowledgment == 'OK':
            print(f"Подтверждение получено от клиента")
            acknowledged = True  # Устанавливаем флаг для отправки новых данных

    # if acknowledgment == 'OK':
    #     print(f"Подтверждение получено от клиента")
    # else:
    #     print("Ошибка в подтверждении")
    #print("---Текст в цикле, но вне отправки данных---")

server_socket.close()
print("End")
