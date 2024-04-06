import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp

# !!! Modelování jednoduchého systému pomocí PID regulátoru jako uživatelská funkce controller()
# a řešiče solve_ivp ALE metodou RK23 !!!


# zdroj https://softinery.com/blog/implementation-of-pid-controller-in-python/
def controller(Kp, Ki, Kd, setpoint, measurement, time):
    global integral, time_prev, e_prev  # Value of offset - when the error is equal zero
    # PID calculations
    e = setpoint - measurement
    P = Kp * e
    integral = integral + Ki * e * (time - time_prev)
    D = Kd * (e - e_prev) / (time - time_prev)
    u = P + integral + D
    # update stored data for next iteration
    e_prev = e
    time_prev = time
    return u

def dSdx(t, S):
    global setpoint, time
    x1, x2 = S

    u = controller(49, 26.1, 7.6, setpoint, x1, t)

    x1_dot = x2
    x2_dot = -3*x2 + 5*x1 + u
    return [x1_dot, x2_dot]


# Global
integral = 0
time_prev = -1e-6
e_prev = 0
# Global end

# Simulation settings
final_time = 2
dt = 1e-3
t_span = (0, final_time)  # Simulation time (seconds) [from, to]
time_points = np.arange(0, final_time + dt, dt)  # Generation of time points with step dt

# setpoint
setpoint = 2

S0 = [0, 0]
sol = solve_ivp(dSdx, t_span, S0, t_eval=time_points, method='RK23')  # !!! Zde je jiná metoda než výchozí RK45 !!!


# Plot
plt.plot(sol.t, sol.y[0])
plt.grid(True)
plt.show()

