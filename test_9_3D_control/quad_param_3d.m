% 17.11.2024
% Pohybova rovnice kvadrokoptery v 3D (bez zavazi) dle
% https://andrew.gibiansky.com/blog/physics/quadcopter-dynamics/ (1)
% https://www.youtube.com/watch?v=xCoFaTyn5dg (2)
% a pro kontrolu
% https://dspace.ucuenca.edu.ec/bitstream/123456789/21401/1/IEE_17_Romero%20et%20al.pdf

%% Parametry
% Matice hmotnosti a setrvacnosti z MuJoCo
% MI = [3.3, 0, 0, 0, -0.15, 0;
%      0, 3.3, 0, 0.15, 0, 0;
%      0, 0, 3.3, 0, 0, 0;
%      0, 0.15, 0, 1.1, 0, 0;
%      -0.15, 0, 0, 0, 2.989, 0;
%      0, 0, 00, 0, 0, 3.978];


M = 3.3; %[kg] hmotnost kvadrokoptery

% momenty setrvacnosti, predpokladame symetrii kvadrokoptery
Ixx = 1.1; %[kg*m2]
Iyy = 2.989;
Izz = 3.978;
I = [Ixx, 0, 0;
     0, Iyy, 0;
     0, 0, Izz];

g = 9.81;
L = 0.086; %[m] polovicni delka kvadrokoptery (rameno od hmotneho bodu)
k_thrust = 0.1; % koeficient umernosti pro generovani tahove sily
k = 0.01; % soucinitel odporu vzduchu
b_moment = 0.01; % koeficient umernosti odporoveho momentu vrtule
%% Inicializace
xyz_init = [0; 0; 0]; %pp poloha
uhly_init = [0; 0; 0]; %pp orientace
xyz_dot_init = [0;0;0];
uhly_dot_init = [0;0;0];

Xinit = [xyz_init; uhly_init; xyz_dot_init; uhly_dot_init]; % pro Newton Euler tvar
Xinit_matrix = [xyz_init; uhly_init]; % pro maticovy tvar
Xinit_ss = Xinit;

