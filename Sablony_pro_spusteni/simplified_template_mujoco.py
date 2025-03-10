# Moje samblona pro spusteni okenka a simulaci, ma "ovaldaci panel".
# Nejsem profesionalni programator, takze tento kod muze byt hursi nez template_mujoco.py a nemet neco navic

import mujoco as mj
import mujoco.viewer  # p.s. high-level, more user-friendly and abstract interface
import time
import numpy as np

# xml_path = 'model_quadcopter_v1.2_example.xml'  # xml file (assumes this is in the same folder as this file)
xml_path = 'model_quadcopter_v2.xml'
simend = 300  # simulation time

model = mj.MjModel.from_xml_path(xml_path)  # MuJoCo model
data = mj.MjData(model)  # MuJoCo data

viewer = mujoco.viewer.launch_passive(model, data)

start = time.time()

# ======================================Data pro drobne deje v Matlab===================================================
nv = len(data.qvel)
M = np.zeros((nv, nv))
mj.mj_fullM(model, M, data.qM)  # matice hmotnosti a setrvacnosti
print("Matice hmotnosti a setrvacnosti:")
print(M)

# pocitam delku od motoru 4 do motoru 2 (vzdalenost 2*L dle Simulink)
left_position = data.site('thrust1').xpos[1]
right_position = data.site('thrust2').xpos[1]
print("Polovicni delka kvadr.", abs(left_position-right_position)/2)
print(left_position)
# -> je symetricka s delkou 0.2051
# ======================================================================================================================

# Close the viewer automatically after simend wall-seconds.
while viewer.is_running() and data.time < simend:
    step_start = time.time()

    # mj_step can be replaced with code that also evaluates
    # a policy and applies a control signal before stepping the physics.
    mj.mj_step(model, data)

    # Example modification of a viewer option: toggle contact points every two seconds.
    # with viewer.lock():
    #     viewer.opt.flags[mujoco.mjtVisFlag.mjVIS_CONTACTPOINT] = int(data.time % 2)

    # Pick up changes to the physics state, apply perturbations, update options from GUI.
    viewer.sync()

    #Rudimentary time keeping, will drift relative to wall clock.
    time_until_next_step = model.opt.timestep - (time.time() - step_start)
    if time_until_next_step > 0:
        time.sleep(time_until_next_step)


# porovnani casu konani programu a casu v simulaci
print("Real time", time.time() - start)
print("Data.time", data.time)

