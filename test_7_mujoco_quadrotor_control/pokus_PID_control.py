import mujoco as mj
import mujoco.viewer  # p.s. high-level, more user-friendly and abstract interface
import time
import numpy as np
import matplotlib.pyplot as plt


# ===========================================POMOCNE FUNKCE=============================================================
def sensor_data_by_name(mj_model, mj_data, sensor_name):
    """
    Vlastni funkce pro nacteni dat ze senzoru  podle jeho nazvu v .XML
    To je jednodusi (pri velkem poctu senzoru), nez primo pouzivat prikaz data.sensordata[i:j] a vybirat spravne bunky
    :param mj_model:
    :param mj_data:
    :param sensor_name:
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
xml_path = 'model_quadcopter_v1.3.xml'  # xml file (assumes this is in the same folder as this file)
simend = 500  # simulation time

model = mj.MjModel.from_xml_path(xml_path)  # MuJoCo model
data = mj.MjData(model)  # MuJoCo data
viewer = mujoco.viewer.launch_passive(model, data)  # with mujoco.viewer.launch_passive(model, data) as viewer

# Example on how to set camera configuration
cam = viewer.cam
cam.azimuth = -128.6
cam.elevation = -38.1
cam.distance = 9.4
cam.lookat = [0.075, 0.459, 1.927]

# Nejake pocatecni podminky
data.ctrl[0:3+1] = (3.3*9.80)/4  # sila pro udrzeni kvadrokoptery, 4F=Mg
mj.mj_forward(model, data)  # je to stejne jako mj_step ale bez intergace podle casu

# matice pro ukladani dat polohy
positions = []
times = []
angles = []
accel = []
speed = []
angspeed = []
force = []
torque = []
z_distance = []


# ==========================================CYKLUS======================================================================
viewer.sync()
start = time.time()
# Close the viewer automatically after simend wall-seconds.
while viewer.is_running() and data.time < simend:
    print_cam_param(0, viewer.cam)  # zobrazovat-li parametry kamery
    step_start = time.time()

    # ==================================Program=========================================================================
    times.append(data.time)

    positions.append(data.geom('zakladna').xpos.copy())  # poloha kvadrokoptery
    accel.append(sensor_data_by_name(model, data, "akcelerometr"))
    speed.append(sensor_data_by_name(model, data, "mereni rychlosti"))
    angspeed.append(sensor_data_by_name(model, data, "gyroskop"))
    force.append(sensor_data_by_name(model, data, "senzor sily"))
    torque.append(sensor_data_by_name(model, data, "senzor momentu"))
    z_distance.append(sensor_data_by_name(model, data, "senzor vzdalenosti"))
    #
    # print("Force:", data.actuator_force)
    # print("Moment:", data.actuator_moment)
    # print("Gravitacni+Coriolisova:", data.qfrc_bias)
    # print("generalized force?", data.qfrc_applied)
    # print("Какая-то штука актуаторов, сила?:", data.qfrc_actuator)

    # ==============================Program konec=======================================================================

    # mj_step can be replaced with code that also evaluates
    # a policy and applies a control signal before stepping the physics.
    mj.mj_step(model, data)

    # Pick up changes to the physics state, apply perturbations, update options from GUI.
    viewer.sync()

    # Rudimentary time keeping, will drift relative to wall clock.
    time_until_next_step = model.opt.timestep - (time.time() - step_start)
    if time_until_next_step > 0:
        time.sleep(time_until_next_step/10)
# =======================================KONEC CYKLUS===================================================================

# porovnani casu konani programu a casu v simulaci
print("Real time", round(time.time() - start, 2))
print("Data.time", round(data.time, 2))

# poloha a uhel odkloneni
plt.figure()
positions = np.array(positions)
plt.plot(times, positions, label=['x', 'y', 'z'])
plt.title('Object Position Over Time')
plt.legend()
plt.show()

# zrychleni
plt.figure()
accel = np.array(accel)
plt.plot(times, accel, label=["ax", "ay", "az"])
plt.title("Akcelerometr")
plt.legend()
plt.show()

# rychlost
plt.figure()
speed = np.array(speed)
plt.plot(times, speed, label=["vx", "vy", "vz"])
plt.title("Velocimetr")
plt.legend()
plt.show()

# uhlova rychlost
plt.figure()
angspeed = np.array(angspeed)
plt.plot(times, angspeed, label=["wx", "wy", "wz"])
plt.title("Uhlova rychlost")
plt.legend()
plt.show()

plt.figure()
force = np.array(force)
plt.plot(times, force, label=["Fx", "Fy", "Fz"])
plt.title("Sila")
plt.legend()
plt.show()

# Moment (njeste jsem nepochopil jak se pocita)
plt.figure()
torque = np.array(torque)
plt.plot(times, torque, label=["Mx", "My", "Mz"])
plt.title("Moment")  # Moment mezi telesem a nafrazenym telesem (worldbody?)
plt.legend()
plt.show()

# Vzdalenost do podlahy
plt.figure()
z_distance = np.array(z_distance)
plt.plot(times, z_distance)
plt.title("Vzalenost od podlahy (max mereni 10)")
plt.show()

