% 28.08.2025
% Kod pro vytvoreni normalnich obrazku pro DP
% ze simulace MuJoCo (vsechny)
close all

% nahravani
load('CascadePID\out_kaskadova_trajektorie.mat')
load('PolePlacement\out_stavova_trajektorie_smo.mat')
load('PolePlacement\out_stavova_trajektorie_agr.mat')
load('LQR\out_LQR_trajektorie_poloha.mat')
load('LQR\out_LQR_trajektorie_palivo.mat')


% kaskadova
t_kas = out_kaskadova.tout;
dpos_kas = out_kaskadova.dron_pos.Data(:,:);
dang_kas = rad2deg(out_kaskadova.dron_angles.Data(:,:)');
pang_kas = rad2deg(out_kaskadova.pend_angles.Data(:,:)');
u_kas = out_kaskadova.sily.Data(:,:); % 1-sila, 2,3,4 - momenty
w_kas = sqrt(out_kaskadova.Rotor_AngVel_square');

% stavova smo
t_stav_smo = out_stavova_smo.tout;
dpos_stav_smo = out_stavova_smo.dron_pos.Data(:,:);
dang_stav_smo = rad2deg(out_stavova_smo.dron_angles.Data(:,:)');
pang_stav_smo = rad2deg(out_stavova_smo.pend_angles.Data(:,:)');
u_stav_smo = out_stavova_smo.sily.Data(:,:);
w_stav_smo = sqrt(reshape(permute(out_stavova_smo.Rotor_AngVel_square, [1 3 2]), 4, 10001));

% stavova agr
t_stav_agr = out_stavova_agr.tout;
dpos_stav_agr = out_stavova_agr.dron_pos.Data(:,:);
dang_stav_agr = rad2deg(out_stavova_agr.dron_angles.Data(:,:)');
pang_stav_agr = rad2deg(out_stavova_agr.pend_angles.Data(:,:)');
u_stav_agr = out_stavova_agr.sily.Data(:,:); 
w_stav_agr = sqrt(reshape(permute(out_stavova_agr.Rotor_AngVel_square, [1 3 2]), 4, 10001));

% LQR poloha (1)
t_lqr1 = out_LQR_poloha.tout;
dpos_lqr1 = out_LQR_poloha.dron_pos.Data(:,:);
dang_lqr1 = rad2deg(out_LQR_poloha.dron_angles.Data(:,:)');
pang_lqr1 = rad2deg(out_LQR_poloha.pend_angles.Data(:,:)');
u_lqr1 = out_LQR_poloha.sily.Data(:,:)'; 
w_lqr1 = sqrt(reshape(permute(out_LQR_poloha.Rotor_AngVel_square, [1 3 2]), 4, 10001));

% LQR palivo (2)
t_lqr2 = out_LQR_palivo.tout;
dpos_lqr2 = out_LQR_palivo.dron_pos.Data(:,:);
dang_lqr2 = rad2deg(out_LQR_palivo.dron_angles.Data(:,:)');
pang_lqr2 = rad2deg(out_LQR_palivo.pend_angles.Data(:,:)');
u_lqr2 = out_LQR_palivo.sily.Data(:,:)'; 
w_lqr2 = sqrt(reshape(permute(out_LQR_palivo.Rotor_AngVel_square, [1 3 2]), 4, 10001));

% referencni poloha (pro vsechny je stejna)
ref = out_kaskadova.ref.Data(:,:);
%%
% Font size
fs = 12; % velikost pismen popisujici osy
legs = 10; % velikost pismen v legend

line_width = 1.5; % tloustka krivek
ref_line_width = 1.2; % tloustka referencnich krivek
axis_width = 1.5; % tlouska krivek os

axis_font_size = 11; % velikost pismen pro cisla na osach

% Rozmer figure pro Word
width_cm = 16.5;
height_cm = 7.5;

% Cesta ke slozce
% script_path = fileparts(mfilename('fullpath'));
% folder_path = fullfile(script_path, 'Obrazky');


%%
% Poloha koptery-----------------------------------------------------------
% X
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(t_kas, dpos_kas(1,:), 'r', 'LineWidth', line_width);
plot(t_stav_smo, dpos_stav_smo(1,:), 'g', 'LineWidth', line_width);
plot(t_stav_agr, dpos_stav_agr(1,:), 'b', 'LineWidth', line_width);
plot(t_lqr1, dpos_lqr1(1,:), 'm', 'LineWidth', line_width);
plot(t_lqr2, dpos_lqr2(1,:), 'y', 'LineWidth', line_width);

plot(t_kas, ref(1,:), 'k--', 'LineWidth', ref_line_width)

ylabel('{\it x} [m]', 'FontSize', fs, 'FontName', 'Times New Roman');
% ylim([-0.2, 1.2])
% xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
legend({'PID+ZV', 'PP1', 'PP2', 'LQR1', 'LQR2', '{\it x}_{ref}'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman', ...
    'Location', 'best', NumColumns=2);
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('Obrazky/', 'mujoco_x_all.svg'), 'svg');

% Y
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(t_kas, dpos_kas(2,:), 'r', 'LineWidth', line_width);
plot(t_stav_smo, dpos_stav_smo(2,:), 'g', 'LineWidth', line_width);
plot(t_stav_agr, dpos_stav_agr(2,:), 'b', 'LineWidth', line_width);
plot(t_lqr1, dpos_lqr1(2,:), 'm', 'LineWidth', line_width);
plot(t_lqr2, dpos_lqr2(2,:), 'y', 'LineWidth', line_width);
plot(t_kas, ref(2,:), 'k--', 'LineWidth', ref_line_width)

ylabel('{\it y} [m]', 'FontSize', fs, 'FontName', 'Times New Roman');
% ylim([-0.5, 2.5])
legend({'PID+ZV', 'PP1', 'PP2', 'LQR1', 'LQR2', '{\it y}_{ref}'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman', ...
    'Location', 'best', NumColumns=2);
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('Obrazky/', 'mujoco_y_all.svg'), 'svg');

% Z
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(t_kas, dpos_kas(3,:), 'r', 'LineWidth', line_width);
plot(t_stav_smo, dpos_stav_smo(3,:), 'g', 'LineWidth', line_width);
plot(t_stav_agr, dpos_stav_agr(3,:), 'b', 'LineWidth', line_width);
plot(t_lqr1, dpos_lqr1(3,:), 'm', 'LineWidth', line_width);
plot(t_lqr2, dpos_lqr2(3,:), 'y', 'LineWidth', line_width);
plot(t_kas, ref(3,:), 'k--', 'LineWidth', ref_line_width)

ylabel('{\it z} [m]', 'FontSize', fs, 'FontName', 'Times New Roman');
xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
% ylim([-0.5; 3.5])
legend({'PID+ZV', 'PP1', 'PP2', 'LQR1', 'LQR2', '{\it z}_{ref}'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman', ...
    'Location', 'best', NumColumns=2);
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('Obrazky/', 'mujoco_z_all.svg'), 'svg');


%%
% Orientace koptery--------------------------------------------------------
% roll
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on;
plot(t_kas, dang_kas(1,:), 'r', 'LineWidth', line_width);
plot(t_stav_smo, dang_stav_smo(1,:), 'g', 'LineWidth', line_width);
plot(t_stav_agr, dang_stav_agr(1,:), 'b', 'LineWidth', line_width);
plot(t_lqr1, dang_lqr1(1,:), 'm', 'LineWidth', line_width);
plot(t_lqr2, dang_lqr2(1,:), 'y', 'LineWidth', line_width);

ylabel('\phi [deg]', 'FontSize', fs, 'FontName', 'Times New Roman');
legend({'PID+ZV', 'PP1', 'PP2', 'LQR1', 'LQR2'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman', ...
    'Location', 'best', NumColumns=5);
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('Obrazky/', 'mujoco_roll_all.svg'), 'svg');

% pitch
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on;
plot(t_kas, dang_kas(2,:), 'r', 'LineWidth', line_width);
plot(t_stav_smo, dang_stav_smo(2,:), 'g', 'LineWidth', line_width);
plot(t_stav_agr, dang_stav_agr(2,:), 'b', 'LineWidth', line_width);
plot(t_lqr1, dang_lqr1(2,:), 'm', 'LineWidth', line_width);
plot(t_lqr2, dang_lqr2(2,:), 'y', 'LineWidth', line_width);

ylabel('\theta [deg]', 'FontSize', fs, 'FontName', 'Times New Roman');
% ylim([-10, 10])
% legend({'PID+ZV', 'PP1', 'PP2', 'LQR1', 'LQR2'}, ...
%     'FontSize', legs, 'FontName', 'Times New Roman', ...
%     'Location', 'best', NumColumns=5);
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('Obrazky/', 'mujoco_pitch_all.svg'), 'svg');

% yaw
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on;
plot(t_kas, dang_kas(3,:), 'r', 'LineWidth', line_width);
plot(t_stav_smo, dang_stav_smo(3,:), 'g', 'LineWidth', line_width);
plot(t_stav_agr, dang_stav_agr(3,:), 'b', 'LineWidth', line_width);
plot(t_lqr1, dang_lqr1(3,:), 'm', 'LineWidth', line_width);
plot(t_lqr2, dang_lqr2(3,:), 'y', 'LineWidth', line_width);

% ylim([-2, 2])
xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('\psi [deg]', 'FontSize', fs, 'FontName', 'Times New Roman');
% legend({'PID+ZV', 'PP1', 'PP2', 'LQR1', 'LQR2'}, ...
%     'FontSize', legs, 'FontName', 'Times New Roman', ...
%     'Location', 'best', NumColumns=5);
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('Obrazky/', 'mujoco_yaw_all.svg'), 'svg');


%%
% Orientace zavazi---------------------------------------------------------
% alpha
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(t_kas, pang_kas(1,:), 'r', 'LineWidth', line_width);
plot(t_stav_smo, pang_stav_smo(1,:), 'g', 'LineWidth', line_width);
plot(t_stav_agr, pang_stav_agr(1,:), 'b', 'LineWidth', line_width);
plot(t_lqr1, pang_lqr1(1,:), 'm', 'LineWidth', line_width);
plot(t_lqr2, pang_lqr2(1,:), 'y', 'LineWidth', line_width);

% xlabel('t [s]', 'Color', 'none', 'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('\alpha [deg]', 'FontSize', fs, 'FontName', 'Times New Roman');
% ylim([-40, 40])
legend({'PID+ZV', 'PP1', 'PP2', 'LQR1', 'LQR2'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman', ...
    'Location', 'northeast', NumColumns=2);
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('Obrazky/', 'mujoco_alpha_all.svg'), 'svg');

% beta
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(t_kas, pang_kas(2,:), 'r', 'LineWidth', line_width);
plot(t_stav_smo, pang_stav_smo(2,:), 'g', 'LineWidth', line_width);
plot(t_stav_agr, pang_stav_agr(2,:), 'b', 'LineWidth', line_width);
plot(t_lqr1, pang_lqr1(2,:), 'm', 'LineWidth', line_width);
plot(t_lqr2, pang_lqr2(2,:), 'y', 'LineWidth', line_width);

xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('\beta [deg]', 'FontSize', fs, 'FontName', 'Times New Roman');
% ylim([-40, 40])
% legend({'PID+ZV', 'PP1', 'PP2', 'LQR1', 'LQR2'}, ...
%     'FontSize', legs, 'FontName', 'Times New Roman', ...
%     'Location', 'best', NumColumns=3);
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('Obrazky/', 'mujoco_beta_all.svg'), 'svg');

%%
% Tahova sila a momenty----------------------------------------------------
% Tah
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(t_kas, u_kas(1,:), 'r', 'LineWidth', line_width);
plot(t_stav_smo, u_stav_smo(1,:), 'g', 'LineWidth', line_width);
plot(t_stav_agr, u_stav_agr(1,:), 'b', 'LineWidth', line_width);
plot(t_lqr1, u_lqr1(1,:), 'm', 'LineWidth', line_width);
plot(t_lqr2, u_lqr2(1,:), 'y', 'LineWidth', line_width);
yline(29.43, 'k--', 'LineWidth', ref_line_width) % (M+m)*g

ylim([0, 140])
yticks(0:20:150)
xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('{\it T} [N]', 'FontSize', fs, 'FontName', 'Times New Roman');
grid on;
legend({'PID+ZV', 'PP1', 'PP2', 'LQR1', 'LQR2', '(M+m)\cdotg'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman', ...
    'Location', 'best', NumColumns=2);
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('Obrazky/', 'mujoco_T_all.svg'), 'svg');

%%
% Momenty -> 3 zvlastni grafy pro kazdy moment
% Tau_phi
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(t_kas, u_kas(2,:), 'r', 'LineWidth', line_width);
plot(t_stav_smo, u_stav_smo(2,:), 'g', 'LineWidth', line_width);
plot(t_stav_agr, u_stav_agr(2,:), 'b', 'LineWidth', line_width);
plot(t_lqr1, u_lqr1(2,:), 'm', 'LineWidth', line_width);
plot(t_lqr2, u_lqr2(2,:), 'y', 'LineWidth', line_width);

% xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylim([-0.8, 0.8])
yticks(-0.8:0.2:0.8)

ylabel('\tau_{\phi} [Nm]', 'FontSize', fs, 'FontName', 'Times New Roman');
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('Obrazky/', 'mujoco_Tau_phi_all.svg'), 'svg');

% Tau_theta
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(t_kas, u_kas(3,:), 'r', 'LineWidth', line_width);
plot(t_stav_smo, u_stav_smo(3,:), 'g', 'LineWidth', line_width);
plot(t_stav_agr, u_stav_agr(3,:), 'b', 'LineWidth', line_width);
plot(t_lqr1, u_lqr1(3,:), 'm', 'LineWidth', line_width);
plot(t_lqr2, u_lqr2(3,:), 'y', 'LineWidth', line_width);

% xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('\tau_{\theta} [Nm]', 'FontSize', fs, 'FontName', 'Times New Roman');
legend({'PID+ZV', 'PP1', 'PP2', 'LQR1', 'LQR2', '(M+m)\cdotg'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman', ...
    'Location', 'best', NumColumns=2);
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('Obrazky/', 'mujoco_Tau_theta_all.svg'), 'svg');

% Tau_psi
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(t_kas, u_kas(4,:), 'r', 'LineWidth', line_width);
plot(t_stav_smo, u_stav_smo(4,:), 'g', 'LineWidth', line_width);
plot(t_stav_agr, u_stav_agr(4,:), 'b', 'LineWidth', line_width);
plot(t_lqr1, u_lqr1(4,:), 'm', 'LineWidth', line_width);
plot(t_lqr2, u_lqr2(4,:), 'y', 'LineWidth', line_width);

xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('\tau_{\psi} [Nm]', 'FontSize', fs, 'FontName', 'Times New Roman');
% legend({'\tau_{\phi}', '\tau_{\theta}', '\tau_{\psi}'},...
%     'FontSize', legs, 'FontName', 'Times New Roman');
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('Obrazky/', 'mujoco_Tau_psi_all.svg'), 'svg');


%% 3D graf trajektorie
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 8.2 7.8]);
view(-144.2678, 33.91)
hold on
% хз, в один или раздельно
% plot3(dpos_kas(1,:), dpos_kas(2,:), dpos_kas(3,:), 'r', 'LineWidth', line_width)
% plot3(dpos_stav_smo(1,:), dpos_stav_smo(2,:), dpos_stav_smo(3,:), 'g', 'LineWidth', line_width)
% plot3(dpos_stav_agr(1,:), dpos_stav_agr(2,:), dpos_stav_agr(3,:), 'b', 'LineWidth', line_width)
% plot3(dpos_lqr1(1,:), dpos_lqr1(2,:), dpos_lqr1(3,:), 'm', 'LineWidth', line_width)
plot3(dpos_lqr2(1,:), dpos_lqr2(2,:), dpos_lqr2(3,:), 'y', 'LineWidth', line_width)
ref_points = unique(ref', 'rows', 'stable')';
plot3(ref_points(1,:), ref_points(2,:), ref_points(3,:), 'ko', 'LineWidth', line_width)
for i = 1:size(ref_points,2)
    x = ref_points(1,i);
    y = ref_points(2,i);
    z = ref_points(3,i);

    % Формируем текст с координатами
    label = sprintf('(%g, %g, %g)', x, y, z);

    % Добавляем текст рядом с точкой
    % text(x, y, z, label, 'FontSize', legs*0.8, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

    % Линия от (x, y, z) до (x, y, 0)
    plot3([x x], [y y], [0 z], 'k--')  % пунктирная красная линия
end

axis equal
grid on
xlabel('{\it x} [m]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('{\it y} [m]', 'FontSize', fs, 'FontName', 'Times New Roman');
zlabel('{\it z} [m]', 'FontSize', fs, 'FontName', 'Times New Roman');
xlim([-4, 4])
xticks(-3:3:3)
ylim([-4, 4])
yticks(-3:3:3)
zlim([0, 10])
zticks([0, 2, 3, 6, 8])
% Ось X (красная)
plot3([0 1], [0 0], [0 0], 'r', 'LineWidth', axis_width*2)
% Ось Y (зелёная)
plot3([0 0], [0 1], [0 0], 'Color','#228B22', 'LineWidth', axis_width*2)
% Ось Z (голубая)
plot3([0 0], [0 0], [0 1], 'b', 'LineWidth', axis_width*2)
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, ...
    'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');

legend({'LQR2'}, 'FontSize', legs, 'FontName', 'Times New Roman', ...
    'Location', 'best');
tightfig;
% saveas(gcf, fullfile('Obrazky/', 'mujoco_3D_kaskadova.svg'), 'svg');


%% Vypocet stredni kvadraticke chyby pro ruzne veliciny 
% Root Mean Squared Error (RMSE)
% sqrt( mean((dpos_kas - ref).^2, 2) ) --> rmse(F, A, dim)

% POLOHA
dpos_kas_RMSE = rmse(dpos_kas, ref, 2); %[x_RMSE; y_RMSE; z_RMSE)
dpos_stav_smo_RMSE = rmse(dpos_stav_smo, ref, 2);
dpos_stav_agr_RMSE = rmse(dpos_stav_agr, ref, 2);
dpos_lqr1_RMSE = rmse(dpos_lqr1, ref, 2);
dpos_lqr2_RMSE = rmse(dpos_lqr2, ref, 2);


% UHLY DRONU
dang_zero = zeros(3, 10001); % chyba vuci nulovym hodnotam

dang_kas_RMSE = rmse(dang_kas, dang_zero, 2);
dang_stav_smo_RMSE = rmse(dang_stav_smo, dang_zero, 2);
dang_stav_agr_RMSE = rmse(dang_stav_agr, dang_zero, 2);
dang_lqr1_RMSE = rmse(dang_lqr1, dang_zero, 2);
dang_lqr2_RMSE = rmse(dang_lqr2, dang_zero, 2);


% TAH A MOMENTY
% chyba pro tah a momenty
u_klid = [3*9.81; 0; 0; 0]*ones(1, 10001); % nutna matice

u_kas_RMSE = rmse(u_kas, u_klid, 2);
u_stav_smo_RMSE = rmse(u_stav_smo, u_klid, 2);
u_stav_agr_RMSE = rmse(u_stav_agr, u_klid, 2);
u_lqr1_RMSE = rmse(u_lqr1, u_klid, 2);
u_lqr2_RMSE = rmse(u_lqr2, u_klid, 2);
%  bar([u_kas_RMSE(2:4,:), u_stav_smo_RMSE(2:4,:), u_stav_agr_RMSE(2:4,:), u_lqr1_RMSE(2:4,:), u_lqr2_RMSE(2:4,:)])


% OTACKY
% pokud pro otacky ze vsech 4 motoru (889.23) [rad/s]
w_klid = 889.23*ones(4, 10001);

w_kas_RMSE = mean(rmse(w_kas, w_klid, 2));
w_stav_smo_RMSE = mean(rmse(w_stav_smo, w_klid, 2));
w_stav_agr_RMSE = mean(rmse(w_stav_agr, w_klid, 2));
w_lqr1_RMSE = mean(rmse(w_lqr1, w_klid, 2));
w_lqr2_RMSE = mean(rmse(w_lqr2, w_klid, 2));
% bar([w_kas_RMSE, w_stav_smo_RMSE, w_stav_agr_RMSE, w_lqr1_RMSE, w_lqr2_RMSE])


% UHLY ZAVAZI (chyba od 0 deg)
pang_zero = zeros(2, 10001);

pang_kas_RMSE = rmse(pang_kas, pang_zero, 2);
pang_stav_smo_RMSE = rmse(pang_stav_smo, pang_zero, 2);
pang_stav_agr_RMSE = rmse(pang_stav_agr, pang_zero, 2);
pang_lqr1_RMSE = rmse(pang_lqr1, pang_zero, 2);
pang_lqr2_RMSE = rmse(pang_lqr2, pang_zero, 2);
% bar([pang_kas_RMSE, pang_stav_smo_RMSE, pang_stav_agr_RMSE, pang_lqr1_RMSE, pang_lqr2_RMSE])

% RYCHLOSTI UHLU ZAVAZI
pang_vel_kas_RMSE = rmse( diff(pang_kas,1,2)./diff(t_kas'), pang_zero(:, end-1), 2);
pang_vel_stav_smo_RMSE = rmse( diff(pang_stav_smo,1,2)./diff(t_kas'), pang_zero(:, end-1), 2);
pang_vel_stav_agr_RMSE = rmse( diff(pang_stav_agr,1,2)./diff(t_kas'), pang_zero(:, end-1), 2);
pang_vel_lqr1_RMSE = rmse( diff(pang_lqr1,1,2)./diff(t_kas'), pang_zero(:, end-1), 2);
pang_vel_lqr2_RMSE = rmse( diff(pang_lqr2,1,2)./diff(t_kas'), pang_zero(:, end-1), 2);
% bar([pang_vel_kas_RMSE, pang_vel_stav_smo_RMSE, pang_vel_stav_agr_RMSE, pang_vel_lqr1_RMSE, pang_vel_lqr2_RMSE])


% Mimo praci
% Просто мысль...а если а считаю все RMSE
% для каждого способа управления, типо все
% показатели имееют вес 1, и какая выйдет сумма
% для каждого регулятора

% vahy pro polohu, uhly zavazi a otacky
k_pos = 1;
k_pang = 1;
k_w = 1;

SUMM_kas = k_pos*sum(dpos_kas_RMSE) + sum(dang_kas_RMSE) + sum(u_kas_RMSE) +...
    + k_w*sum(w_kas_RMSE) + k_pang*sum(pang_kas_RMSE) + sum(pang_vel_kas_RMSE);

SUMM_stav_smo = k_pos*sum(dpos_stav_smo_RMSE) + sum(dang_stav_smo_RMSE) + sum(u_stav_smo_RMSE) +...
    + k_w*sum(w_stav_smo_RMSE) + k_pang*sum(pang_stav_smo_RMSE) + sum(pang_vel_stav_smo_RMSE);

SUMM_stav_agr = k_pos*sum(dpos_stav_agr_RMSE) + sum(dang_stav_agr_RMSE) + sum(u_stav_agr_RMSE) +...
    + k_w*sum(w_stav_agr_RMSE) + k_pang*sum(pang_stav_agr_RMSE) + sum(pang_vel_stav_agr_RMSE);

SUMM_lqr1 = k_pos*sum(dpos_lqr1_RMSE) + sum(dang_lqr1_RMSE) + sum(u_lqr1_RMSE) +...
    + k_w*sum(w_lqr1_RMSE) + k_pang*sum(pang_lqr1_RMSE) + sum(pang_vel_lqr1_RMSE);

SUMM_lqr2 = k_pos*sum(dpos_lqr2_RMSE) + sum(dang_lqr2_RMSE) + sum(u_lqr2_RMSE) +...
    + k_w*sum(w_lqr2_RMSE) + k_pang*sum(pang_lqr2_RMSE) + sum(pang_vel_lqr2_RMSE);

figure
name = ["PID+ZV", "PP1", "PP2", "LQR1", "LQR2"];
% bar(name, [SUMM_kas, SUMM_stav_smo, SUMM_stav_agr, SUMM_lqr1, SUMM_lqr2])
