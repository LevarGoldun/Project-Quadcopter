import time
import mujoco as mj
import socket  # TCP communication
import json  # To convert Python dictionary into a friendly format
import numpy as np
import imageio  # 📌 To record video
from PIL import Image, ImageDraw, ImageFont  # 📌 For drawing text over frames

# Plot
import matplotlib.pyplot as plt
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas


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
    # cam.azimuth = (t * 20) % 360 - 107.42  # Вращение вокруг оси Z (в градусах), вращение 20°/сек
    # cam.elevation = -20     # Угол сверху вниз
    # cam.distance = 4.0      # Расстояние от объекта


def draw_overlay_text(frame_np, sim_time, drone_pos, motor_values):
    """Добавляет текст (время и обороты) поверх кадра"""
    img = Image.fromarray(frame_np)
    draw = ImageDraw.Draw(img)

    # Строки для отображения
    time_str = f"Time: {sim_time:5.2f} s"  # time
    pos_str = "Drone pos: [" + ", ".join(f"{coord:5.2f}" for coord in drone_pos) + "] m"  # drone position
    motor_str = "Motors: [" + ", ".join(f"{int(v):>4}" for v in np.sqrt(motor_values)) + "] rad/s"  # motor rad/s

    # Тёмный прямоугольник с прозрачностью (эмулируем стиль MuJoCo)
    # overlay_color = (50, 0, 50, 180)  # темный пурпурный, semi-transparent
    # text_box_width = 420
    # text_box_height = 50
    # draw.rectangle([0, 0, text_box_width, text_box_height], fill=overlay_color)

    # Белый текст
    text_color = (255, 255, 255)

    # Отображение текста на кадре
    draw.text((10, 5), time_str, fill=text_color, font=font)
    draw.text((10, 30), pos_str, fill=text_color, font=font)
    draw.text((10, 55), motor_str, fill=text_color, font=font)

    return np.array(img)


# def init_plot(ax, title, xlim, ylim, labels):
#     """
#     Инициализация одного графика.
#     ax      - ось matplotlib
#     title   - заголовок
#     xlim    - (xmin, xmax)
#     ylim    - (ymin, ymax)
#     labels  - список подписей линий
#     """
#     ax.set_xlim(*xlim)
#     ax.set_ylim(*ylim)
#     ax.set_title(title)
#
#     lines = []
#     for label in labels:
#         line, = ax.plot([], [], label=label)
#         lines.append(line)
#     ax.legend()
#     return lines


def update_plot(lines, time_hist, data_hists):
    """
    Обновление линий на графике.
    lines      - список Line2D (из init_plot)
    time_hist  - список времени
    data_hists - список списков значений (по одному для каждой линии)
    """
    for line, values in zip(lines, data_hists):
        line.set_data(time_hist, values)


def combine_side_by_side(frame_left, fig, canvas, ratio, total_size=(1280, 720), ):
    target_w, target_h = total_size
    mujoco_w = int(target_w * ratio)
    plot_w = target_w - mujoco_w

    # --- Получаем картинку из matplotlib ---
    canvas.draw()
    plot_image = np.frombuffer(canvas.buffer_rgba(), dtype=np.uint8)
    plot_image = plot_image.reshape(fig.canvas.get_width_height()[::-1] + (4,))[:, :, :3]

    # --- График приводим к нужному размеру ---
    img_plot = Image.fromarray(plot_image)
    img_plot = img_plot.resize((plot_w, target_h), Image.LANCZOS)
    frame_plot_resized = np.array(img_plot)

    # --- Создаём холст ---
    combined = np.zeros((target_h, target_w, 3), dtype=np.uint8)
    combined[:, :mujoco_w, :] = frame_left      # тут без ресайза
    combined[:, mujoco_w:, :] = frame_plot_resized

    return combined

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
# размеры для MuJoCo
total_w, total_h = 1280, 720
ratio = 0.5
mujoco_w = int(total_w * ratio)
plot_w = total_w - mujoco_w

renderer = mj.Renderer(model, width=mujoco_w, height=total_h)  # рендер без графического интерфейса
mj.mj_forward(model, data)     # начальное состояние сцены
font = ImageFont.truetype("consola.ttf", 20)  # шрифт

# 📌 Настройка камеры вручную (как было раньше)
scene_option = mj.MjvOption()
scene_option.frame = mj.mjtFrame.mjFRAME_WORLD  # отображение мировых координат
cam = mj.MjvCamera()
cam.azimuth = -107.42
cam.elevation = -47.15
cam.distance = 5.16
cam.lookat = [-0.0049, 0.4150, 2.1315]

# 📌 Создание директории для кадров и writer для видео
video_filename = "sim_kaskadova_refZ_PD.mp4"
# fps = int(1 / model.opt.timestep)
fps = int(60)
writer = imageio.get_writer(video_filename, fps=fps, codec='libx264', bitrate='5000k')

# ------------------------------------------Simulation setup------------------------------------------------------------
simtime = 20
timestep = str(model.opt.timestep)

steps_per_frame = int(1 / model.opt.timestep / fps)  # к-во шагов симуляции на 60 кадров/с
frame_step_counter = 0  # счетчик шагов симуляции

timeData = {"SimTime": simtime, "TimeStep": timestep}
client_socket.sendall(json.dumps(timeData).encode('utf-8'))
time.sleep(1)

print("Total simulation time: " + str(simtime) + " s")
print("Model time step: " + str(timestep) + " s")

# ======================================================================================================================


# ==========================================MAIN PROGRAM================================================================
data.ctrl[0:3 + 1] = (3 * 9.81) / 4 / 0.0000093

# plot init
dpi = 100
figsize = (plot_w / dpi, total_h / dpi)
# fig, axs = plt.subplots(4, 1, figsize=figsize, dpi=dpi, sharex=True)
fig, axs = plt.subplots(4, 1, figsize=figsize, dpi=dpi, sharex=True, constrained_layout=True)
# fig, axs = plt.subplots(4, 1, figsize=figsize, dpi=dpi, sharex=True)
# # Оставляем справа место под легенды
# fig.subplots_adjust(right=0.8)  # <- графики занимают 80% ширины, справа 20% под легенду
canvas = FigureCanvas(fig)

# >>>> новый код: делаем компактные графики
for ax in axs:
    ax.label_outer()         # скрыть дубли осей
    ax.tick_params(labelsize=8)
    ax.grid(True, alpha=0.3)
# plt.tight_layout(pad=2.0)    # равномерное распределение
# <<<<

# ------plot create----------
# --- 1. Позиция ---
axs[0].set_xlim(0, simtime)
axs[0].set_ylim(-4, 10)
axs[0].set_autoscaley_on(True)  # автолимит с запасом
axs[0].margins(y=0.1)       # 10% запаса сверху/снизу
axs[0].grid(True)
axs[0].set_title("Poloha dronu [m]")

lines_pos = []
colors_pos = ["red", "green", "blue"]
for label, color in zip(["x", "y", "z"], colors_pos):
    # основная линия
    line_actual, = axs[0].plot([], [], label=label, color=color)
    # желаемые положения
    line_ref, = axs[0].plot([], [], label=f"{label}_ref", color=color, linestyle="--", linewidth=0.8)
    # сохранение линий
    lines_pos.append(line_actual)
    lines_pos.append(line_ref)
axs[0].legend(fontsize=10, loc='center left', bbox_to_anchor=(1.0, 0.5), frameon=False)

# --- 2. Углы ---
axs[1].set_xlim(0, simtime)
axs[1].set_ylim(-30, 30)
axs[1].set_autoscaley_on(True)   # автоподстройка
axs[1].margins(y=0.1)            # 10% запаса
axs[1].grid(True)
axs[1].set_title("Orientace dronu [deg]")
lines_rpy = []
colors_rpy = ["red", "green", "blue"]
for label, color in zip(["roll", "pitch", "yaw"], colors_rpy):
    line, = axs[1].plot([], [], label=label, color=color)
    lines_rpy.append(line)
axs[1].legend(fontsize=10, loc='center left', bbox_to_anchor=(1.0, 0.5), frameon=False)
# axs[1].legend(fontsize=8, loc='upper left', frameon=False)

# --- 3. Углы груза---
axs[2].set_xlim(0, simtime)
axs[2].set_ylim(-45, 45)
axs[2].set_autoscaley_on(True)
axs[2].margins(y=0.1)
axs[2].grid(True)
axs[2].set_title("Vychýlení závaží [deg]")
lines_alphabeta = []
color_alphabeta = ["red", "green"]
for label, color in zip(["alpha", "beta"], color_alphabeta):
    line, = axs[2].plot([], [], label=label, color=color)
    lines_alphabeta.append(line)
axs[2].legend(fontsize=10, loc='center left', bbox_to_anchor=(1.0, 0.5), frameon=False)
# axs[2].legend(fontsize=8, loc='upper left', frameon=False)

# --- 4. Моторы ---
axs[3].set_xlim(0, simtime)
axs[3].set_ylim(0, 2000)
axs[3].set_autoscaley_on(True)
axs[3].margins(y=0.1)
axs[3].grid(True)
axs[3].set_title("Otáčky motorů [rad/s]")
axs[3].set_xlabel("Čas [s]")
lines_mot = []
for label in ["m1", "m2", "m3", "m4"]:
    line, = axs[3].plot([], [], label=label)
    lines_mot.append(line)
axs[3].legend(fontsize=10, loc='center left', bbox_to_anchor=(1.0, 0.5), frameon=False)
# axs[3].legend(fontsize=8, loc='upper left', frameon=False)

# --- массивы данных ---
time_hist = []
x_hist, y_hist, z_hist = [], [], []
x_ref_hist, y_ref_hist, z_ref_hist = [], [], []
roll_hist, pitch_hist, yaw_hist = [], [], []
alpha_hist, beta_hist = [], []
m1_hist, m2_hist, m3_hist, m4_hist = [], [], [], []

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

        update_camera(cam, data)  # 📌 автообновление камеры
        # 📌 Сохраняем кадр с камеры каждые steps_per_frame шагов
        frame_step_counter += 1
        if frame_step_counter >= steps_per_frame:
            frame_step_counter = 0  # сброс
            # 📌 Обновление рендера и получение кадра
            renderer.update_scene(data, camera=cam, scene_option=scene_option)
            frame = renderer.render()
            # 📌 Добавим текстовую информацию в кадр
            frame = draw_overlay_text(frame, data.time, data.body('quadcopter').xpos, data.ctrl)
            combined_frame = combine_side_by_side(frame, fig, canvas, ratio, total_size=(1280, 720))  # объединение
            writer.append_data(combined_frame)  # 📌 Добавляем кадр в видео

        # Receive from MATLAB
        get = client_socket.recv(1024)
        if get:
            json_str = json.loads(get.decode('utf-8'))
            m_square = json_str['Rotor_AngVel_square']
            data.ctrl = [m_square[0], m_square[1], m_square[2], m_square[3]]

            dron_angles = json_str['dron_angles']
            pend_angles = json_str['pend_angles']
            ref_xyz = json_str['ref_xyz']

            # Array and plot update
            # -из-за того что я углы и другие вещи рассчитываю в Симулинке, я должен их послать обратно
            # -до mj_step обновляю графики, тогда это будет еще тот же шаг

            time_hist.append(data.time)
            # положение квадрокоптера
            x_hist.append(data.body('quadcopter').xpos[0])
            y_hist.append(data.body('quadcopter').xpos[1])
            z_hist.append(data.body('quadcopter').xpos[2])

            x_ref_hist.append(ref_xyz[0])
            y_ref_hist.append(ref_xyz[1])
            z_ref_hist.append(ref_xyz[2])

            # ориентация квадрокоптера
            roll_hist.append(dron_angles[0])
            pitch_hist.append(dron_angles[1])
            yaw_hist.append(dron_angles[2])

            # отклонение груза
            alpha_hist.append(pend_angles[0])
            beta_hist.append(pend_angles[1])

            # обороты двигателей
            m1_hist.append(np.sqrt(m_square[0]))
            m2_hist.append(np.sqrt(m_square[1]))
            m3_hist.append(np.sqrt(m_square[2]))
            m4_hist.append(np.sqrt(m_square[3]))

            # обновление графиков
            update_plot(lines_pos, time_hist, [x_hist, x_ref_hist, y_hist, y_ref_hist, z_hist, z_ref_hist])
            update_plot(lines_rpy, time_hist, [roll_hist, pitch_hist, yaw_hist])
            update_plot(lines_alphabeta, time_hist, [alpha_hist, beta_hist])
            update_plot(lines_mot, time_hist, [m1_hist, m2_hist, m3_hist, m4_hist])
            # пересчёт осей (чтобы не обрезало)
            for i in range(0, 3+1):
                axs[i].relim()
                axs[i].autoscale_view()

            # Step simulation
            mj.mj_step(model, data)

except Exception as e:
    print(f"Error: {e}")

client_socket.close()
server_socket.close()

writer.close()  # 📌 Закрываем файл видео после окончания симуляции
print("Simulation complete. Video saved as:", video_filename)
# ========================================END PROGRAM===================================================================
