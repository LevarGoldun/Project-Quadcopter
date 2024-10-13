import time
import mujoco as mj
import mujoco.viewer

import socket  # ChatGPT

# Nastaveni soketu
HOST = 'localhost'
PORT = 65432

# Vytvoreni soketu
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind((HOST, PORT))
server_socket.listen()

print("Cekame spojeni s MATLAB...")
client_socket, addr = server_socket.accept()
print(f"Pripojeno k {addr}")


xml_path = 'model_quadcopter_v1.xml'
model = mj.MjModel.from_xml_path(xml_path)  # MuJoCo model
data = mj.MjData(model)  # MuJoCo data


with mujoco.viewer.launch_passive(model, data) as viewer:
    # Close the viewer automatically after 30 wall-seconds.
    start = time.time()

    while viewer.is_running() and time.time() - start < 300:
        step_start = time.time()

        # mj_step can be replaced with code that also evaluates
        # a policy and applies a control signal before stepping the physics.
        mujoco.mj_step(model, data)

        # Example modification of a viewer option: toggle contact points every two seconds.
        with viewer.lock():
            viewer.opt.flags[mujoco.mjtVisFlag.mjVIS_CONTACTPOINT] = int(data.time % 2)
            if int(data.time % 2):
                data.ctrl = [10, 10, 10, 10]
            else:
                data.ctrl = [5, 5, 5, 5]

        # Отправка данных в MATLAB
        message = ','.join(map(str, data.ctrl.flatten()))
        client_socket.sendall(message.encode('utf-8'))  # posilame do Matlab
        #confirmation = client_socket.recv(1024).decode('utf-8')  # cekame odpoved od Matlab

        # Pick up changes to the physics state, apply perturbations, update options from GUI.
        viewer.sync()

        # Rudimentary time keeping, will drift relative to wall clock.

        time_until_next_step = model.opt.timestep - (time.time() - step_start)
        if time_until_next_step > 0:
            time.sleep(time_until_next_step)

