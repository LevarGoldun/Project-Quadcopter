% 27.02.2025
%% Uvod
% Все остальные коды/файлы в этом тесте сделаны в 2024 году летнего
% семестра про проект 1. Почему я делаю этот файл в 2025 году летнего
% семестра (диплом и проект 3). Ну, у меня не выходит state feedback 
% про 3Д квадрокоптер с грузом (ряд матрицы R меньше чем состояний) 
% и поэтому я хочу попробовать для 2Д квадрокоптере с грузом. Let's go.

%% Rovnice prave strany a linearizace
% zkopirovano z simulink_rizeni_bez_a_s_zavazim.slx z test_4.5
% [x1, x2, x3, x4, x5, x6, x7, x8] = [x, y, fi, alfa, x_dot, y_dot, fi_dot, alfa_dot]
syms x1 x2 x3 x4 x5 x6 x7 x8
syms M m F1 F2 g L d Ikv Ip F_wind 
syms c_x c_y c_fi c_alfa 

x1_dot = x5;
x2_dot = x6;
x3_dot = x7;
x4_dot = x8;

x5_dot = (cos(x4)*(c_alfa*x8 + d*g*m*sin(x4)))/(- d*m*cos(x4)^2 - d*m*sin(x4)^2 + M*d + d*m) - ((- m*sin(x4)^2 + M + m)*(d*m*sin(x4)*x8^2 + F_wind - sin(x3)*(F1 + F2) - c_x*x5))/(m^2*cos(x4)^2 - 2*M*m + m^2*sin(x4)^2 - M^2 - m^2 + M*m*cos(x4)^2 + M*m*sin(x4)^2) + (m*cos(x4)*sin(x4)*(d*m*cos(x4)*x8^2 - cos(x3)*(F1 + F2) + c_y*x6 + g*(M + m)))/(m^2*cos(x4)^2 - 2*M*m + m^2*sin(x4)^2 - M^2 - m^2 + M*m*cos(x4)^2 + M*m*sin(x4)^2);
x6_dot = (sin(x4)*(c_alfa*x8 + d*g*m*sin(x4)))/(- d*m*cos(x4)^2 - d*m*sin(x4)^2 + M*d + d*m) + ((- m*cos(x4)^2 + M + m)*(d*m*cos(x4)*x8^2 - cos(x3)*(F1 + F2) + c_y*x6 + g*(M + m)))/(m^2*cos(x4)^2 - 2*M*m + m^2*sin(x4)^2 - M^2 - m^2 + M*m*cos(x4)^2 + M*m*sin(x4)^2) - (m*cos(x4)*sin(x4)*(d*m*sin(x4)*x8^2 + F_wind - sin(x3)*(F1 + F2) - c_x*x5))/(m^2*cos(x4)^2 - 2*M*m + m^2*sin(x4)^2 - M^2 - m^2 + M*m*cos(x4)^2 + M*m*sin(x4)^2);
x7_dot = -(c_fi*x7 - L*(F1 - F2))/Ikv;
x8_dot = (sin(x4)*(d*m*cos(x4)*x8^2 - cos(x3)*(F1 + F2) + c_y*x6 + g*(M + m)))/(- d*m*cos(x4)^2 - d*m*sin(x4)^2 + M*d + d*m) - (cos(x4)*(d*m*sin(x4)*x8^2 + F_wind - sin(x3)*(F1 + F2) - c_x*x5))/(- d*m*cos(x4)^2 - d*m*sin(x4)^2 + M*d + d*m) - ((M + m)*(c_alfa*x8 + d*g*m*sin(x4)))/(d*m*(- d*m*cos(x4)^2 - d*m*sin(x4)^2 + M*d + d*m));

% P.S. Я проверил якобианы и подстановку через уравнения выше и 
% уравнения через автоматическое выведение матриц -->кароч можно быть
% спокойным и все уравнения верны

ff = [x1_dot; x2_dot; x3_dot; x4_dot; x5_dot; x6_dot; x7_dot; x8_dot];
ff = subs(ff, [F_wind, c_x, c_y, c_fi, c_alfa], [ 0 0 0 0 0]);

X = [x1 x2 x3 x4 x5 x6 x7 x8]; % vektor stavu
U = [F1, F2]; % vektor vstupu
% Я оказывается чуть по тупому сделал с входами, но думаю роли не играет

Aj = jacobian(ff, X);
Bj = jacobian(ff, U);

%% Singularni body
Xs = [0 0 0 0 0 0 0 0];
Us = [(M+m)/2 (M+m)/2];

Aj = simplify(subs(Aj, [X, U], [Xs, Us]));
Bj = simplify(subs(Bj, [X, U], [Xs, Us]));

%% Linearni popis
Ac = subs(Aj, [M m g L d Ikv Ip], [0.5 0.01 9.81 0.086 0.1 0.00025 1.0000e-04]);
Bc = subs(Bj, [M m g L d Ikv Ip], [0.5 0.01 9.81 0.086 0.1 0.00025 1.0000e-04]);

Ac = double(Ac)
Bc = double(Bc)
Cc = eye(4,8)

%% Riditelnost a pozorovatelnost
R = ctrb(Ac, Bc);
rank(R) % riditelny

P = obsv(Ac, Cc);
rank(P) % pozorovatelny

% Ну бля в 2Д все однозначно и изи бля...а я ебусь с 3д

