# Chci otestovat pristup k atributum mj.MjData()
# a take pridat senzor a podivat se, co bude na vystupu

import mujoco as mj
import mujoco.viewer  # p.s. high-level, more user-friendly and abstract interface
import time
import numpy as np
import matplotlib.pyplot as plt

# ===========================================POMOCNE FUNKCE=============================================================
def print_cam_param(permit, camera):
    if permit:
        print('cam.azimuth =', camera.azimuth, 'cam.elevation =', camera.elevation, 'cam.distance =', camera.distance)
        print('cam.lookat = [', camera.lookat[0], ',', camera.lookat[1], ',', camera.lookat[2], ']')
        # vytup z funkce napsat v nastaveni parametru kamery


# ===========================================KONEC POMOCNE FUNKCE=======================================================


# ==============================================NASTAVENI===============================================================
xml_path = 'pendulum_test.xml'  # xml file (assumes this is in the same folder as this file)
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
data.qpos[0] = np.pi/2  # pro joint typu hinge v .xml

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

    # ==================================program=========================================================================
    positions.append(data.geom('kulicka').xpos.copy())  # poloha kulicky, je to geometrie 1
    times.append(data.time)

    angles.append(data.qpos.copy()*180/np.pi)

    accel.append(data.sensordata[1:3+1].copy())
    speed.append(data.sensordata[4:6+1].copy())
    angspeed.append(data.sensordata[7:9+1].copy())
    force.append(data.sensordata[10:12+1].copy())
    torque.append(data.sensordata[13:15+1].copy())
    z_distance.append(data.sensordata[16])

    # ==============================program konec=======================================================================

    # mj_step can be replaced with code that also evaluates
    # a policy and applies a control signal before stepping the physics.
    mj.mj_step(model, data)

    # Example modification of a viewer option: toggle contact points every two seconds.
    # with viewer.lock():
    #     viewer.opt.flags[mujoco.mjtVisFlag.mjVIS_CONTACTPOINT] = int(data.time % 2)

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
positions = np.array(positions)
fig, axs = plt.subplots(2, 1)

axs[0].plot(times, positions[:, 0], label='X position')
axs[0].plot(times, positions[:, 1], label='Y position')
axs[0].plot(times, positions[:, 2], label='Z position')

axs[0].set_xlabel('Time Step')
axs[0].set_ylabel('Position')
axs[0].set_title('Object Position Over Time')
axs[0].legend()

axs[1].plot(times, angles, label='Angles')
axs[1].set_xlabel('Time Step')
axs[1].set_ylabel('Angles [deg]')
axs[1].legend()

plt.tight_layout()  # vzdalenost mezi subploty
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

# Sila
# !!! V danem konkretnim pripade kde mame volne kmitani, tak na kyvadlo pusobi pouze gravitacni sila v
# jednotlivych smerech. Fz = m*g = 2*g -> graf se shoduje s grafem zrychleni (jenom hodnoty o velikost hmotnosti vetsi)
plt.figure()
force = np.array(force)
plt.plot(times, force, label=["Fx", "Fy", "Fz"])
plt.title("Sila")  # Sila mezi telesem a nafrazenym telesem (worldbody?)
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

