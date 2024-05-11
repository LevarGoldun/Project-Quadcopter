% Quadcopter Parameters KCC 4-2023
g = 9.81;                     % gravity constant (m/s^2)
m = 0.468;                  % mass of helicopter kg
l = 0.225;                    % distance between a rotor
                                   % and quadcopter CG (m)
k = 2.98e-6;                % lift constant
b = 1.14e-7;                % drag constant
% drag force coefficents
Ax = 0.25; % kg/s
Ay = 0.25;
Az = 0.25;
% inertia matrix
Ix = 4.856e-3; %kgm^2
Iy = 4.856e-3;
Iz = 8.801e-3;
% paramters of the PD controller
KpT = 4;
KdT = 2;
KiT = 0;
KpR = 1;
KdR = 3;
KiR = 0;

