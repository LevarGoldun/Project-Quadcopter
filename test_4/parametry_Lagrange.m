%% Parametry
g = 9.81;
L = 0.086; %[m] poloviční délka kvadrokoptéry
d = 0.1; %[m] délka lana

M = 0.5; %[kg]
m = 0.01; %[kg]
Ikv = 0.00025; %[kg*m^2]
Ip = m*d^2; % setrvačnost hmotného bodu vzdáleného od osy rotace

% k = 0.1; % x a y tlumení kvadrokoptéry
% kp = 0.01; % xp a yp tlumení kyvadla


% zaprve smodelujeme bez zadneho tlumeni
%pro model Newton-Euler
k=0;
kp=0;
%pro model lagrange
c_x=0;
c_y=0;
c_fi=0;
c_alfa=0;
