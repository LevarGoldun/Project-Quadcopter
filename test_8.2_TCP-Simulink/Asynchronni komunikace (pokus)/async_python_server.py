"""
Проба сделать асинхронную передачу данных.
Сервер как реальный мир. Матлаб/Синулинк как микрокомпьютер, который
собирает, обрабатывает и посылает управляющие сигналы с какой-то частотой
"""

import time
import mujoco as mj
import mujoco.viewer
import socket  # TCP communication
import json  # To convert Python dictionary into a friendly format
import asyncio

# Server settings
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind(('localhost', 65432))
server_socket.listen(1)
print("Waiting for connection with MATLAB...")
client_socket, addr = server_socket.accept()
print(f"Connected to {addr}")

# Test connection with Matlab
get = client_socket.recv(1024).decode('utf-8')  # Read
if get == 'Hello':
    print('Matlab: ' + get)
    send = 'Ahoj'
    time.sleep(0.05)
    client_socket.sendall(send.encode('utf-8'))  # Answer

# MuJoCo settings
xml_path = 'model_quadcopter_v1.xml'
model = mj.MjModel.from_xml_path(xml_path)  # MuJoCo model
data = mj.MjData(model)  # MuJoCo data

# ------------------------------------------SIMULATION SETUP------------------------------------------------------------
# Sending to MATLAB the simulation time step (from .xml file)
timestep = str(model.opt.timestep)
client_socket.sendall(timestep.encode('utf-8'))

# Getting the total simulation time from Matlab
simtime = int(client_socket.recv(1024).decode('utf-8'))
print("Simulation time: " + str(simtime) + " s")
print("Time step: " + str(timestep))
# ----------------------------------------------------------------------------------------------------------------------


# ----------------------------------------MAIN PROGRAM------------------------------------------------------------------
async def receive_from_matlab(viewer):
    """
    Асинхронное получение данных
    от MATLAB и отправление данных обратно
    """
    try:
        while viewer.is_running():
            receive = await asyncio.to_thread(client_socket.recv, 1024)
            print(receive)
            if receive:
                json_str = json.loads(receive.decode('utf-8'))
                m_ctrl = json_str['MotorSignal']
                print("m_ctrl: " + str(m_ctrl))
                data.ctrl = [m_ctrl, m_ctrl, m_ctrl, m_ctrl]

                # Send data to MATLAB
                # Forming a data dictionary
                data_to_send = {
                    "SimulationTime": data.time,
                    "Number of position coordinates": model.nq,
                    "Number of degrees of freedom": model.nv,
                    "Nothing": 'Random text'
                }
                # Convert the dictionary to a JSON string
                json_data_to_send = json.dumps(data_to_send)
                # print("posilame: "+json_data_to_send)
                await asyncio.to_thread(client_socket.sendall, json_data_to_send.encode('utf-8'))
            await asyncio.sleep(0.05)
    except asyncio.CancelledError:
        pass


async def mujoco_simulation(viewer):
    """
    Асинхронное выполнение симуляции MuJoCo
    """
    try:
        while data.time < simtime and viewer.is_running():
            with viewer.lock():
                # mj_step can be replaced with code that also evaluates
                # a policy and applies a control signal before stepping the physics.
                mujoco.mj_step(model, data)

            # Pick up changes to the physics state, apply perturbations, update options from GUI.
            viewer.sync()
            await asyncio.sleep(model.opt.timestep)
    except asyncio.CancelledError:
        pass

async def main():
    """
    Объединение задач и запуск их параллельно.
    """
    with mujoco.viewer.launch_passive(model, data) as viewer:
        try:
            await asyncio.gather(
                receive_from_matlab(viewer),
                mujoco_simulation(viewer)
            )
        except asyncio.CancelledError:
            pass

asyncio.run(main())
client_socket.close()
server_socket.close()
print("End")
