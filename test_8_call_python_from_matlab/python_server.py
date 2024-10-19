import time
import mujoco as mj
import mujoco.viewer

import socket  # TCP communication
import select  # Are there any sockets

# Server settings
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind(('localhost', 65432))
server_socket.listen(1)
print("Waiting for connection with MATLAB...")
client_socket, addr = server_socket.accept()
print(f"Connected to {addr}")
client_socket.setblocking(False)  # Set non-blocking mode

# Test connection with Matlab
while True:
    # Check if a message has arrived from the client
    ready_to_read, _, _ = select.select([client_socket], [], [], 0)
    if ready_to_read:
        get = client_socket.recv(1024).decode('utf-8')  # Read
        if get == 'Hello':
            print('Matlab: ' + get)
            send = 'Ahoj'
            client_socket.sendall(send.encode('utf-8'))  # Answer
            time.sleep(2)
            break

# MuJoCo settings
xml_path = 'model_quadcopter_v1.xml'
model = mj.MjModel.from_xml_path(xml_path)  # MuJoCo model
data = mj.MjData(model)  # MuJoCo data

# Initialization
acknowledged = True
last_time = time.time()
# Main program
with mujoco.viewer.launch_passive(model, data) as viewer:
    # Close the viewer automatically after ??? wall-seconds.
    start = time.time()

    while viewer.is_running() and time.time() - start < 30:
        step_start = time.time()

        # mj_step can be replaced with code that also evaluates
        # a policy and applies a control signal before stepping the physics.
        mujoco.mj_step(model, data)

        with viewer.lock():
            # !!! This part is now implemented in Matlab and is passed through sockets !!!
            # viewer.opt.flags[mujoco.mjtVisFlag.mjVIS_CONTACTPOINT] = int(data.time % 2)
            # if int(data.time % 2):
            #     data.ctrl = [10, 10, 10, 10]
            # else:
            #     data.ctrl = [5, 5, 5, 5]

            # Send data to MATLAB
            if step_start - last_time > 0.1 and acknowledged:
                last_time = step_start
                data_to_send = str(data.time)
                client_socket.sendall(data_to_send.encode('utf-8'))
                acknowledged = False  # Waiting for confirmation after sending

        # Check if a message has arrived from the client
        ready_to_read, _, _ = select.select([client_socket], [], [], 0)
        if ready_to_read:
            get = client_socket.recv(1024).decode('utf-8')  # Read
            if get == 'OK':  # expected response from Matlab
                acknowledged = True

            else:
                number = int(get)
                print(number)
                data.ctrl = [number, number, number, number]

        # Pick up changes to the physics state, apply perturbations, update options from GUI.
        viewer.sync()

        # Rudimentary time keeping, will drift relative to wall clock.
        time_until_next_step = model.opt.timestep - (time.time() - step_start)
        if time_until_next_step > 0:
            time.sleep(time_until_next_step)

server_socket.close()
print("End")
