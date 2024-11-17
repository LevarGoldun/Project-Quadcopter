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
b_moment = 0.1; % koeficient umernosti odporoveho momentu vrtule
%% Inicializace
Xinit = [0;0;0;0;0;0;0;0;0;0;0;0];
%% Rovnice (spis priprava)
% Eulerove uhly, XYZ
roll = 0;
pitch = 0;
yaw = 0;

R_x = [1, 0, 0; 
       0, cos(roll), -sin(roll);
       0, sin(roll), cos(roll)];

R_y = [cos(pitch), 0, sin(pitch); 
       0, 1, 0; 
      -sin(pitch), 0, cos(pitch)];

R_z = [cos(yaw), -sin(yaw), 0; 
       sin(yaw), cos(yaw), 0; 
       0, 0, 1];

R = R_x * R_y * R_z;

% Matice pro transformace derivaci Eulerovych uhlu do uhlove rychlosti
% v soustave tela (pochopil jsem ji vyznam pomoci ChatGPT)
Rw = [1, 0, -sin(pitch);
      0, cos(roll), cos(pitch)*sin(roll);
      0 -sin(roll), cos(pitch)*cos(roll)];

% m(x;y;z) = (0;0;-mg) + R*TB + FD
% FD = -k*(dx;dy;dz) odpor vzduchu
% TB = (0;0;k_thrust*(w1^2+w2^2+w3^2+w4^2)

%I*(dwx;dwy;dwz) + (wx;wy;wz)x(I*(wx;wy;wz) = Tau
% Tau = (L*k_thrust*() ; L*k_thrust*(); b_moment*() )