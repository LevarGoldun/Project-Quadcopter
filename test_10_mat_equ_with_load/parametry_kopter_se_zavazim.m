% 24.02.2025
% 04.03.2025 - nove parametry pro v2
% Parametry pro odvozeni_nelin_rovnic_INERTIA_LOAD.mlx a
% kopter_se_zavazim_simulace.slx

%% Parametry

M = 2; %[kg] hmotnost kvadrokoptery

% momenty setrvacnosti, predpokladame symetrii kvadrokoptery
Ixx = 1.0247; %[kg*m2]
Iyy = 1.0247;
Izz = 0.0455;
I = [Ixx, 0, 0;
     0, Iyy, 0;
     0, 0, Izz];

m = 1; %[kg] hmotnost zavazi
d = 1; %[m] delka lana
Ip = m*d^2; %[kg*m2] setrvacnost zavazi (hm bod)

g = 9.81;
L = 0.2051; %[m] polovicni delka kvadrokoptery (rameno od hmotneho bodu)
% как блять до этого для большего квадрокоптера было 0.086 м я хз...

k_thrust = 0.1; % koeficient umernosti pro generovani tahove sily
k = 0.01; % soucinitel odporu vzduchu
b_moment = 0.01; % koeficient umernosti odporoveho momentu vrtule

%% Inicializace
xyz_init = [0; 0; 0]; %pp poloha
uhly_init = [0; 0; 0]; %pp orientace
zavazi_init = [0; 0]; %pp alpha a beta zavazi

xyz_dot_init = [0;0;0];
uhly_dot_init = [0;0;0];
zavazi_dot_init = [0;0];

Xinit_matrix = [xyz_init; uhly_init; zavazi_init]; % pro maticovy tvar
Xinit_ss = [Xinit_matrix; [0 0 0 0 0 0 0 0]'];

% singularni body pro linearni state-space se zavazim (pro vypocet delt)
Xs_p = [0;0;0; 0;0;0; 0;0; 0;0;0; 0;0;0; 0;0];
Us_p = [(M+m)*g; 0; 0; 0];