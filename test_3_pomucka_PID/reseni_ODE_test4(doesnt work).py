import numpy as np
import matplotlib.pyplot as plt
import control as ct

# !!! Modelování jednoduchého systému přes knihovnu control (DOESN'T WORK) !!!

def dSdx(t, S, u):
    x1, x2 = S

    x1_dot = x2
    x2_dot = -3 * x2 + 5 * x1 + u

    return np.array([x1_dot, x2_dot])


# I/O systém pomocí dynamiky dSdx():
sys_io = ct.NonlinearIOSystem(dSdx, None, inputs='u', outputs=('x1', 'x2'), states=('x1', 'x2'), name='model_system')

# PID regulátor jako přenosová funkce (vic rovnice ze Simulink)
Kp = 49
Ki = 26.1
Kd = 7.6
pid_tf = ct.TransferFunction([Kd, Kp, Ki], [1, 0], name='control', inputs='e', outputs='u')

# URO
closed_loop = ct.InterconnectedSystem((pid_tf, sys_io), name='URO', connections=[
    ['control.e', '-model_system.x1'], ['model_system.u', 'control.u']], inputs='setpoint', outputs='x1')
print(closed_loop)


# Simulace
X0 = [25, 20]
T = np.linspace(0, 70, 500)

