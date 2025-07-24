% 32.06.2025
% Kod pro vytvoreni normalnich obrazku pro DP

% Nutne rucne menit co bude na grafu a co ne !
close all

% Simulink data
sim_time = out.tout;
sim_dron_pos = out.dron_pos.Data(:,:);
sim_dron_angles = rad2deg(out.dron_angles.Data(:,:));
sim_pend_angles = rad2deg(out.pend_angles.Data(:,:));
x_ref = out.ref.Data(:,1);
y_ref = out.ref.Data(:,2);
z_ref = out.ref.Data(:,3);

roll_ref = out.ref.Data(:,4);
pitch_ref = out.ref.Data(:,5);
yaw_ref = out.ref.Data(1,6);

u = out.inputs.Data(:,:)'; % 1-sila, 2,3,4 - momenty

% Stara data pro Cascadove rizeni bez VZ shaperu 
% -> chci do novych grafu pridat tenkce cary starych dat pro lepsi
% porovnani
% load('out_cascade_ref12345.mat')
old_sim_time = out_old.tout;
x_old = out_old.dron_pos.Data(:,1);
y_old = out_old.dron_pos.Data(:,2);
z_old = out_old.dron_pos.Data(:,3);
roll_old = rad2deg(out_old.dron_angles.Data(:,1));
pitch_old = rad2deg(out_old.dron_angles.Data(:,2));
yaw_old = rad2deg(out_old.dron_angles.Data(:,3));
alpha_old = rad2deg(out_old.pend_angles.Data(:,1));
beta_old = rad2deg(out_old.pend_angles.Data(:,2));
%%
% Font size
fs = 12; % velikost pismen popisujici osy
legs = 12; % velikost pismen v legend

line_width = 1.5; % tloustka krivek
ref_line_width = 1.2; % tloustka referencnich krivek
old_line_width = 1; %tloustka pro stara data bez ZV
axis_width = 1.5; % tlouska krivek os

axis_font_size = 11; % velikost pismen pro cisla na osach

% Rozmer figure pro Word
width_cm = 16.5;
height_cm = 7.5;

% Cesta ke slozce
script_path = fileparts(mfilename('fullpath'));
folder_path = fullfile(script_path, 'obrazky plot');


% Poloha koptery-----------------------------------------------------------
% x
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(sim_time, sim_dron_pos(:, 1), 'r', 'LineWidth', line_width);
plot(sim_time, x_ref,'--', 'Color', '#7E2F8E', 'LineWidth', ref_line_width)
plot(old_sim_time, x_old, 'k:', 'LineWidth', old_line_width)
ylabel('{\it x} [m]', 'FontSize', fs, 'FontName', 'Times New Roman');
% xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
legend({'{\it x}', '{\it x}_{ref}', '{\it x}_{bez ZV}'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman', ...
    'Location', 'best');
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'cascade_x.svg'), 'svg');

%y
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(sim_time, sim_dron_pos(:, 2), 'Color','#228B22', 'LineWidth', line_width);
plot(sim_time, y_ref,'--', 'Color', '#7E2F8E', 'LineWidth', ref_line_width)
plot(old_sim_time, y_old, 'k:', 'LineWidth', old_line_width)
ylabel('{\it y} [m]', 'FontSize', fs, 'FontName', 'Times New Roman');
% xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
legend({'{\it y}', '{\it y}_{ref}', '{\it y}_{bez ZV}'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman', ...
    'Location', 'best');
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'cascade_y.svg'), 'svg');

%z
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(sim_time, sim_dron_pos(:, 3), 'b', 'LineWidth', line_width);
plot(sim_time, z_ref,'--', 'Color', '#7E2F8E', 'LineWidth', ref_line_width)
plot(old_sim_time, z_old, 'k:', 'LineWidth', old_line_width)
ylabel('{\it z} [m]', 'FontSize', fs, 'FontName', 'Times New Roman');
xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
legend({'{\it z}', '{\it z}_{ref}', '{\it z}_{bez ZV}'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman', ...
    'Location', 'best');
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'cascade_z.svg'), 'svg');


% Orientace koptery--------------------------------------------------------
% roll
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on;
plot(sim_time, sim_dron_angles(:, 1), 'r-', 'LineWidth', line_width);
plot(sim_time, roll_ref, 'Color', '#7E2F8E', 'LineStyle', '--', 'LineWidth', ref_line_width);
plot(old_sim_time, roll_old, 'k:', 'LineWidth', old_line_width)
% xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('\phi [deg]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylim([-45, 45])
legend({'\phi', '\phi_{ref}', '\phi_{bez ZV}'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman');
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'cascade_roll.svg'), 'svg');

%pitch
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on;
plot(sim_time, sim_dron_angles(:, 2), 'Color','#228B22', 'LineStyle','-', 'LineWidth', line_width);
plot(sim_time, pitch_ref, 'Color', '#7E2F8E', 'LineStyle', '--', 'LineWidth', ref_line_width);
plot(old_sim_time, pitch_old, 'k:', 'LineWidth', old_line_width)
% xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('\theta [deg]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylim([-45, 45])
legend({'\theta', '\theta_{ref}', '\theta_{bez ZV}'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman');
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'cascade_pitch.svg'), 'svg');

%yaw
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on;
plot(sim_time, sim_dron_angles(:, 3), 'b', 'LineWidth', line_width);
yline(yaw_ref, '--', 'Color', '#7E2F8E', 'LineWidth', ref_line_width)
plot(old_sim_time, yaw_old, 'k:', 'LineWidth', old_line_width)
xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('\psi [deg]', 'FontSize', fs, 'FontName', 'Times New Roman');
legend({'\psi', '\psi_{ref}', '\psi_{bez ZV}'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman', ...
    'Location', 'best');
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'cascade_yaw.svg'), 'svg');


% Orientace zavazi---------------------------------------------------------
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(sim_time, sim_pend_angles(:, 1), 'r', 'LineWidth', line_width)
plot(sim_time, sim_pend_angles(:, 2), 'Color', '#228B22', 'LineStyle', '-', 'LineWidth', line_width)
plot(old_sim_time, alpha_old, 'r:', 'LineWidth', old_line_width)
plot(old_sim_time, beta_old, 'Color', '#228B22', 'LineStyle', ':', 'LineWidth', old_line_width)
xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('\alpha [deg], \beta [deg]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylim([-40, 40])
legend({'\alpha', '\beta', '\alpha_{bez ZV}', '\beta_{bez ZV}'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman');
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'cascade_alpha_beta.svg'), 'svg');


% Tahova sila a momenty
% Sila
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(sim_time, u(:,1), 'b', 'LineWidth', line_width)
yline(29.43, '--', 'Color', '#7E2F8E', 'LineWidth', ref_line_width)
xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('{\it T} [N]', 'FontSize', fs, 'FontName', 'Times New Roman');
grid on;
legend({'{\it T}', '(M+m)\cdotg'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman', ...
    'Location', 'best');
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'cascade_tah.svg'), 'svg');

% Momenty
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(sim_time, u(:, 2), 'r', 'LineWidth', line_width);
plot(sim_time, u(:, 3), 'Color','#228B22', 'LineWidth', line_width);
plot(sim_time, u(:, 4), 'b', 'LineWidth', line_width);
xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
% xticks([0,0.5,1,1.5,2,4,6,8,10,12,14,16])
ylabel('\tau_{\phi}, \tau_{\theta}, \tau_{\psi} [Nm]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylim([-0.8, 0.8])
legend({'\tau_{\phi}', '\tau_{\theta}', '\tau_{\psi}'},...
    'FontSize', legs, 'FontName', 'Times New Roman');
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'cascade_momenty.svg'), 'svg');

%% Uzivatelska funkce pro analyzu grafu
function stepinfo_and_error(data, t, ref_v, start_v, ST)
    % data - namerena odezva z Simulink tx1
    % t - cas
    % ref_v - pozadovana hodnota na ktere musi se ustalit
    % start_v - pocatecni hodnota (vetsinou 0)
    % ST - Setting Time Threshold (defoltne 2%)
    inf = stepinfo(data, t, ref_v, start_v, 'SettlingTimeThreshold', ST);

    % Vypocet ustalene chyby
    settlingTime = inf.SettlingTime;
    % Находим индексы после времени установления
    idx = find(t >= settlingTime);
    % Среднее значение выхода после settlingTime
    data_avg = mean(data(idx));
    % Ошибка от среднего значения к желаемому
    SSE = abs(ref_v - data_avg)/ref_v*100;
    
    disp(inf)
    fprintf('Steady-state error: %.2f\n', SSE);
    fprintf('--------------------------\n\n')
end

% rucne
% stepinfo_and_error(sim_dron_pos(:,3), sim_time, 3, 0, 5/100)
% lsiminfo(sim_dron_pos(:,2), sim_time, x_ref, 0, 'SettlingTimeThreshold', 0.05)

% stepinfo_and_error(sim_dron_angles(:,3), sim_time, 45, 0, 5/100)
lsiminfo(sim_dron_angles(:,2), sim_time, 0, 0, 'SettlingTimeThreshold', 0.05)