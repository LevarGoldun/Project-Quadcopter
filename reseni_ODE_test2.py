import numpy as np
import matplotlib.pyplot as plt
import scipy as sp
from scipy.integrate import odeint
from scipy.integrate import solve_ivp
from simple_pid import PID

# Reseni soustavy ODEs
if True:
    pid = PID(49, 26.1, 7.6, setpoint=2, sample_time=None)
    i = 0
    tt = [0]

    def dSdx(t, S, controller):
        x1, x2 = S
        #u = pid(x1, dt=1e-3)
        x1_dot = x2
        x2_dot = -3*x2 + 5*x1 + controller(x1, dt=1e-3)
        # НИКАКОЙ РАЗННИЦЫ В ПОВЕДЕНИИ СИМУЛЯЦИИ
        return [x1_dot, x2_dot]


    final_time = 10
    dt = 1e-3
    t_span = (0, final_time)  # Simulation time (seconds) [from, to]
    time_points = np.arange(0, final_time + dt, dt)  # Generation of time points with step dt

    S0 = [0, 0]
    sol = solve_ivp(dSdx, t_span, S0, args=(pid,), t_eval=time_points)
    # НИКАКОЙ РАЗНИЦЫ В ПОВЕДЕНИИ СИМУЛЯЦИИ

    # Plot
    plt.plot(sol.t, sol.y[0])
    plt.show()

