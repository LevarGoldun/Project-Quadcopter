% 22.03.2025
% Kopie souboru z test_10_mat_equ_with_load

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
% как блять до этого для большего квадрокоптера было 0.086 м я хз...

k_thrust = 2.3e-3; % koeficient umernosti pro generovani tahove sily
% k = 0.1; % soucinitel odporu vzduchu
b_moment = 5.4e-6; % koeficient umernosti odporoveho momentu vrtule

%% Inicializace
xyz_init = [0; 0; 0]; %pp poloha [m]
uhly_init = [0; 0; 0]; %pp orientace [rad]
zavazi_init = [0; 0]; %pp alpha a beta zavazi [rad]

xyz_dot_init = [0;0;0];
uhly_dot_init = [0;0;0];
zavazi_dot_init = [0;0];

Xinit_matrix = [xyz_init; uhly_init; zavazi_init]; % pro maticovy tvar
Xinit_ss = [Xinit_matrix; [0 0 0 0 0 0 0 0]']; % pro state-space

% singularni body pro linearni state-space se zavazim (pro vypocet delt)
Xs_p = [0;0;0; 0;0;0; 0;0; 0;0;0; 0;0;0; 0;0];
Us_p = [(M+m)*g; 0; 0; 0];
% singularni bod pro vstupy ve tvaru otacek^2 rotoru - jmenovite otacky^2 
% pro rovnovaznou polohu
ms2 = (M+m)*g/(4*k_thrust); %[RPS^2]
Ums_p = [ms2; ms2; ms2; ms2];