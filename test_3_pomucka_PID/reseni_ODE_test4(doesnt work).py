import numpy as np
import matplotlib.pyplot as plt
import control as ct


# Начнем с определения динамики системы.
def dSdx(t, S, u):
    x1, x2 = S

    x1_dot = x2
    x2_dot = -3 * x2 + 5 * x1 + u

    return np.array([x1_dot, x2_dot])


# Теперь мы создаем систему ввода/вывода, используя динамику dSdx():
sys_io = ct.NonlinearIOSystem(dSdx, None, inputs='u', outputs=('x1', 'x2'), states=('x1', 'x2'), name='model_system')

# ПИД регулятор в виде transfer function (vic rovnice ze Simulink)
Kp = 49
Ki = 26.1
Kd = 7.6
pid_tf = ct.TransferFunction([Kd, Kp, Ki], [1, 0], name='control', inputs='e', outputs='u')

# Система управления с замкнутым контуром
closed_loop = ct.InterconnectedSystem((pid_tf, sys_io), name='URO', connections=[
    ['control.e', '-model_system.x1'], ['model_system.u', 'control.u']], inputs='setpoint', outputs='x1')

print(closed_loop)
# Теперь систему sys можно смоделировать
X0 = [25, 20]                 # Initial H, L
T = np.linspace(0, 70, 500)   # Simulation 70 years of time

# Simulate the system
#t, y = ct.input_output_response(io_predprey, T, 0, X0)

