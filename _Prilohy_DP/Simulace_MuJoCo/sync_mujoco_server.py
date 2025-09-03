import time
import mujoco as mj
import mujoco.viewer
import socket  # TCP communication
import json  # To convert Python dictionary into a friendly format
import numpy as np

# ===========================================POMOCNE FUNKCE=============================================================
def print_cam_param(permit, camera):
    if permit:
        print('cam.azimuth =', camera.azimuth, 'cam.elevation =', camera.elevation, 'cam.distance =', camera.distance)
        print('cam.lookat = [', camera.lookat[0], ',', camera.lookat[1], ',', camera.lookat[2], ']')
        # output from function write in camera parameter settings


def sensor_data_by_name(mj_model, mj_data, sensor_name):
    """
    Vlastni funkce pro nacteni dat ze senzoru  podle jeho nazvu v .XML
    To je jednodusi (pri velkem poctu senzoru), nez primo pouzivat prikaz data.sensordata[i:j]
    a vybirat spravne bunky
    """
    # Identifiktor senzoru podle jeho jmena
    sensor_id = mj.mj_name2id(mj_model, mj.mjtObj.mjOBJ_SENSOR, sensor_name)
    # Pocatecni index
    sensor_adr = mj_model.sensor_adr[sensor_id]
    # Delka dat ze senzoru
    sensor_dim = mj_model.sensor_dim[sensor_id]
    return mj_data.sensordata[sensor_adr:sensor_adr + sensor_dim].copy()


def update_T_vector(model, site_name, value):
    site_id = mj.mj_name2id(model, mj.mjtObj.mjOBJ_SITE, site_name)
    norm_w = max(0.0, min(value / 3904576, 1.0))
    y2 = norm_w * (-0.5)
    # model.site_fromto[site_id] = [0, 0, -0.29, 0, y2, -0.29]
    print(model.site_fromto.shape)


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
xml_path = 'model_quadcopter_v2.xml'
model = mj.MjModel.from_xml_path(xml_path)  # MuJoCo model
data = mj.MjData(model)  # MuJoCo data
viewer = mujoco.viewer.launch_passive(model, data)

# ------------------------------------------Simulation setup------------------------------------------------------------
# Sending to MATLAB simulation time step (from .xml file) and total simulation time
simtime = 1  # [s]
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
# -----------------------------------------Other------------------------------------------------------------------------
# nv = len(data.qvel)
# M = np.zeros((nv, nv))
# mj.mj_fullM(model, M, data.qM)  # matice hmotnosti a setrvacnosti
# print("Matice hmotnosti a setrvacnosti:")
# print(M)

# ======================================================================================================================


# ==========================================MAIN PROGRAM================================================================
# Initialization
data.ctrl[0:3 + 1] = (3 * 9.81) / 4 / 0.0000093
# uhlova rychlost pro udrzeni kvadrokoptery, 4*k*w^2=Mg (p.s. celkova hmotnost 3 kg)

try:
    while viewer.is_running() and data.time < simtime+model.opt.timestep:
        print_cam_param(cam_data_permit, viewer.cam)

        # Send data to MATLAB
        data_to_send = {
            "SimulationTime": data.time,
            "DronPos": data.body('quadcopter').xpos.tolist(),
            "PendPos": data.geom('point_mass').xpos.tolist(),
            "DronRotM": data.body('quadcopter').xmat.tolist(),
            "PendRotM": data.geom('point_mass').xmat.tolist(),

            "imuAccel": sensor_data_by_name(model, data, 'akcelerometr').tolist(),
            "imuGyro": sensor_data_by_name(model, data, 'gyroskop').tolist(),
            "imuMag": sensor_data_by_name(model, data, 'magnetometr').tolist()
        }
        # Convert the dictionary to a JSON string
        json_data_to_send = json.dumps(data_to_send)
        # Send
        client_socket.sendall(json_data_to_send.encode('utf-8'))

        # Receive data from MATLAB
        # print("Wait get")
        get = client_socket.recv(1024)
        if get:
            json_str = json.loads(get.decode('utf-8'))
            m_square = json_str['Rotor_AngVel_square']
            data.ctrl = [m_square[0], m_square[1], m_square[2], m_square[3]]

            # Changing vector length (not working)
            # update_T_vector(model, "T_vektor1", m_square[1])

            # STEP the simulation
            with viewer.lock():
                mj.mj_step(model, data)
            # Pick up changes to the physics state, apply perturbations, update options from GUI.
            viewer.sync()
            # time.sleep(0.5)
except Exception as e:
    print(f"Error: {e}")

client_socket.close()
server_socket.close()
print("End")
# ========================================END PROGRAM===================================================================
