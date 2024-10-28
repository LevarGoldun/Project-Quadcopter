import time
import mujoco as mj
import mujoco.viewer

import socket  # TCP communication
import select  # Are there any sockets
import json  # To convert Python dictionary into a friendly format

# Server settings
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind(('localhost', 65432))
server_socket.listen(1)
print("Waiting for connection with MATLAB...")
client_socket, addr = server_socket.accept()
print(f"Connected to {addr}")
# client_socket.setblocking(False)  # Set non-blocking mode -->  I have an idea for a blocking mode

# Test connection with Matlab
get = client_socket.recv(1024).decode('utf-8')  # Read
if get == 'Hello':
    print('Matlab: ' + get)
    send = 'Ahoj'
    client_socket.sendall(send.encode('utf-8'))  # Answer
    time.sleep(0.05)

# MuJoCo settings
xml_path = 'model_quadcopter_v1.xml'
model = mj.MjModel.from_xml_path(xml_path)  # MuJoCo model
data = mj.MjData(model)  # MuJoCo data

# ------------------------------------------SIMULATION SETUP------------------------------------------------------------
# Sending to MATLAB the simulation time step (from .xml file)
timestep = str(model.opt.timestep)
client_socket.sendall(timestep.encode('utf-8'))

# Getting the total simulation time from Matlab
simtime = int(client_socket.recv(1024).decode('utf-8'))
print("Simulation time: " + str(simtime) + " s")
print("Time step: " + str(timestep))
# ----------------------------------------------------------------------------------------------------------------------

# Initialization
# acknowledged = True
# last_time = time.time()

# ----------------------------------------MAIN PROGRAM------------------------------------------------------------------
with mujoco.viewer.launch_passive(model, data) as viewer:
    while True and viewer.is_running():
        with viewer.lock():
            get = client_socket.recv(1024).decode('utf-8')  # Read
            json_str = json.loads(get)
            # print(json_str['RandomText'])
            number = json_str['MotorSignal']
            # print(number)
            data.ctrl = [number, number, number, number]

            # Send data to MATLAB
            # Forming a data dictionary
            data_to_send = {
                "SimulationTime": data.time,
                "Number of position coordinates": model.nq,
                "Number of degrees of freedom": model.nv,
                "Nothing": 'Random text'
            }
            # Convert the dictionary to a JSON string
            json_data_to_send = json.dumps(data_to_send)
            client_socket.sendall(json_data_to_send.encode('utf-8'))

        # mj_step can be replaced with code that also evaluates
        # a policy and applies a control signal before stepping the physics.
        mujoco.mj_step(model, data)

        # Pick up changes to the physics state, apply perturbations, update options from GUI.
        viewer.sync()

server_socket.close()
print("End")
