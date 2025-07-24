% 14.07.2025
% Kod pro vytvoreni normalnich obrazku pro DP
% pro LQR rizeni
% (asi nebude se moc lisit od plot_Stavova)

% Nutne rucne menit co bude na grafu a co ne !
close all

% Simulink data
% Asi dva ruzne navrhy -> pro kazdy graf 2x krivky

% Pro variantu 1 -> sledovani polohy
t1 = out_poloha.tout;
dron_pos_1 = out_poloha.dron_pos.Data(:,:);
dron_ang_1 = rad2deg(out_poloha.dron_angles.Data(:,:));
pend_ang_1 = rad2deg( out_poloha.pend_angles.Data(:,:));
u_1 =  out_poloha.inputs.Data(:,:); % 1-sila, 2,3,4 - momenty

% % Pro variantu 2 -> setreni paliva
t2 = out_palivo.tout;
dron_pos_2 = out_palivo.dron_pos.Data(:,:);
dron_ang_2 = rad2deg(out_palivo.dron_angles.Data(:,:));
pend_ang_2 = rad2deg(out_palivo.pend_angles.Data(:,:));
u_2 = out_palivo.inputs.Data(:,:);
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
plot(t1, dron_pos_1(:, 1), 'r', 'LineWidth', line_width);
plot(t2, dron_pos_2(:, 1), 'Color', [1.0 0.4 0.4], 'LineWidth', line_width)
yline(1,'--', 'Color', '#7E2F8E', 'LineWidth', ref_line_width)
ylabel('{\it x} [m]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylim([-0.2, 1.2])
% xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
legend({'návrh 1', 'návrh 2', '{\it x}_{ref}'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman', ...
    'Location', 'best');
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'lqr_x.svg'), 'svg');

%y
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(t1, dron_pos_1(:, 2), 'Color','#228B22', 'LineWidth', line_width);
plot(t2, dron_pos_2(:, 2), 'Color', [0.4, 1, 0.4]*0.85, 'LineWidth', line_width)
yline(2,'--', 'Color', '#7E2F8E', 'LineWidth', ref_line_width)
ylabel('{\it y} [m]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylim([-0.5, 2.5])
% xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
legend({'návrh 1', 'návrh 2', '{\it y}_{ref}'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman', ...
    'Location', 'best');
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'lqr_y.svg'), 'svg');

%z
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(t1, dron_pos_1(:, 3), 'b', 'LineWidth', line_width);
plot(t2, dron_pos_2(:, 3), 'Color', [0.4 0.4 1.0], 'LineWidth', line_width)
yline(3,'--', 'Color', '#7E2F8E', 'LineWidth', ref_line_width)
ylabel('{\it z} [m]', 'FontSize', fs, 'FontName', 'Times New Roman');
xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylim([-0.5; 3.5])
legend({'návrh 1', 'návrh 2', '{\it z}_{ref}'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman', ...
    'Location', 'best');
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'lqr_z.svg'), 'svg');


% Orientace koptery--------------------------------------------------------
% roll
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on;
plot(t1, dron_ang_1(:, 1), 'r', 'LineWidth', line_width);
plot(t2, dron_ang_2(:, 1), 'Color', [1.0 0.4 0.4], 'LineWidth', line_width)
ylabel('\phi [deg]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylim([-15, 15])
legend({'návrh 1', 'návrh 2'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman');
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'lqr_roll.svg'), 'svg');

%pitch
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on;
plot(t1, dron_ang_1(:, 2), 'Color','#228B22', 'LineWidth', line_width);
plot(t2, dron_ang_2(:, 2), 'Color', [0.4, 1, 0.4]*0.85, 'LineWidth', line_width)
ylabel('\theta [deg]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylim([-10, 10])
legend({'návrh 1', 'návrh 2'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman');
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'lqr_pitch.svg'), 'svg');

%yaw
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on;
plot(t1, dron_ang_1(:, 3), 'b', 'LineWidth', line_width);
plot(t2, dron_ang_2(:, 3), 'Color', [0.4 0.4 1.0], 'LineWidth', line_width)
yline(0,'--', 'Color', '#7E2F8E', 'LineWidth', ref_line_width)
ylim([-2, 2])
xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('\psi [deg]', 'FontSize', fs, 'FontName', 'Times New Roman');
legend({'návrh 1', 'návrh 2', '\psi_{ref}'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman');
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'lqr_yaw.svg'), 'svg');


% Orientace zavazi---------------------------------------------------------
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(t1, pend_ang_1(:, 1), 'r', 'LineWidth', line_width);
plot(t1, pend_ang_1(:, 2), 'Color','#228B22', 'LineWidth', line_width);
plot(t2, pend_ang_2(:, 1), 'Color', [1.0 0.4 0.4], 'LineWidth', line_width)
plot(t2, pend_ang_2(:, 2), 'Color', [0.4, 1, 0.4]*0.85, 'LineWidth', line_width)
xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('\alpha [deg], \beta [deg]', 'FontSize', fs, 'FontName', 'Times New Roman');
% ylim([-40, 40])
legend({'\alpha návrh 1', '\beta návrh 1', '\alpha návrh 2', '\beta návrh 2'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman', 'NumColumns', 2);
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'lqr_alpha_beta.svg'), 'svg');


% Tahova sila a momenty
% Sila
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
plot(t1, u_1(:, 1), 'b', 'LineWidth', line_width)
plot(t2, u_2(:, 1), 'Color', [0.4 0.4 1.0], 'LineWidth', line_width)
yline(29.43, '--', 'Color', '#7E2F8E', 'LineWidth', ref_line_width)
% xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
ylabel('{\it T} [N]', 'FontSize', fs, 'FontName', 'Times New Roman');
grid on;
legend({'návrh 1', 'návrh 2', '(M+m)\cdotg'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman', ...
    'Location', 'best');
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'lqr_tah.svg'), 'svg');

% Momenty
figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 width_cm height_cm]);
hold on
% Используем tiledlayout для общей подписи осей
t = tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
% Общий ylabel
ylabel(t, '\tau_{\phi}, \tau_{\theta}, \tau_{\psi} [Nm]', ...
       'FontSize', fs, 'FontName', 'Times New Roman');

% --- Первый subplot: smo ---
nexttile; hold on;
plot(t1, u_1(:, 2), 'r', 'LineWidth', line_width);
plot(t1, u_1(:, 3), 'Color','#228B22', 'LineWidth', line_width);
plot(t1, u_1(:, 4), 'b', 'LineWidth', line_width);
legend({'\tau_{\phi}', '\tau_{\theta}', '\tau_{\psi} návrh 1'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman',...
    'Orientation', 'horizontal', 'Location', 'southeast');
grid on;
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, ...
    'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');

% --- Второй subplot: agr ---
nexttile; hold on;
plot(t1, u_2(:, 2), 'Color', [1.0 0.4 0.4], 'LineWidth', line_width);
plot(t1, u_2(:, 3), 'Color', [0.4, 1, 0.4]*0.85, 'LineWidth', line_width);
plot(t1, u_2(:, 4), 'Color', [0.4 0.4 1.0], 'LineWidth', line_width);
xlabel('t [s]', 'FontSize', fs, 'FontName', 'Times New Roman');
grid on;
legend({'\tau_{\phi}', '\tau_{\theta}', '\tau_{\psi} návrh 2'}, ...
    'FontSize', legs, 'FontName', 'Times New Roman',...
    'Orientation', 'horizontal', 'Location', 'southeast');
% ytickformat('%.2f');
set(gca, 'LineWidth', axis_width, 'FontSize', axis_font_size, ...
    'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
% tightfig;
saveas(gcf, fullfile('obrazky plot', 'lqr_momenty.svg'), 'svg');

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
% P.S. Uvazuju 2% z max reg. odchylky, protoze stavova regulace je mnohem
% lepe

% stepinfo_and_error(dron_pos_2(:,3), t2, 3, 0, 2/100)
% lsiminfo(sim_dron_pos(:,2), sim_time, x_ref, 0, 'SettlingTimeThreshold', 0.02)

% stepinfo_and_error(dron_ang_1(:,3), t1, 0, 0, 5/100)
% lsiminfo(dron_ang_2(:,2), t2, 0, 0, 'SettlingTimeThreshold', 0.05)

% lsiminfo(pend_ang_2(:,2), t2, 0, 0, 'SettlingTimeThreshold', 0.05)