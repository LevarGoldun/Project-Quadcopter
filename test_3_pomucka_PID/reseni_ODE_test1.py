import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from simple_pid import PID

# !!! Modelování jednoduchého systému pomocí PID regulátoru z knihovny simple_pid a řešiče solve_ivp !!!

# Objekt regulátor
pid = PID(49, 26.1, 7.6, setpoint=2, sample_time=None)

# Definice soustavy dif. rovnic jako funkce
def dSdx(t, S):
    x1, x2 = S
    u = pid(x1, dt=1e-3)
    # Předběžným řešením je, že při volání regulátoru zadám parametr
    # dt - pokud je nastaven, použije se tato hodnota pro časový krok místo reálného času.
    # PŘESTOŽE REGULÁTOR FUNGUJE, VÝSTUPNÍ HODNOTY NEJSOU ZCELA SPRÁVNÉ/POROVNATELNÉ S MATLABEM.

    x1_dot = x2
    x2_dot = -3*x2 + 5*x1 + u
    return [x1_dot, x2_dot]


# Simulace
final_time = 2
dt = 1e-3
t_span = (0, final_time)  # Simulation time (seconds) [from, to]
# Generation of time points with step dt (the points where we want to see a solution)
time_points = np.arange(0, final_time + dt, dt)

S0 = [0, 0]  # poč. podm.
sol = solve_ivp(dSdx, t_span, S0, t_eval=time_points)

# Plot
plt.plot(sol.t, sol.y[0])
plt.show()

