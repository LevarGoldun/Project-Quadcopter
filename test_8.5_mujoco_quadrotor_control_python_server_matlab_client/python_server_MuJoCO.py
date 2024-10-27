import mujoco as mj
import mujoco.viewer  # p.s. high-level, more user-friendly and abstract interface
import time
import numpy as np
import matplotlib.pyplot as plt
from scipy.spatial.transform import Rotation  # pro vypocet uhlu Eulera z kvaternionu

import socket  # TCP communication
import select  # Are there any sockets
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


# def controller(mj_model, mj_data, z_ref, x_ref):
#     z_actual = mj_data.geom('zakladna').xpos[2]  # Z poloha kvadrokoptery
#     x_actual = mj_data.geom('zakladna').xpos[0]  # X poloha kvadrokoptery
#
#     F_cmd = PID_F_cmd.control(z_ref, z_actual)  # pozadovana vyska z
#
#     phi_desired = -1*PID_phi_desired.control(x_ref, x_actual)  # pozadovana poloha x --> pozadovany naklon kvadrokoptery
#     # vystupem PID_phi_desired jsou radiany; minus, protoze kladny smer X je v jinem smeru nez v Simulink
#
#     # Chci pohybovat v rovice XY, tzn. kolma osa k teto rovine je Y --> merime nakloneni kvadrokoptery pitch
#     # [roll, pitch] = roll_pitch_calculation(mj_model, mj_data)  # pocita z hodnot akceleromentu-->velky sum
#     [roll, pitch] = roll_pitch_calculation_scipy(mj_model, mj_data)  # z kvaternionu-->lepsi kvalita dat
#
#     angle_cmd = PID_angle_cmd.control(phi_desired, pitch * np.pi / 180)
#
#     F1 = F_cmd + angle_cmd
#     F2 = F_cmd - angle_cmd
#
#     pid_out.append([F_cmd, phi_desired, angle_cmd])
#
#     # orientacni model
#     # F2      F1
#     # ^       ^
#     # |       |
#     # ____*____
#
#     # motor 1 a motor 2 budou mit silu "F2" jako v Simulink
#     data.ctrl[0] = F2/2
#     data.ctrl[1] = F2/2
#
#     # motor 3 a motor 4 budou mit silu "F1"
#     data.ctrl[2] = F1/2
#     data.ctrl[3] = F1/2

# def roll_pitch_calculation_scipy(mj_model, mj_data): --> moved to MATLAB
#     """
#     Calculating roll and pitch from quaternions
#     :param mj_model:
#     :param mj_data:
#     :return: roll and pitch in degrees !!!
#     """
#     # teleso "kvadrokoptera" ma index radku 1
#     quat = mj_data.xquat[1][:]  # vystupem jsou quaternions
#     r = Rotation.from_quat([quat[1], quat[2], quat[3], quat[0]])  # SciPy pouziva poradi [x, y, z, w]
#     euler_angles = r.as_euler('xyz', degrees=True)
#     roll = euler_angles[0]
#     pitch = euler_angles[1]
#     return round(roll, 3), round(pitch, 3)
# ===========================================KONEC POMOCNE FUNKCE=======================================================


# ==============================================NASTAVENI===============================================================
# Server settings
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind(('localhost', 65432))
server_socket.listen(1)
print("Waiting for connection with MATLAB...")
client_socket, addr = server_socket.accept()
print(f"Connected to {addr}")
#client_socket.setblocking(False)  # Set non-blocking mode

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
xml_path = 'model_quadcopter_v1.4.xml'
model = mj.MjModel.from_xml_path(xml_path)  # MuJoCo model
data = mj.MjData(model)  # MuJoCo data
viewer = mujoco.viewer.launch_passive(model, data)  # with mujoco.viewer.launch_passive(model, data) as viewer

simend = 500  # simulation time
dt = model.opt.timestep  # dano nastavenim .XML souboru
client_socket.sendall(str(dt).encode('utf-8'))  # Posilame dt do Matlab
time.sleep(1)

# Example on how to set camera configuration
cam = viewer.cam
cam.azimuth = -127.8
cam.elevation = -44
cam.distance = 18
cam.lookat = [-0.18, 0.66, 7.09]

# PIDs inicialization --> moved to MATLAB
# pri takovem nastaveni fungule, ale nerealisticky a s inf. silami.
# PID_F_cmd = PID(dt, 8.92390432404577, 2.25471500348612, 8.67284220431323, umin=0, umax=20)
# PID_phi_desired = PID(dt, -0.00323096272986417, -1.0967929328284e-05, -0.0313597401851494, umin=-np.pi/2, umax=np.pi/2)
# PID_angle_cmd = PID(dt, 0.122982000274937, 0.00445840861689157, 0.833002920844437, umin=-5, umax=5)

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

# Data storage matrix --> moved to MATLAB
# positions = []
# times = []
# angles = []
# accel = []
# speed = []
# angspeed = []
# force = []
# torque = []
# z_distance = []
# pid_out = []

mj.mj_forward(model, data)  # je to stejne jako mj_step ale bez intergace podle casu
viewer.sync()

# ==========================================MAIN LOOP===================================================================
# Initialization
data.ctrl[0:3 + 1] = (3.8 * 9.81) / 4*0.99  # sila pro udrzeni kvadrokoptery, 4F=Mg (p.s. celkova hmotnost 3.3 kg)
acknowledged = True
last_time = time.time()
start = time.time()

# Close the viewer automatically after simend wall-seconds.
while viewer.is_running() and data.time < simend:
    print_cam_param(0, viewer.cam)  # zobrazovat-li parametry kamery,
    step_start = time.time()

    # ==================================Program=========================================================================
    # Send data to MATLAB
    if step_start - last_time > 0.1 and acknowledged:
        last_time = step_start

        # Forming a data dictionary (what we want to send)
        data_to_send = {
            "simulationTime": data.time,
            # NumPy array is not JSON serializable -> convert using .tolist()
            "position": (data.geom('zakladna').xpos.copy()).tolist(),
            "quaternions": (data.xquat[1][:]).tolist(),
        }
        # Convert the dictionary to a JSON string
        json_data_to_send = json.dumps(data_to_send)
        client_socket.sendall(json_data_to_send.encode('utf-8'))
        acknowledged = False  # Waiting for confirmation after sending

    # Check if a message has arrived from the client
    ready_to_read, _, _ = select.select([client_socket], [], [], 0)
    if ready_to_read:
        get = client_socket.recv(1024).decode('utf-8')  # Read
        json_str = json.loads(get)
        if 'command' in json_str:
            if json_str['command'] == 'OK':  # expected response from Matlab
                acknowledged = True
        else:
            F1 = json_str['F1']
            F2 = json_str['F2']

            # motor 1 a motor 2 budou mit silu "F2" jako v Simulink
            data.ctrl[0] = F2 / 2
            data.ctrl[1] = F2 / 2

            # motor 3 a motor 4 budou mit silu "F1"
            data.ctrl[2] = F1 / 2
            data.ctrl[3] = F1 / 2

    # moved to MATLAB
    # times.append(data.time)
    #
    # positions.append(data.geom('zakladna').xpos.copy())  # poloha kvadrokoptery
    # angles.append(roll_pitch_calculation_scipy(model, data))  # z kvaternionu presneji uhly
    #
    # accel.append(sensor_data_by_name(model, data, "akcelerometr"))
    # speed.append(sensor_data_by_name(model, data, "mereni rychlosti"))
    # angspeed.append(sensor_data_by_name(model, data, "gyroskop"))
    # force.append(sensor_data_by_name(model, data, "senzor sily"))
    # torque.append(sensor_data_by_name(model, data, "senzor momentu"))
    # z_distance.append(sensor_data_by_name(model, data, "senzor vzdalenosti"))

    # ==============================Program konec=======================================================================

    # mj_step can be replaced with code that also evaluates
    # a policy and applies a control signal before stepping the physics.
    mj.mj_step(model, data)

    # Pick up changes to the physics state, apply perturbations, update options from GUI.
    viewer.sync()

    # Rudimentary time keeping, will drift relative to wall clock.
    time_until_next_step = dt - (time.time() - step_start)
    if time_until_next_step > 0:
        time.sleep(time_until_next_step / 1)
# =======================================KONEC CYKLUS===================================================================

# Comparison of program and simulation time
print("Real time:", round(time.time() - start, 2))
print("Data.time:", round(data.time, 2), ", dt:", dt)
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
