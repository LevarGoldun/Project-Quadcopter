% 03.03.2025
% Navrch stavove zpetne vazby pro soustavu kvadrokoptery
% se zavazim S JINYM ODECNEM UHLU ZAVAZI 
% (!!! odvozeni_nelin_rovnic_INERTIA_LOAD_OTHER_ANGLES.mlx)

% Asi tady bude 2 zpusoby-> pole placement a LQR (tenhle jeste neumim)

%% State Feedback 
% Rozsirena stavova regulace s pozorovatelem (Luemberguv)

% Analyza stability vychoziho systemu
% Matice Ac a Bc z odvozeni_nelin_rovnic_INERTIA_LOAD_OTHER_ANGLES.mlx, 
% POKUD SE ZMENI, NUTNE RUCNE ZMENIT TADY:
syms M m g d Ip Ixx Iyy Izz

Ac = [
0, 0, 0,                 0,                  0, 0,                  0,                  0, 1, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,                 0,                  0, 0,                  0,                  0, 0, 1, 0, 0, 0, 0, 0, 0;
0, 0, 0,                 0,                  0, 0,                  0,                  0, 0, 0, 1, 0, 0, 0, 0, 0;
0, 0, 0,                 0,                  0, 0,                  0,                  0, 0, 0, 0, 1, 0, 0, 0, 0;
0, 0, 0,                 0,                  0, 0,                  0,                  0, 0, 0, 0, 0, 1, 0, 0, 0;
0, 0, 0,                 0,                  0, 0,                  0,                  0, 0, 0, 0, 0, 0, 1, 0, 0;
0, 0, 0,                 0,                  0, 0,                  0,                  0, 0, 0, 0, 0, 0, 0, 1, 0;
0, 0, 0,                 0,                  0, 0,                  0,                  0, 0, 0, 0, 0, 0, 0, 0, 1;
0, 0, 0,                 0,      (g*(M + m))/M, 0,            (g*m)/M,                  0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,    -(g*(M + m))/M,                  0, 0,                  0,            (g*m)/M, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,                 0,                  0, 0,                  0,                  0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,                 0,                  0, 0,                  0,                  0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,                 0,                  0, 0,                  0,                  0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,                 0,                  0, 0,                  0,                  0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,                 0, -(g*(M + m))/(M*d), 0, -(g*(M + m))/(M*d),                  0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0, (g*(M + m))/(M*d),                  0, 0,                  0, -(g*(M + m))/(M*d), 0, 0, 0, 0, 0, 0, 0, 0];

Bc = [
        0,     0,     0,     0;
        0,     0,     0,     0;
        0,     0,     0,     0;
        0,     0,     0,     0;
        0,     0,     0,     0;
        0,     0,     0,     0;
        0,     0,     0,     0;
        0,     0,     0,     0;
        0,     0,     0,     0;
        0,     0,     0,     0;
1/(M + m),     0,     0,     0;
        0, 1/Ixx,     0,     0;
        0,     0, 1/Iyy,     0;
        0,     0,     0, 1/Izz;
        0,     0,     0,     0;
        0,     0,     0,     0];

% take parametry nutne rucne menit
Ac = subs(Ac, [M Ixx Iyy Izz m d g], [2 1.0247 1.0247 0.0455 1 1 9.81]);
Bc = subs(Bc, [M Ixx Iyy Izz m d g], [2 1.0247 1.0247 0.0455 1 1 9.81]);

Ac = double(Ac); % a tohle uz muzeme analyzovat
Bc = double(Bc);
Cc = eye(8, 16); % na vystup pouze poloha, orientace a uhly zavazi
% ale pro navrch stavove regulace potrebujeme upravenou matici C
Cc_ = [
    1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0;
    0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0;
    0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0;
    0     0     0     0     0     1     0     0     0     0     0     0     0     0     0     0];

Dc = 0; %

ev = eig(Ac);

% figure;
% plot(real(ev), imag(ev), '*', 'MarkerFaceColor', 'b');
% grid on;
% xlabel('Real Part');
% ylabel('Imaginary Part');
% title('Eigenvalues with Imaginary Axis');
% yline(0, '--k');
% xline(0, '--k');
% axis equal;
% //ну это понятно, собственные числа//

% Je system riditelny?
R = ctrb(Ac, Bc);
% rank(R) --> 16, super

% Je system pozorovatelny ?
P = obsv(Ac, Cc_);
% rank(P) --> 16, super

% Rozsireny stavovy popis -->
% --> referencni x, y, z, yaw
% --> +4 integracnich clenu v rozsirenem popisu
Ac_ex = [Ac, zeros(16, 4); Cc_, zeros(4, 4)];
Bc_ex = [Bc; zeros(4, 4)];

syms x(t) y(t) z(t) phi(t) theta(t) psi(t) alpha(t) beta(t)
syms Ix_ref Iy_ref Iz_ref Iyaw_ref
q = transpose([x y z phi theta psi alpha beta]);
q_dot = diff(q,1);
X_ex = [q; q_dot; [Ix_ref;Iy_ref;Iz_ref;Iyaw_ref]];

% Volba polu a vypocet koeficientu (16+4ref)
% poles1 = [-1-1i;-1+1i;-2; -1-1.1i;-1+1.1i;-2.1; -0.5;-0.51;
%          -3.1;-3.2;-3.3; -4.1;-4.2;-4.3; -0.66;-0.67;
%          -1.7; -1.8; -1.9; -5]/10; % negunguji

% poles2 = [-4-3j;-4+3j; -3.5-3j;-3.5+3j; -3-2.5j;-3+2.5j;
%           -1.5-1j;-1.5+1j; -1-0.8j;-1+0.8j; -0.5-0.6j;-0.5+0.6j;
%           -3.5+2.5j;-3.5-2.5j; -3-2j;-3+2j;
%           -5; -4.5; -3.8; -1];

poles2 = [-4;-4.1;-4.2; 
          -3.5+3j;-3.5-3j;-2;
          -1.5-1j;-1.5+1j; 

          -1-0.8j;-1+0.8j;-0.5-0.6j;
          -0.5+0.6j;-0.4;-2.5;
          -3-2j;-3+2j;

          -5; -4.5; -3.8; -1];

% poly pro pozorovatele 2-6x rychlejsi
poles_obs = poles2(1:16)*5;

% Koeficietnty pro zpetnou vazbu
K_ex_other_angles = place(Ac_ex, Bc_ex, poles2);
ki_oa = K_ex_other_angles(:, 17:20); % zesileni pro integracni cleny
kp_oa = K_ex_other_angles(:, 1:16); % zesileni pro stavove cleny

% Koeficienty pro pozorovatele - vyuzit princip duality
% Take pozor je pouzita jina matice C!!! (vychozi)
% protoze merime polohu, orientace a 2 uhly zavazi
L_observer = place(Ac', Cc', poles_obs)';



%% LQR
% asi s nekonecnym horizontem, zatim nechapu rozdil
% Q - pro stavy
% R - pro vstupy
% [x;y;z;roll;pitch;yaw;alpha;beta;+derivace;+x_ref;y_ref;z_ref;yaw_ref]

% vahy pro stavy (8x)
q_weight = [1 1 1 10 10 10 100 100];

% vahy pro derivace stavu (8x)
q_dot_weight = [1 1 1 1 1 1 100 100];

% vahy pro integracni cleny (4x)
ref_weight = [100 1 1 100];

Q1 = diag([q_weight, q_dot_weight, ref_weight]);

R1 = diag([0.01; 0.01; 0.01; 10]);

[K_ex_lqr,~,Plqr] = lqr(Ac_ex, Bc_ex, Q1,R1);
ki_lqr = K_ex_lqr(:, 17:20); % zesileni pro integracni cleny
kp_lqr = K_ex_lqr(:, 1:16); % zesileni pro stavove cleny