% Пример данных
t = out.tout;
% Подставьте сюда свои данные:
alpha = out.pend_angles.Data(:,1);  % измеренный сигнал (вектор той же длины, что и t)

% Модель затухающего колебания
model_fun = @(p, t) p(1) * exp(-p(2)*t) .* cos(p(3)*t + p(4));

% Начальные приближения: [A, damping, omega_d, phi]
A0 = max(alpha);
zeta_omega0_0 = 1; % грубая оценка коэффициента эксп. затухания
omega_d0 = 2*pi*1; % 1 Гц, замените по грубой оценке
phi0 = 0;
p0 = [A0, zeta_omega0_0, omega_d0, phi0];

% Оптимизация
opts = optimoptions('lsqcurvefit', 'Display', 'off');
[p_opt, resnorm] = lsqcurvefit(model_fun, p0, t, alpha, [], [], opts);

% Расшифровка параметров
A_fit = p_opt(1);
zeta_omega0_fit = p_opt(2);
omega_d_fit = p_opt(3);
phi_fit = p_opt(4);

% Если надо извлечь zeta и omega_0:
% omega_d = omega_0 * sqrt(1 - zeta^2)
% => omega_0 = sqrt(omega_d^2 + zeta_omega0^2)
omega_0 = sqrt(omega_d_fit^2 + zeta_omega0_fit^2);
zeta = zeta_omega0_fit / omega_0;

% Визуализация
x_fit = model_fun(p_opt, t);

figure;
set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 16.5 5]);
hold on
plot(t, rad2deg(alpha), 'r', 'LineWidth', 1.5)
plot(t, rad2deg(x_fit), 'k--', 'LineWidth', 1.5);
yticks([-30; -15; 0; 15; 30])
xlabel('t [s]', 'FontSize', 12, 'FontName', 'Times New Roman');
ylabel('\alpha [deg]', 'FontSize', 12, 'FontName', 'Times New Roman');
legend({'\alpha_{měření}', '\alpha_{odhad}'}, ...
    'FontSize', 12, 'FontName', 'Times New Roman');
grid on;
set(gca, 'LineWidth', 1.5, 'FontSize', 11, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman');
tightfig;
saveas(gcf, fullfile('obrazky plot', 'tlumeni_odhad_koef.svg'), 'svg');

%% Чтобы не проводить эксперименты по 300 раз (есл что, просто закоментировать)
omega_0 = 3.6539; % frekvence
zeta = 0.1385; %koef tlumeni

% Parametry "tlumenych" kmitu
fprintf('Uhlova frekvence (omega_0): %.4f rad/s\n', omega_0);
fprintf('Tlumeni (zeta): %.4f\n', zeta);

% vekla omega
big_omega = omega_0*sqrt(1-zeta^2);

% Vypocet shaperu
bbeta = -omega_0 * zeta
A = exp(bbeta/big_omega*pi)/(1 + exp(bbeta/big_omega*pi))
T = pi/big_omega

disp("-------------------------------")

% TF shaperu (pri dosazeni ciloveho polu musi byt 0)
s = -bbeta - i*big_omega;
G_shaper = A + (1-A)*exp(-s*T)


% Vizualni kontrola
bbeta1 = -omega_0 * zeta;
A1 = exp(bbeta1/big_omega*pi)/(1 + exp(bbeta1/big_omega*pi));
T1 = pi/big_omega;

bbeta2 = omega_0 * zeta;
A2 = exp(bbeta2/big_omega*pi)/(1 + exp(bbeta2/big_omega*pi));
T2 = pi/big_omega;

% Диапазон частот
omega = linspace(0, 10, 100);

s_sub = @(omega) omega.*(-zeta + j*sqrt(1-zeta^2));

S1 = @(s) A1 + (1-A1).*exp(-s.*T1);
S2 = @(s) A2 + (1-A2).*exp(-s.*T2);

S1_mod = abs(S1(s_sub(omega))) .* exp(-omega*zeta*T1);
S2_mod = abs(S2(s_sub(omega))) .* exp(-omega*zeta*T2);

% Построение графика
figure;
hold on
plot(omega, S1_mod, 'LineWidth', 2);
plot(omega, S2_mod, 'LineWidth', 2);
xlabel('\omega');
ylabel('|S(\omega)|');
title('Amplitude of S(\omega) for substituted s');
legend('A=0.3919', 'A=0.6081')
grid on;

