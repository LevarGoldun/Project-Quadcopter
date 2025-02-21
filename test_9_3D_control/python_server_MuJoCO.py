import mujoco as mj
import mujoco.viewer  # p.s. high-level, more user-friendly and abstract interface
import time

import socket  # TCP communication
import json  # To convert Python dictionary into a friendly format


# ===========================================POMOCNE FUNKCE=============================================================
def sensor_data_by_name(mj_model, mj_data, sensor_name):
    """
    Vlastni funkce pro nacteni dat ze senzoru  podle jeho nazvu v .XML
    To je jednodusi (pri velkem poctu senzoru), nez primo pouzivat prikaz data.sensordata[i:j] a vybirat spravne bunky
    :param mj_model
    :param mj_data
    :param sensor_name
    :return:
    """
    # Identifiktor senzoru podle jeho jmena
    sensor_id = mj.mj_name2id(mj_model, mj.mjtObj.mjOBJ_SENSOR, sensor_name)
    # Pocatecni index
    sensor_adr = mj_model.sensor_adr[sensor_id]
    # Delka dat ze senzoru
    sensor_dim = mj_model.sensor_dim[sensor_id]
    return mj_data.sensordata[sensor_adr:sensor_adr + sensor_dim].copy()


def print_cam_param(permit, camera):
    if permit:
        print('cam.azimuth =', camera.azimuth, 'cam.elevation =', camera.elevation, 'cam.distance =', camera.distance)
        print('cam.lookat = [', camera.lookat[0], ',', camera.lookat[1], ',', camera.lookat[2], ']')
        # vytup z funkce napsat v nastaveni parametru kamery

# ===========================================KONEC POMOCNE FUNKCE=======================================================


# ==============================================NASTAVENI===============================================================
# Server settings
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind(('localhost', 65432))
server_socket.listen(1)
print("Waiting for connection with MATLAB...")
client_socket, addr = server_socket.accept()
print(f"Connected to {addr}")
# client_socket.setblocking(False)  # Set non-blocking mode --> I have an idea for a blocking mode

# Test connection with Matlab
get = client_socket.recv(1024).decode('utf-8')  # Read
if get == 'Hello':
    print('Matlab: ' + get)
    send = 'Ahoj'
    client_socket.sendall(send.encode('utf-8'))  # Answer
    time.sleep(0.05)

# MuJoCo settings
# xml_path = 'model_quadcopter_v1.4.1.xml'
xml_path = 'model_quadcopter_v1.4.2_no_pendulum.xml'

model = mj.MjModel.from_xml_path(xml_path)  # MuJoCo model
data = mj.MjData(model)  # MuJoCo data
viewer = mujoco.viewer.launch_passive(model, data)  # with mujoco.viewer.launch_passive(model, data) as viewer

# ------------------------------------------SIMULATION SETUP------------------------------------------------------------
# Sending to MATLAB the simulation time step (from .xml file)
timestep = str(model.opt.timestep)
client_socket.sendall(timestep.encode('utf-8'))

# Getting the total simulation time from Matlab
simtime = int(client_socket.recv(1024).decode('utf-8'))
print("Simulation time: " + str(simtime) + " s")
print("Time step: " + str(timestep))
# ----------------------------------------------------------------------------------------------------------------------

# Example on how to set camera configuration
cam_data_permit = False  # zobrazovat-li parametry kamery,
cam = viewer.cam
cam.azimuth = -127.8
cam.elevation = -44
cam.distance = 18
cam.lookat = [-0.18, 0.66, 7.09]

# ======================================Data pro drobne deje v Matlab===================================================
# nv = len(data.qvel)
# M = np.zeros((nv, nv))
# mj.mj_fullM(model, M, data.qM)  # matice hmotnosti a setrvacnosti
# print(M)

# pocitam delku od motoru 4 do motoru 2 (vzdalenost 2*L dle Simulink)
# left_position = data.site('thrust4').xpos[0]
# right_position = data.site('thrust2').xpos[0]
# print("Polovicni delka kvadr.", abs(left_position-right_position)/2)

# ======================================================================================================================

mj.mj_forward(model, data)  # je to stejne jako mj_step ale bez intergace podle casu
viewer.sync()

# ==========================================MAIN LOOP===================================================================
# Initialization
data.ctrl[0:3 + 1] = (3.8 * 9.81) / 4*0.99  # sila pro udrzeni kvadrokoptery, 4F=Mg (p.s. celkova hmotnost 3.3 kg)

# Close the viewer automatically after simtime wall-seconds.
while viewer.is_running() and data.time < simtime:
    print_cam_param(cam_data_permit, viewer.cam)

    # ==================================Program=========================================================================
    with viewer.lock():
        # Get data from MATLAB
        get = client_socket.recv(1024).decode('utf-8')  # Read
        json_str = json.loads(get)
        m1 = json_str['m1']
        m3 = json_str['m3']
        m2 = json_str['m2']
        m4 = json_str['m4']

        # Sily na motorech
        data.ctrl[0] = m1
        data.ctrl[1] = m2
        data.ctrl[2] = m3
        data.ctrl[3] = m4

        # Send data to MATLAB
        # Forming a data dictionary (what we want to send)
        data_to_send = {
            "SimulationTime": data.time,
            # NumPy array is not JSON serializable -> convert using .tolist()
            "Position": (data.geom('zakladna').xpos.copy()).tolist(),
            "Quaternions": (data.xquat[1][:]).tolist(),
        }
        # Convert the dictionary to a JSON string
        json_data_to_send = json.dumps(data_to_send)
        client_socket.sendall(json_data_to_send.encode('utf-8'))

    # ==============================Program konec=======================================================================

    # mj_step can be replaced with code that also evaluates
    # a policy and applies a control signal before stepping the physics.
    mj.mj_step(model, data)

    # Pick up changes to the physics state, apply perturbations, update options from GUI.
    viewer.sync()

# =======================================KONEC CYKLUS===================================================================

server_socket.close()
print("End")