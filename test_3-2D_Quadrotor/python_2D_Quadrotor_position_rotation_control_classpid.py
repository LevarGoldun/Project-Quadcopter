# Zdroj https://cookierobotics.com/052/

from scipy.integrate import odeint
import matplotlib.pyplot as plt
import numpy as np


class PIDController:
    def __init__(self, Kp, Ki, Kd):
        self.Kp = Kp
        self.Ki = Ki
        self.Kd = Kd
        self.setpoint = 0
        self.measurement = 0
        self.time = 0
        self.integral = 0
        self.time_prev = -1e-6
        self.e_prev = 0

    def update(self, setpoint, measurement, time):
        # PID calculations
        self.time = time
        self.setpoint = setpoint
        self.measurement = measurement

        e = self.setpoint - self.measurement
        P = self.Kp * e
        self.integral += self.Ki * e * (self.time - self.time_prev)
        D = self.Kd * (e - self.e_prev) / (self.time - self.time_prev)
        u = P + self.integral + D
        # update stored data for next iteration
        self.e_prev = e
        self.time_prev = self.time

        return u


# Modelování větru, který vychyluje kvadrokoptéru ve vodorovném směru
# return: Síla (N)
def wind():
    return np.random.normal(0, 1) * 0.05 / 3 + 0.1


# Equation of motion
# dX/dt = f(t, X)
# t   : Current time (seconds), scalar
# X   : Current state, [x, y, phi, x_dot, y_dot, phi_dot] = [x1, x2, x3, x4, x5, x6], according to file ...control_2.slx
# return: First derivative of state, i.e. X_dot = [x1_dot, x2_dot, x3_dot, x4_dot, x5_dot, x6_dot]
def X_dot(t, X, F_cmd, angle_cmd, F_wind):
    F1 = F_cmd + angle_cmd
    F2 = F_cmd - angle_cmd

    x1_dot = X[4]
    x2_dot = X[5]
    x3_dot = X[6]
    x4_dot = (-(F1 + F2) * np.sin(X[3]) - k * X[4] + F_wind) / m
    x5_dot = ((F1 + F2) * np.cos(X[3]) - m * g - k * X[5]) / m
    x6_dot = (F2 - F1) * L / Ixx

    return [0, x1_dot, x2_dot, x3_dot, x4_dot, x5_dot, x6_dot]


# P.S. Číslování matic v Python začíná indexem 0. Aby se indexace shodovala se soubory Simulink,
# je nulový prvek matice X a X_dot v Python prostě nic, jen nulový prvek v libovolném okamžiku

# --------------------------------------------------Setting-------------------------------------------------------------

# Constants
g = 9.81  # Gravitational acceleration (m/s^2)
m = 0.5  # Mass (kg)
Ixx = 0.00025  # Mass moment of inertia (kg*m^2)
L = 0.086  # Arm length (m)
k = 0.1  # Viscous damping coefficient (kg/s)


final_time = 30
dt = 1e-3
time_prev = -1e-6

y_sol = np.array([[0, 0, 0, 0, 0, 0, 0]])  # Initial state [0, x0, y0, phi0, x_dot0, y_dot0, phidot0]
t_sol = [time_prev]

sim_time = np.arange(0, final_time + dt, dt)


# Požadovaná poloha ve 2D
x_desired = 0
y_desired = 0

# Matice pro záznam dat
F_wind_out = []
pid_F_cmd_out = []
pid_angle_cmd_out = []
pid_phi_desired_out = []

pid_F_cmd = PIDController(0.5071869524592, 0.08640841170504, 0.5666397829706)
pid_angle_cmd = PIDController(-0.100774081166777, -0.0834490802167096, -0.028941288066033)
pid_phi_desired = PIDController(-0.0200986598020869, -0.000346755744844904, -0.0220005563169977)

# --------------------------------------------------Start---------------------------------------------------------------
# Simulation
for time in sim_time:
    t_span = np.arange(time_prev, time, dt/5)

    F_cmd = pid_F_cmd.update(y_desired, y_sol[-1, 2], time)
    phi_desired = pid_phi_desired.update(x_desired, y_sol[-1, 1], time)
    angle_cmd = pid_angle_cmd.update(phi_desired, y_sol[-1, 3], time)
    F_wind = wind()

    yi = odeint(X_dot, y_sol[-1, :], t_span, args=(F_cmd, angle_cmd, F_wind), tfirst=True)

    t_sol.append(time)
    y_sol = np.vstack((y_sol, yi[-1, :]))
    time_prev = time

    F_wind_out.append(F_wind)
    pid_F_cmd_out.append(F_cmd)
    pid_angle_cmd_out.append(angle_cmd)
    pid_phi_desired_out.append(phi_desired)

# --------------------------------------------------Plot----------------------------------------------------------------
# Plot 1
fig, axs = plt.subplots(3, figsize=(8, 10))

axs[0].plot(t_sol, y_sol[:, 1])
axs[0].set_title('x(t)')

axs[1].plot(t_sol, y_sol[:, 2])
axs[1].set_title('y(t)')
axs[2].plot(t_sol, np.rad2deg(y_sol[:, 3]))
axs[2].set_title('phi(t)')

plt.subplots_adjust(hspace=0.5)
plt.show()

# Plot 2
#plt.plot(F_wind_out)
#plt.show()