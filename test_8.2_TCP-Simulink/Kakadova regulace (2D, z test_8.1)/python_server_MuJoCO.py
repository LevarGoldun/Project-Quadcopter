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
xml_path = 'model_quadcopter_v1.4.1.xml'
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
        F1 = json_str['F1']
        F2 = json_str['F2']

        # motor 1 a motor 2 budou mit silu "F2" jako v Simulink
        data.ctrl[0] = F2 / 2
        data.ctrl[1] = F2 / 2
        # motor 3 a motor 4 budou mit silu "F1"
        data.ctrl[2] = F1 / 2
        data.ctrl[3] = F1 / 2

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
#
# # data z PID
# plt.figure()
# pid_out = np.array(pid_out)
# plt.plot(times, pid_out, label=['F_cmd', 'phi_desired', 'angle_cmd'])
# plt.title('PIDs outputs')
# plt.legend()
# plt.show()
#
# # poloha
# plt.figure()
# positions = np.array(positions)
# plt.plot(times, positions, label=['x', 'y', 'z'])
# plt.title('Object Position Over Time')
# plt.legend()
# plt.show()
#
# # roll a pitch
# plt.figure()
# angles = np.array(angles)
# plt.plot(times, angles, label=['roll [deg]', 'pitch[deg]'])
# plt.title('Orientation Over Time')
# plt.legend()
# plt.show()
#
# # zrychleni
# plt.figure()
# accel = np.array(accel)
# plt.plot(times, accel, label=["ax", "ay", "az"])
# plt.title("Akcelerometr")
# plt.legend()
# plt.show()
#
# # rychlost
# plt.figure()
# speed = np.array(speed)
# plt.plot(times, speed, label=["vx", "vy", "vz"])
# plt.title("Velocimetr")
# plt.legend()
# plt.show()
#
# # uhlova rychlost
# plt.figure()
# angspeed = np.array(angspeed)
# plt.plot(times, angspeed, label=["wx", "wy", "wz"])
# plt.title("Uhlova rychlost")
# plt.legend()
# plt.show()
#
# plt.figure()
# force = np.array(force)
# plt.plot(times, force, label=["Fx", "Fy", "Fz"])
# plt.title("Sila")
# plt.legend()
# plt.show()
#
# # Moment (njeste jsem nepochopil jak se pocita)
# plt.figure()
# torque = np.array(torque)
# plt.plot(times, torque, label=["Mx", "My", "Mz"])
# plt.title("Moment")  # Moment mezi telesem a nafrazenym telesem (worldbody?)
# plt.legend()
# plt.show()
#
# # Vzdalenost do podlahy
# plt.figure()
# z_distance = np.array(z_distance)
# plt.plot(times, z_distance)
# plt.title("Vzalenost od podlahy (max mereni 10)")
# plt.show()
