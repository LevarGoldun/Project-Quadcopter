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

# ===========================================POMOCNE FUNKCE=============================================================


def print_cam_param(permit, camera):
    if permit:
        print('cam.azimuth =', camera.azimuth, 'cam.elevation =', camera.elevation, 'cam.distance =', camera.distance)
        print('cam.lookat = [', camera.lookat[0], ',', camera.lookat[1], ',', camera.lookat[2], ']')
        # output from function write in camera parameter settings

# ========================================KONEC POMOCNE FUNKCE==========================================================


# ==============================================SETTINGS================================================================
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
xml_path = '../model_quadcopter_v2_debug.xml'
model = mj.MjModel.from_xml_path(xml_path)  # MuJoCo model
data = mj.MjData(model)  # MuJoCo data
viewer = mujoco.viewer.launch_passive(model, data)

# ------------------------------------------Simulation setup------------------------------------------------------------
# Sending to MATLAB simulation time step (from .xml file) and total simulation time
simtime = 100  # [s]
timestep = str(model.opt.timestep)  # [s]

timeData = {"SimTime": simtime, "TimeStep": timestep}
client_socket.sendall(json.dumps(timeData).encode('utf-8'))
time.sleep(1)

print("Total simulation time: " + str(simtime) + " s")
print("Model time step: " + str(timestep) + " s")

# -----------------------------------------Camera setup-----------------------------------------------------------------
# Example on how to set camera configuration
cam_data_permit = False  # zobrazovat-li parametry kamery,
cam = viewer.cam
cam.azimuth = -107.42
cam.elevation = -47.15
cam.distance = 5.16
cam.lookat = [-0.0049, 0.4150, 2.1315]

# ======================================================================================================================


# ==========================================MAIN PROGRAM================================================================
async def receive_from_matlab(viewer):
    """
    Asynchronously receiving data
    from MATLAB and sending data back
    """
    try:
        while viewer.is_running():
            receive = await asyncio.to_thread(client_socket.recv, 1024)
            if receive:
                json_str = json.loads(receive.decode('utf-8'))
                m_square = json_str['Rotor_RPS_square']
                data.ctrl = [m_square[0], m_square[1], m_square[2], m_square[3]]

                # Send data to MATLAB
                # Forming a data dictionary
                data_to_send = {
                    "SimulationTime": data.time,
                    # NumPy array is not JSON serializable -> convert using .tolist()
                    "DronPos": (data.body('quadcopter').xpos.copy()).tolist(),  # xyz quadcopter
                    "PendPos": (data.geom('point_mass').xpos.copy()).tolist(),  # xyz point mass

                    "DronRotM": (data.body('quadcopter').xmat.copy()).tolist(),  # rot. matrix quadcopter
                    "PendRotM": (data.geom('point_mass').xmat.copy()).tolist(),  # rot. matrix point mass

                }

                # Convert the dictionary to a JSON string
                json_data_to_send = json.dumps(data_to_send)
                await asyncio.to_thread(client_socket.sendall, json_data_to_send.encode('utf-8'))
            await asyncio.sleep(0.005)
    except asyncio.CancelledError:
        pass


async def mujoco_simulation(viewer):
    """
    Asynchronous running MuJoCo simulation
    """
    try:
        while data.time < simtime and viewer.is_running():
            print_cam_param(cam_data_permit, viewer.cam)
            with viewer.lock():
                # mj_step can be replaced with code that also evaluates
                # a policy and applies a control signal before stepping the physics.
                mujoco.mj_step(model, data)

            # Pick up changes to the physics state, apply perturbations, update options from GUI.
            viewer.sync()
            # await asyncio.sleep(model.opt.timestep)
            # await asyncio.sleep(0.)
    except asyncio.CancelledError:
        pass


async def main():
    """
    Combine tasks and run them in parallel
    """
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
# ========================================END PROGRAM===================================================================
