import time
import mujoco as mj
import socket  # TCP communication
import json  # To convert Python dictionary into a friendly format
import numpy as np
import imageio  # 📌 Для записи видео
import os

# ===========================================POMOCNE FUNKCE=============================================================
def print_cam_param(permit, camera):
    if permit:
        print('cam.azimuth =', camera.azimuth, 'cam.elevation =', camera.elevation, 'cam.distance =', camera.distance)
        print('cam.lookat = [', camera.lookat[0], ',', camera.lookat[1], ',', camera.lookat[2], ']')


def sensor_data_by_name(mj_model, mj_data, sensor_name):
    sensor_id = mj.mj_name2id(mj_model, mj.mjtObj.mjOBJ_SENSOR, sensor_name)
    sensor_adr = mj_model.sensor_adr[sensor_id]
    sensor_dim = mj_model.sensor_dim[sensor_id]
    return mj_data.sensordata[sensor_adr:sensor_adr + sensor_dim].copy()


def update_camera(cam, data):
    """Автоматическое сопровождение камеры за дроном"""
    dron_pos = data.body('quadcopter').xpos.copy()

    cam.lookat[:] = dron_pos

    t = data.time
    # Пример камеры сбоку и чуть сверху
    cam.azimuth = (t * 20) % 360 - 107.42  # Вращение вокруг оси Z (в градусах), вращение 20°/сек
    # cam.elevation = -20     # Угол сверху вниз
    # cam.distance = 4.0      # Расстояние от объекта

# ========================================KONEC POMOCNE FUNKCE==========================================================


# ==============================================SETTINGS================================================================
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind(('localhost', 65432))
server_socket.listen(1)
print("Waiting for connection with MATLAB...")
client_socket, addr = server_socket.accept()
print(f"Connected to {addr}")

get = client_socket.recv(1024).decode('utf-8')
if get == 'Hello':
    print('Matlab: ' + get)
    send = 'Ahoj'
    time.sleep(0.05)
    client_socket.sendall(send.encode('utf-8'))

# MuJoCo settings
xml_path = 'model_quadcopter_v2.xml'
model = mj.MjModel.from_xml_path(xml_path)
data = mj.MjData(model)

# 📌 Создание рендера без GUI
renderer = mj.Renderer(model, width=640, height=480)  # рендер без графического интерфейса
mj.mj_forward(model, data)     # начальное состояние сцены

# 📌 Настройка камеры вручную (как было раньше)
scene_option = mj.MjvOption()
cam = mj.MjvCamera()
cam.azimuth = -107.42
cam.elevation = -47.15
cam.distance = 5.16
cam.lookat = [-0.0049, 0.4150, 2.1315]

# 📌 Создание директории для кадров и writer для видео
video_filename = "simulation_test3.mp4"
fps = int(1 / model.opt.timestep)
writer = imageio.get_writer(video_filename, fps=fps, codec='libx264', bitrate='2500k')

# ------------------------------------------Simulation setup------------------------------------------------------------
simtime = 10
timestep = str(model.opt.timestep)

timeData = {"SimTime": simtime, "TimeStep": timestep}
client_socket.sendall(json.dumps(timeData).encode('utf-8'))
time.sleep(1)

print("Total simulation time: " + str(simtime) + " s")
print("Model time step: " + str(timestep) + " s")

# ======================================================================================================================


# ==========================================MAIN PROGRAM================================================================
data.ctrl[0:3 + 1] = (3 * 9.81) / 4 / 0.0000093

try:
    while data.time < simtime + model.opt.timestep:
        # Send data to MATLAB
        data_to_send = {
            "SimulationTime": data.time,
            "DronPos": data.body('quadcopter').xpos.tolist(),
            "PendPos": data.geom('point_mass').xpos.tolist(),
            "DronRotM": data.body('quadcopter').xmat.tolist(),
            "PendRotM": data.geom('point_mass').xmat.tolist(),
            "imuAccel": sensor_data_by_name(model, data, 'akcelerometr').tolist(),
            "imuGyro": sensor_data_by_name(model, data, 'gyroskop').tolist(),
            "imuMag": sensor_data_by_name(model, data, 'magnetometr').tolist()
        }
        json_data_to_send = json.dumps(data_to_send)
        client_socket.sendall(json_data_to_send.encode('utf-8'))

        # Receive from MATLAB
        get = client_socket.recv(1024)
        if get:
            json_str = json.loads(get.decode('utf-8'))
            m_square = json_str['Rotor_AngVel_square']
            data.ctrl = [m_square[0], m_square[1], m_square[2], m_square[3]]

            # Step simulation
            mj.mj_step(model, data)

            update_camera(cam, data)  # 📌 автообновление камеры
            # 📌 Обновление рендера и получение кадра
            renderer.update_scene(data, camera=cam, scene_option=scene_option)
            frame = renderer.render()
            writer.append_data(frame)  # 📌 Добавляем кадр в видео

except Exception as e:
    print(f"Error: {e}")

client_socket.close()
server_socket.close()

writer.close()  # 📌 Закрываем файл видео после окончания симуляции
print("Simulation complete. Video saved as:", video_filename)
# ========================================END PROGRAM===================================================================
