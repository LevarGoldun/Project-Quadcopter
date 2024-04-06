# Zdroj https://cookierobotics.com/052/

from scipy.integrate import \
    solve_ivp  # This function numerically integrates a system of ordinary differential equations
import matplotlib.pyplot as plt
import numpy as np
from simple_pid import PID

# Constants
g = 9.81  # Gravitational acceleration (m/s^2)
m = 0.5  # Mass (kg)
Ixx = 0.00025  # Mass moment of inertia (kg*m^2)
L = 0.086  # Arm length (m)
k = 0.1  # Viscous damping coefficient (kg/s)


# Modelování větru, který vychyluje kvadrokoptéru ve vodorovném směru
# return: Síla (N)
def wind():
    return np.random.normal(0, 1) * 0.05 / 3 + 0.1


# Equation of motion
# dX/dt = f(t, X)
# t   : Current time (seconds), scalar
# X   : Current state, [x, y, phi, x_dot, y_dot, phi_dot] = [x1, x2, x3, x4, x5, x6], according to file ...control_2.slx
# return: First derivative of state, i.e. X_dot = [x1_dot, x2_dot, x3_dot, x4_dot, x5_dot, x6_dot]
def X_dot(t, X):
    global dt, F_wind_out, pid_F_cmd_out, pid_angle_cmd_out, pid_phi_desired_out  # pro záznam dát

    F_cmd = pid_F_cmd(X[2], dt=dt)
    phi_desired = pid_phi_desired(X[1], dt=dt)
    pid_angle_cmd.setpoint = phi_desired
    angle_cmd = pid_angle_cmd(X[3], dt=dt)

    F1 = F_cmd + angle_cmd
    F2 = F_cmd - angle_cmd
    F_wind = wind()

    x1_dot = X[4]
    x2_dot = X[5]
    x3_dot = X[6]
    x4_dot = (-(F1 + F2) * np.sin(X[3]) - k * X[4] + F_wind) / m
    x5_dot = ((F1 + F2) * np.cos(X[3]) - m * g - k * X[5]) / m
    x6_dot = (F2 - F1) * L / Ixx

    F_wind_out.append(F_wind)
    pid_F_cmd_out.append(F_cmd)
    pid_angle_cmd_out.append(angle_cmd)
    pid_phi_desired_out.append(phi_desired)

    return [0, x1_dot, x2_dot, x3_dot, x4_dot, x5_dot, x6_dot]


# P.S. Číslování matic v Python začíná indexem 0. Aby se indexace shodovala se soubory Simulink,
# je nulový prvek matice X a X_dot v Python prostě nic, jen nulový prvek v libovolném okamžiku

# --------------------------------------------------Start---------------------------------------------------------------
final_time = 30
dt = 1e-3

t_span = (0, final_time)  # Simulation time (seconds) [from, to]
time_points = np.arange(0, final_time + dt, dt)  # Generation of time points with step dt
X0 = [0, 0, 0, 0, 0, 0, 0]  # Initial state [0, x0, y0, phi0, x_dot0, y_dot0, phidot0]

# Požadovaná poloha ve 2D
x_desired = 0
y_desired = 0

# Nastaveni PID regulatorů
# PID pro nastavení výšky y
pid_F_cmd = PID(0.507186952459298, 0.0864084117050425, 0.566639782970635, setpoint=y_desired, sample_time=None)
# PID pro nastavení úhlu phi
pid_angle_cmd = PID(-0.100774081166777, -0.0834490802167096, -0.028941288066033, setpoint=0, sample_time=None)
# PID pro nastavení požadovaného úhlu phi (kaskádové řízení)
pid_phi_desired = PID(-0.0200986598020869, -0.000346755744844904, -0.0220005563169977, setpoint=x_desired, sample_time=None)

# Matice pro záznam dat
F_wind_out = []
pid_F_cmd_out = []
pid_angle_cmd_out = []
pid_phi_desired_out = []

# Solve for the states, X(t) = [0, x(t), y(t), phi(t), x_dot(t), y_dot(t), phidot(t)]
sol = solve_ivp(X_dot, t_span, X0, t_eval=time_points)


# --------------------------------------------------Plot----------------------------------------------------------------
# Plot 1
fig, axs = plt.subplots(3, figsize=(8, 10))

axs[0].plot(sol.t, sol.y[1])
axs[0].set_title('x(t) [m]')
axs[1].plot(sol.t, sol.y[2])
axs[1].set_title('y(t) [m]')
axs[2].plot(sol.t, np.rad2deg(sol.y[3]))
axs[2].set_title('phi(t) [deg]')

plt.subplots_adjust(hspace=0.5)
plt.show()

# Plot 2
#plt.plot(F_wind_out)
#plt.show()
