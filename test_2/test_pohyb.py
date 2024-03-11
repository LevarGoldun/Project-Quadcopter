import time
import mujoco as mj
import mujoco.viewer
import numpy as np
import matplotlib.pyplot as plt

xml_path = 'model_quadcopter_v1.2.xml'

model = mj.MjModel.from_xml_path(xml_path)  # MuJoCo model
data = mj.MjData(model)  # MuJoCo data


def up_down(model_data):
    if int(model_data.time % 3):
        model_data.ctrl = [9, 9, 9, 9]
    else:
        model_data.ctrl = [5, 5, 5, 5]


def forward_backward(model_data):
    if int(model_data.time % 2):
        model_data.ctrl = [7, 7, 9, 9]
    else:
        model_data.ctrl = [9, 9, 7, 7]


def left_right(model_data):
    if int(model_data.time % 3):
        model_data.ctrl = [7.5, 8, 7.5, 8]
    else:
        model_data.ctrl = [8, 7.5, 8, 7.5]


def rot_left_right(model_data):
    if int(model_data.time % 3):
        model_data.ctrl = [7.5, 8, 8, 7.5]
    else:
        model_data.ctrl = [8, 7.5, 7.5, 8]


# positions = []

with mujoco.viewer.launch_passive(model, data) as viewer:
    # Close the viewer automatically after 30 wall-seconds.
    start = time.time()

    while viewer.is_running() and time.time() - start < 30:
        step_start = time.time()

        # positions.append(data.body('kvadrokoptera').xpos.copy())

        # mj_step can be replaced with code that also evaluates
        # a policy and applies a control signal before stepping the physics.
        mujoco.mj_step(model, data)

        with viewer.lock():
            #up_down(data)
            #forward_backward(data)
            #left_right(data)
            rot_left_right(data)

        # Pick up changes to the physics state, apply perturbations, update options from GUI.
        viewer.sync()

        # Rudimentary time keeping, will drift relative to wall clock.

        time_until_next_step = model.opt.timestep - (time.time() - step_start)
        if time_until_next_step > 0:
            time.sleep(time_until_next_step)

"""
positions = np.array(positions)

# Object Position
plt.plot(positions[:, 0], label='X position')
plt.plot(positions[:, 1], label='Y position')
plt.plot(positions[:, 2], label='Z position')
plt.xlabel('Time Step')
plt.ylabel('Position')
plt.title('Object Position Over Time')
plt.legend()
plt.show()
"""
