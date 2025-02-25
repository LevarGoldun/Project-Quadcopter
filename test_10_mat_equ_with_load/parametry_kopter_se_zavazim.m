% 24.02.2025 (ZATIM NEMENIL JSEM PARAMETRY)
% Parametry pro odvozeni_nelin_rovnic_INERTIA_LOAD.mlx a
% kopter_se_zavazim_simulace.slx

%% Parametry

M = 3.3; %[kg] hmotnost kvadrokoptery

% momenty setrvacnosti, predpokladame symetrii kvadrokoptery
Ixx = 1.1; %[kg*m2]
Iyy = 2.989;
Izz = 3.978;
I = [Ixx, 0, 0;
     0, Iyy, 0;
     0, 0, Izz];

m = 1; %[kg] hmotnost zavazi
d = 1; %[m] delka lana
Ip = m*d^2; %[kg*m2] setrvacnost zavazi (hm bod)

g = 9.81;
L = 0.086; %[m] polovicni delka kvadrokoptery (rameno od hmotneho bodu)

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

% singularni body pro linearni state-space (pro vypocet delt)
Xs = [0;0;0; 0;0;0; 0;0; 0;0;0; 0;0;0; 0;0];
Us = [M*g; 0; 0; 0];