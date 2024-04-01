import numpy as np
import matplotlib.pyplot as plt
import scipy as sp
from scipy.integrate import odeint
from scipy.integrate import solve_ivp
from simple_pid import PID

# !!! Modelování jednoduchého systému pomocí PID regulátoru z knihovny simple_pid a řešiče solve_ivp !!!

# Reseni soustavy ODEs
if True:
    pid = PID(49, 26.1, 7.6, setpoint=2, sample_time=None)

    def dSdx(t, S):
        x1, x2 = S
        u = pid(x1, dt=1e-3)
        # ПРЕДВАРИТЕЛЬНОЕ РЕШЕНИЕ В ТОМ, ЧТО ПРИ ВЫЗОВЕ РЕГУЛЯТОРА Я УКАЗЫВАЮ ПАРАМЕТР dt – если установлено,
        # используется это значение для временного шага вместо реального времени.
        # ХОТЬ РЕГУЛЯТОР И РАБОТАЕТ, Я ДУМАЮ ВЫХОДНЫЕ ЗНАЧЕНИЯ НЕ СОВСЕМ ВЕРНЫ/СОВПАДАЮТ ПО СРАВНЕНИЮ С МАТЛАБОМ

        x1_dot = x2
        x2_dot = -3*x2 + 5*x1 + u
        return [x1_dot, x2_dot]


    final_time = 2
    dt = 1e-3
    t_span = (0, final_time)  # Simulation time (seconds) [from, to]
    time_points = np.arange(0, final_time + dt, dt)  # Generation of time points with step dt

    S0 = [0, 0]
    sol = solve_ivp(dSdx, t_span, S0, t_eval=time_points)

    # Plot
    plt.plot(sol.t, sol.y[0])
    plt.show()

