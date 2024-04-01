import numpy as np
import matplotlib.pyplot as plt
import scipy as sp
from scipy.integrate import odeint
from scipy.integrate import solve_ivp
from simple_pid import PID

# !!! Modelování jednoduchého systému pomocí PID regulátoru z knihovny simple_pid nebo jako vnější funkce controller()
# a řešiče odeint, která vypočítá nové stavy systému na nějakém intervalu dt ve smyčce for !!!

# Reseni soustavy ODEs
if True:
    #pid = PID(49, 26.1, 7.6, setpoint=2, sample_time=None)

    # zdroj https://softinery.com/blog/implementation-of-pid-controller-in-python/
    def controller(Kp, Ki, Kd, setpoint, measurement):
        global time, integral, time_prev, e_prev  # Value of offset - when the error is equal zero
        offset = 320*0
        # PID calculations
        e = setpoint - measurement
        P = Kp * e
        integral = integral + Ki * e * (time - time_prev)
        D = Kd * (e - e_prev) / (time - time_prev)
        u = offset + P + integral + D
        # update stored data for next iteration
        e_prev = e
        #time_prev = time
        return u

    def dSdx(t, S, u):
        x1, x2 = S
        #u = pid(x1, dt=1e-3)

        x1_dot = x2
        x2_dot = -3*x2 + 5*x1 + u
        return [x1_dot, x2_dot]


    # Global
    integral = 0
    time_prev = -1e-6
    e_prev = 0
    # Global end

    final_time = 2
    dt = 1e-3
    y_sol = np.array([[0, 0]])
    t_sol = [time_prev]
    u_sol = [0]

    sim_time = np.arange(0, final_time, dt)

    # setpoint
    setpoint = 2


    # Simulation
    for time in sim_time:
        t_span = np.arange(time_prev, time, dt/5)
        u = controller(49, 26.1, 7.6, setpoint, y_sol[-1, 0])
        #u = pid(y_sol[-1, 0], dt=dt)
        # работает и так и так, только глобальные переменные нужны как раз для реализации ПИД через функцию...

        yi = odeint(dSdx, y_sol[-1, :], t_span, args=(u, ), tfirst=True)

        t_sol.append(time)
        y_sol = np.vstack((y_sol, yi[-1, :]))
        u_sol.append(u)
        time_prev = time

    # Plot
    plt.plot(t_sol, y_sol[:, 0])
    plt.grid(True)
    #plt.plot(t_sol, u_sol)
    plt.show()

