% 24.02.2025
% 04.03.2025 - nove parametry pro v2

% 14.03.2025 - byla udelana chyba pri urceni I kvadrokoptery. Mujoco pise
% setrvacnost celeho systemu dron+zavazi. Samotny dron ma jine I, vic dole

% 21.06.2025 - nove koeficienty k, b, nominalni otacky (predtim spatny
% vypocet)
%% Parametry

M = 2; %[kg] hmotnost kvadrokoptery

% momenty setrvacnosti, predpokladame symetrii kvadrokoptery
Ixx = 0.0222; %[kg*m2]
Iyy = 0.0222;
Izz = 0.0429;
I = [Ixx, 0, 0;
     0, Iyy, 0;
     0, 0, Izz];

m = 1; %[kg] hmotnost zavazi
d = 1; %[m] delka lana
Ip = m*d^2; %[kg*m2] setrvacnost zavazi (hm bod) %nepouzivam

g = 9.81;
l = 0.2051; %[m] polovicni delka kvadrokoptery (rameno od hmotneho bodu)

% koeficient umernosti pro generovani tahove sily
k_thrust = 9.3e-6; %[N/(rad/s)^2]

% koeficient umernosti odporoveho momentu vrtule
b_moment = 3.6e-7;

% hodnoty pro obycejny ZV shaper
A = 0.6081; % vic cast DP s vypoctem ZV tvarovace
T = 0.8682;
%% Inicializace
% pp poloha, orientace a vychyleni zavazi -> lze menit v blizkosti Xs, Us
xyz_init = [0; 0; 0]; %pp poloha
uhly_init = [0; 0; 0]; %pp orientace
zavazi_init = [10*pi/180*0; 15*pi/180*0]; %pp alpha a beta zavazi

Xinit_matrix = [xyz_init; uhly_init; zavazi_init]; % pro maticovy tvar
Xinit_ss = [Xinit_matrix; [0 0 0 0 0 0 0 0]']; % pro ss tvar
Uinit = [(M+m)*g; 0; 0; 0]; % pp na aktuatorech (vzdy jako Us)

% hodnoty singularniho bodu, v kterem byla provedena linearizace
% (nemenime) -> pouziva se pro vypocet delt
Xs = [0;0;0; 0;0;0; 0;0; 0;0;0; 0;0;0; 0;0];
Us = [(M+m)*g; 0; 0; 0];
% dX = X - Xs; dU = U - Us

% singularni bod pro vstupy ve tvaru otacek rotoru - jmenovite uhlove rychlosti pro
% rovnovaznou polohu (uhlove rychlosti, rad/s)
w_square = (M+m)*g/(4*k_thrust); % je to hodnota (rad/s)^2 !!!
Uws = [w_square; w_square; w_square; w_square];
