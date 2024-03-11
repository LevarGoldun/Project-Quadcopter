import time
import mujoco as mj
import mujoco.viewer
import numpy as np
import matplotlib.pyplot as plt


xml_path = 'model_quadcopter_v1.xml'

model = mj.MjModel.from_xml_path(xml_path)  # MuJoCo model
data = mj.MjData(model)  # MuJoCo data


positions = []

with mujoco.viewer.launch_passive(model, data) as viewer:
    # Close the viewer automatically after 30 wall-seconds.
    start = time.time()

    while viewer.is_running() and time.time() - start < 30:
        step_start = time.time()

        positions.append(data.body('kvadrokoptera').xpos.copy())

        # mj_step can be replaced with code that also evaluates
        # a policy and applies a control signal before stepping the physics.
        mujoco.mj_step(model, data)

        # Example modification of a viewer option: toggle contact points every two seconds.
        with viewer.lock():
            viewer.opt.flags[mujoco.mjtVisFlag.mjVIS_CONTACTPOINT] = int(data.time % 2)
            if int(data.time % 2):
                data.ctrl = [10, 10, 10, 10]
            else:
                data.ctrl = [5, 5, 5, 5]

        # Pick up changes to the physics state, apply perturbations, update options from GUI.
        viewer.sync()

        # Rudimentary time keeping, will drift relative to wall clock.

        time_until_next_step = model.opt.timestep - (time.time() - step_start)
        if time_until_next_step > 0:
            time.sleep(time_until_next_step)


# Преобразование списка позиций в массив numpy

positions = np.array(positions)

# Построение графика позиций объекта
plt.plot(positions[:, 0], label='X position')
plt.plot(positions[:, 1], label='Y position')
plt.plot(positions[:, 2], label='Z position')
plt.xlabel('Time Step')
plt.ylabel('Position')
plt.title('Object Position Over Time')
plt.legend()
plt.show()

