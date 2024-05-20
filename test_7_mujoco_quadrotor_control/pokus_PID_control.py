import mujoco as mj
import mujoco.viewer  # p.s. high-level, more user-friendly and abstract interface
import time
import numpy as np
import matplotlib.pyplot as plt


# ===========================================POMOCNE FUNKCE=============================================================
class PID:  # https://thingsdaq.org/2022/04/07/digital-pid-controller/
    def __init__(self, Ts, kp, ki, kd, umax=np.inf, umin=-np.inf, tau=0.0):
        #
        self._Ts = Ts  # Sampling period (s)
        self._kp = kp  # Proportional gain
        self._ki = ki  # Integral gain
        self._kd = kd  # Derivative gain
        self._umax = umax  # Upper output saturation limit
        self._umin = umin  # Lower output saturation limit
        self._tau = tau  # Derivative term filter time constant (s)
        #
        self._eprev = [0, 0]  # Previous errors e[n-1], e[n-2]
        self._uprev = 0  # Previous controller output u[n-1]
        self._udfiltprev = 0  # Previous derivative term filtered value

    def control(self, ysp, y):
        # Calculating error e[n]
        e = ysp - y
        # Calculating proportional term
        up = self._kp * (e - self._eprev[0])
        # Calculating integral term (with anti-windup)
        ui = self._ki*self._Ts * e
        if (self._uprev >= self._umax) or (self._uprev <= self._umin):
            ui = 0
        # Calculating derivative term
        ud = self._kd/self._Ts * (e - 2*self._eprev[0] + self._eprev[1])
        # Filtering derivative term
        udfilt = (
            self._tau/(self._tau+self._Ts)*self._udfiltprev +
            self._Ts/(self._tau+self._Ts)*ud
        )
        # Calculating PID controller output u[n]
        u = self._uprev + up + ui + udfilt

        # Updating previous time step errors e[n-1], e[n-2]
        self._eprev[1] = self._eprev[0]  # e[n-1]-->e[n-2]
        self._eprev[0] = e  # e[n]-->e[n-1]

        # Updating previous time step output value u[n-1]
        self._uprev = u

        # Updating previous time step derivative term filtered value
        self._udfiltprev = udfilt

        # Limiting output (just to be safe)
        if u < self._umin:
            u = self._umin
        elif u > self._umax:
            u = self._umax

        # Returning controller output at current time step
        return u


def sensor_data_by_name(mj_model, mj_data, sensor_name):
    """
    Vlastni funkce pro nacteni dat ze senzoru  podle jeho nazvu v .XML
    To je jednodusi (pri velkem poctu senzoru), nez primo pouzivat prikaz data.sensordata[i:j] a vybirat spravne bunky
    :param mj_model: писька
    :param mj_data: дриська
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


def controller(mj_model, mj_data):
    z_actual = mj_data.geom('zakladna').xpos[2]  # Z poloha kvadrokoptery
    x_actual = mj_data.geom('zakladna').xpos[0]  # X poloha kvadrokoptery

    F_cmd = PID_F_cmd.control(4, z_actual)  # pozadovana vyska z
    phi_desired = PID_phi_desired.control(-5, x_actual)  # pozadovana poloha x --> pozadovany naklon kvadrokoptery
    # vystupem PID_phi_desired jsou radiany

    # Chci pohybovat v rovice XY, tzn. kolma osa k teto rovine je Y --> uhel pitch
    [roll, pitch] = roll_pitch_calculation(mj_model, mj_data)
    angle_cmd = -1*PID_angle_cmd.control(phi_desired, pitch*np.pi/180)
    # minus, protoze kladny smer X je v jinem smeru nez v Simulink

    F1 = F_cmd + angle_cmd
    F2 = F_cmd - angle_cmd

    pid_out.append([F_cmd, phi_desired, angle_cmd])

    # orientacni model
    # F2      F1
    # ^       ^
    # |       |
    # ____*____

    # motor 1 a motor 2 budou mit silu "F2" jako v Simulink
    data.ctrl[0] = F2
    data.ctrl[1] = F2

    # motor 3 a motor 4 budou mit silu "F1"
    data.ctrl[2] = F1
    data.ctrl[3] = F1


def roll_pitch_calculation(mj_model, mj_data):
    """
    Calculating roll and pitch from the accelerometer
    :param mj_model:
    :param mj_data:
    :return: roll and pitch in degrees !!!
    """
    # rotation sequence Rxyz
    [X, Y, Z] = sensor_data_by_name(mj_model, mj_data, "akcelerometr")
    roll = np.arctan2(Y, Z) * 180/np.pi  # x axis
    pitch = np.arctan2(-X, np.sqrt(Y*Y + Z*Z)) * 180/np.pi  # y axis
    return round(roll, 3), round(pitch, 3)


# ===========================================KONEC POMOCNE FUNKCE=======================================================


# ==============================================NASTAVENI===============================================================
xml_path = 'model_quadcopter_v1.3.xml'  # xml file (assumes this is in the same folder as this file)
model = mj.MjModel.from_xml_path(xml_path)  # MuJoCo model
data = mj.MjData(model)  # MuJoCo data
viewer = mujoco.viewer.launch_passive(model, data)  # with mujoco.viewer.launch_passive(model, data) as viewer

simend = 500  # simulation time
dt = model.opt.timestep  # dano nastavenim .XML souboru

# Example on how to set camera configuration
cam = viewer.cam
cam.azimuth = -128.6
cam.elevation = -38.1
cam.distance = 9.4
cam.lookat = [0.075, 0.459, 1.927]

# Nejake pocatecni podminky
#data.ctrl[0:3+1] = (3.3*9.81)/4  # sila pro udrzeni kvadrokoptery, 4F=Mg (p.s. celkova hmotnost 3.3 kg]

# pri takovem nastaveni fungule, ale nerealisticky a s inf. silami.
PID_F_cmd = PID(dt, 8.92390432404577, 2.25471500348612, 8.67284220431323)
PID_phi_desired = PID(dt, -0.00323096272986417, -1.0967929328284e-05, -0.0313597401851494, umax=np.pi/2, umin=-np.pi/2)
PID_angle_cmd = PID(dt, 0.122982000274937, 0.00445840861689157, 0.833002920844437)

# =============================================================Data pro Matlab
M = np.zeros((6, 6))
mj.mj_fullM(model, M, data.qM)  # matice hmotnosti a setrvacnosti
#print(M)

# pocitam delku od motoru 4 do motoru 2 (vzdalenost 2*L dle Simulink)
left_position = data.site('thrust4').xpos[0]
right_position = data.site('thrust2').xpos[0]
#print("Polovicni delka kvadr.", abs(left_position-right_position)/2)

# ==============================================================



# matice pro ukladani dat
positions = []
times = []
angles = []
accel = []
speed = []
angspeed = []
force = []
torque = []
z_distance = []

mj.mj_forward(model, data)  # je to stejne jako mj_step ale bez intergace podle casu
viewer.sync()

pid_out = []
# ==========================================CYKLUS======================================================================
start = time.time()
# Close the viewer automatically after simend wall-seconds.
while viewer.is_running() and data.time < simend:
    print_cam_param(0, viewer.cam)  # zobrazovat-li parametry kamery
    step_start = time.time()

    # ==================================Program=========================================================================
    controller(model, data)

    times.append(data.time)

    positions.append(data.geom('zakladna').xpos.copy())  # poloha kvadrokoptery
    angles.append(roll_pitch_calculation(model, data))

    accel.append(sensor_data_by_name(model, data, "akcelerometr"))
    speed.append(sensor_data_by_name(model, data, "mereni rychlosti"))
    angspeed.append(sensor_data_by_name(model, data, "gyroskop"))
    force.append(sensor_data_by_name(model, data, "senzor sily"))
    torque.append(sensor_data_by_name(model, data, "senzor momentu"))
    z_distance.append(sensor_data_by_name(model, data, "senzor vzdalenosti"))

    # ==============================Program konec=======================================================================

    # mj_step can be replaced with code that also evaluates
    # a policy and applies a control signal before stepping the physics.
    mj.mj_step(model, data)

    # Pick up changes to the physics state, apply perturbations, update options from GUI.
    viewer.sync()

    # Rudimentary time keeping, will drift relative to wall clock.
    time_until_next_step = dt - (time.time() - step_start)
    if time_until_next_step > 0:
        time.sleep(time_until_next_step/10)
# =======================================KONEC CYKLUS===================================================================

# porovnani casu konani programu a casu v simulaci
print("Real time:", round(time.time() - start, 2))
print("Data.time:", round(data.time, 2), ", dt:", dt)

# data z PID
plt.figure()
pid_out = np.array(pid_out)
plt.plot(times, pid_out, label=['F_cmd', 'phi_desired', 'angle_cmd'])
plt.title('PIDs outputs')
plt.legend()
plt.show()

# poloha
plt.figure()
positions = np.array(positions)
plt.plot(times, positions, label=['x', 'y', 'z'])
plt.title('Object Position Over Time')
plt.legend()
plt.show()
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
plt.figure()
accel = np.array(accel)
plt.plot(times, accel, label=["ax", "ay", "az"])
plt.title("Akcelerometr")
plt.legend()
plt.show()
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