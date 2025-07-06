% 22.03.2025
% Kopie souboru z test_10_mat_equ_with_load

% 06.07.2025 - zmena hodnot parametru k_thrust a b_moment, nove nominalni
% uhlove rychlosti [rad/s] a otacky [ot/min]
% + pridani hodnot pro Input Shaper

%% Parametry

M = 2; %[kg] hmotnost kvadrokoptery

% momenty setrvacnosti, predpokladame symetrii kvadrokoptery
Ixx = 0.0222; %[kg*m2]
Iyy = 0.0222;
Izz = 0.0429;
% P.S. 1.0221 [kg*m2] pro mujoco model dron+zavazi a zavazi melo velky vliv
I = [Ixx, 0, 0;
     0, Iyy, 0;
     0, 0, Izz];

m = 1; %[kg] hmotnost zavazi
d = 1; %[m] delka lana
Ip = m*d^2; %[kg*m2] setrvacnost zavazi (hm bod)

g = 9.81;
l = 0.2051; %[m] polovicni delka kvadrokoptery (rameno od hmotneho bodu)

% k_thrust = 2.3e-3; % koeficient umernosti pro generovani tahove sily
k_thrust = 9.3e-6; %[N/(rad/s)^2]

% b_moment = 5.4e-6; % koeficient umernosti odporoveho momentu vrtule
b_moment = 3.6e-7;

% hodnoty pro obycejny ZV shaper
A = 0.3919; % nespravna, ale tlumi
% A = 0.6081; % spravna, ale spatne tlumi
T = 0.8682;

%% Inicializace
xyz_init = [0; 0; 2]; %pp poloha [m]
uhly_init = [0; 0; 0]; %pp orientace [rad]
zavazi_init = [0; 0]; %pp alpha a beta zavazi [rad]

xyz_dot_init = [0;0;0];
uhly_dot_init = [0;0;0];
zavazi_dot_init = [0;0];

Xinit_matrix = [xyz_init; uhly_init; zavazi_init]; % pro maticovy tvar
Xinit_ss = [Xinit_matrix; [0 0 0 0 0 0 0 0]']; % pro state-space

% singularni body pro linearni state-space se zavazim (pro vypocet delt)
Xs_p = [0;0;2; 0;0;0; 0;0; 0;0;0; 0;0;0; 0;0];
% v MuJoCo na vysce 2

Us_p = [(M+m)*g; 0; 0; 0];

% singularni bod pro vstupy uhlove rychlosti - omega^2 [rad/s]^2
% pro rovnovaznou polohu
w_square = (M+m)*g/(4*k_thrust); % je to hodnota (rad/s)^2 !!!
Uws_p = [w_square; w_square; w_square; w_square];