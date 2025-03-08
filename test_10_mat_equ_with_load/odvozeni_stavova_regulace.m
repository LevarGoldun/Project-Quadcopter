% 25.02.2025
% Navrch stavove zpetne vazby pro soustavu kvadrokoptery
% se zavazim (!!! pro odvozeni_nelin_rovnic_INERTIA_LOAD.mlx)

% Asi tady bude 2 zpusoby-> pole placement a LQR (tenhle jeste neumim)

%% State Feedback 
% Rozsirena stavova regulace s pozorovatelem (Luemberguv)

% Analyza stability vychoziho systemu
% Matice Ac a Bc z odvozeni_nelin_rovnic_INERTIA_LOAD.mlx, POKUD SE ZMENI,
% NUTNE RUCNE ZMENIT TADY:
syms M m g d Ip Ixx Iyy Izz

% Matice Ac a Bc pro sing. bod v 0 (nulech) -> bohuzel neni riditelnost
% Ac = [
% 0, 0, 0,  0,                                                0, 0,                                        0, 0, 1, 0, 0, 0, 0, 0, 0, 0;
% 0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 1, 0, 0, 0, 0, 0, 0;
% 0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 1, 0, 0, 0, 0, 0;
% 0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 1, 0, 0, 0, 0;
% 0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 1, 0, 0, 0;
% 0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 1, 0, 0;
% 0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 0, 1, 0;
% 0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 0, 0, 1;
% 0, 0, 0,  0, (g*(M + m)*(m*d^2 + Ip))/(M*m*d^2 + Ip*m + Ip*M), 0,      (d^2*g*m^2)/(M*m*d^2 + Ip*m + Ip*M), 0, 0, 0, 0, 0, 0, 0, 0, 0;
% 0, 0, 0, -g,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
% 0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
% 0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
% 0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
% 0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
% 0, 0, 0,  0,         -(d*g*m*(M + m))/(M*m*d^2 + Ip*m + Ip*M), 0, -(d*g*m*(M + m))/(M*m*d^2 + Ip*m + Ip*M), 0, 0, 0, 0, 0, 0, 0, 0, 0;
% 0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
% 
% Bc = [
%         0,     0,     0,     0;
%         0,     0,     0,     0;
%         0,     0,     0,     0;
%         0,     0,     0,     0;
%         0,     0,     0,     0;
%         0,     0,     0,     0;
%         0,     0,     0,     0;
%         0,     0,     0,     0;
%         0,     0,     0,     0;
%         0,     0,     0,     0;
% 1/(M + m),     0,     0,     0;
%         0, 1/Ixx,     0,     0;
%         0,     0, 1/Iyy,     0;
%         0,     0,     0, 1/Izz;
%         0,     0,     0,     0;
%         0,     0,     0,     0];


% Tyhle matice Ac a Bc pro sing. bod v blizkosti nuly pro alpha a beta
% Xs = [0;0;0; 0;0;0; 0.05;0.05; 0;0;0; 0;0;0; 0;0];
% Uz jsou riditelne
Ac = [
0, 0, 0,                                                                                                                                                                                                                                                                                                                                                        0,                                                                                                                                                                                                                                                                                                                                                                                            0, 0,                                                                  0,                                                                  0, 1, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,                                                                                                                                                                                                                                                                                                                                                        0,                                                                                                                                                                                                                                                                                                                                                                                            0, 0,                                                                  0,                                                                  0, 0, 1, 0, 0, 0, 0, 0, 0;
0, 0, 0,                                                                                                                                                                                                                                                                                                                                                        0,                                                                                                                                                                                                                                                                                                                                                                                            0, 0,                                                                  0,                                                                  0, 0, 0, 1, 0, 0, 0, 0, 0;
0, 0, 0,                                                                                                                                                                                                                                                                                                                                                        0,                                                                                                                                                                                                                                                                                                                                                                                            0, 0,                                                                  0,                                                                  0, 0, 0, 0, 1, 0, 0, 0, 0;
0, 0, 0,                                                                                                                                                                                                                                                                                                                                                        0,                                                                                                                                                                                                                                                                                                                                                                                            0, 0,                                                                  0,                                                                  0, 0, 0, 0, 0, 1, 0, 0, 0;
0, 0, 0,                                                                                                                                                                                                                                                                                                                                                        0,                                                                                                                                                                                                                                                                                                                                                                                            0, 0,                                                                  0,                                                                  0, 0, 0, 0, 0, 0, 1, 0, 0;
0, 0, 0,                                                                                                                                                                                                                                                                                                                                                        0,                                                                                                                                                                                                                                                                                                                                                                                            0, 0,                                                                  0,                                                                  0, 0, 0, 0, 0, 0, 0, 1, 0;
0, 0, 0,                                                                                                                                                                                                                                                                                                                                                        0,                                                                                                                                                                                                                                                                                                                                                                                            0, 0,                                                                  0,                                                                  0, 0, 0, 0, 0, 0, 0, 0, 1;
0, 0, 0,                                                                                                                                                             -(d^2*g*m^2*(8*Ip*M*sin(1/5) + 8*Ip*m*sin(1/5) + 4*M*d^2*m*sin(1/5) - 5*M*d^2*m*sin(1/10) - M*d^2*m*sin(3/10)))/(16*(M*m*d^2 + Ip*m + Ip*M)*(2*Ip*m + 2*Ip*M + M*d^2*m - M*d^2*m*cos(1/10))), (g*(Ip^2*M^2 + Ip^2*m^2 + Ip*d^2*m^3 + 2*Ip^2*M*m - 2*Ip*d^2*m^3*sin(1/20)^2 + 2*Ip*d^2*m^3*sin(1/20)^4 + M*d^4*m^3*sin(1/20)^2 - M*d^4*m^3*sin(1/20)^4 + M*d^4*m^3*sin(1/20)^6 + M^2*d^4*m^2*sin(1/20)^2 + 2*Ip*M*d^2*m^2 + Ip*M^2*d^2*m - Ip*M*d^2*m^2*sin(1/20)^2 + Ip*M^2*d^2*m*sin(1/20)^2 + 2*Ip*M*d^2*m^2*sin(1/20)^4))/((M*m*sin(1/20)^2*d^2 + Ip*m + Ip*M)*(M*m*d^2 + Ip*m + Ip*M)), 0,  (d^2*g*m^2*(cos(1/20) + cos(3/20)))/(2*M*m*d^2 + 2*Ip*m + 2*Ip*M), -(d^2*g*m^2*(cos(1/20) - cos(3/20)))/(4*M*m*d^2 + 4*Ip*m + 4*Ip*M), 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0, -(g*(Ip^2*M^2 + Ip^2*m^2 + 2*Ip^2*M*m + 2*Ip*d^2*m^3*sin(1/20)^2 - 2*Ip*d^2*m^3*sin(1/20)^4 + M*d^4*m^3*sin(1/20)^2 - M*d^4*m^3*sin(1/20)^6 + M^2*d^4*m^2*sin(1/20)^2 + Ip*M*d^2*m^2 + Ip*M^2*d^2*m + 3*Ip*M*d^2*m^2*sin(1/20)^2 + Ip*M^2*d^2*m*sin(1/20)^2 - 2*Ip*M*d^2*m^2*sin(1/20)^4))/((M*m*sin(1/20)^2*d^2 + Ip*m + Ip*M)*(M*m*d^2 + Ip*m + Ip*M)),                                                                                                                                                                                                  (d^2*g*m^2*(8*Ip*M*sin(1/5) + 8*Ip*m*sin(1/5) + 4*M*d^2*m*sin(1/5) - 5*M*d^2*m*sin(1/10) - M*d^2*m*sin(3/10)))/(16*(M*m*d^2 + Ip*m + Ip*M)*(2*Ip*m + 2*Ip*M + M*d^2*m - M*d^2*m*cos(1/10))), 0, -(d^2*g*m^2*(sin(1/20) - sin(3/20)))/(2*M*m*d^2 + 2*Ip*m + 2*Ip*M),  (d^2*g*m^2*(sin(1/20) + sin(3/20)))/(4*M*m*d^2 + 4*Ip*m + 4*Ip*M), 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,                                                                                                                                                                                                                                                                                           -(d^2*g*m^2*(cos(1/20) - cos(1/20)^3))/(M*m*d^2 + Ip*m + Ip*M),                                                                                                                                                                                                                                                                                                                                (d^2*g*m^2*(sin(1/20) - sin(1/20)^3))/(M*m*d^2 + Ip*m + Ip*M), 0,                      (d^2*g*m^2*sin(1/10))/(M*m*d^2 + Ip*m + Ip*M),                                                                  0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,                                                                                                                                                                                                                                                                                                                                                        0,                                                                                                                                                                                                                                                                                                                                                                                            0, 0,                                                                  0,                                                                  0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,                                                                                                                                                                                                                                                                                                                                                        0,                                                                                                                                                                                                                                                                                                                                                                                            0, 0,                                                                  0,                                                                  0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,                                                                                                                                                                                                                                                                                                                                                        0,                                                                                                                                                                                                                                                                                                                                                                                            0, 0,                                                                  0,                                                                  0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,                                                                                                                                                                                                                                                                                                    (d*g*m*sin(1/10)*(M + m))/(2*(M*m*d^2 + Ip*m + Ip*M)),                                                                                                                                                                                                                                                                                                                                    (d*g*m*(M + m)*(sin(1/20)^2 - 1))/(M*m*d^2 + Ip*m + Ip*M), 0,                 -(d*g*m*cos(1/20)*(M + m))/(M*m*d^2 + Ip*m + Ip*M),                                                                  0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,                                                                                                                                                                                                                                                                                (d*g*m*sin(1/10)*(M + m))/(2*Ip*m + 2*Ip*M + M*d^2*m - M*d^2*m*cos(1/10)),                                                                                                                                                                                                                                                                                                                              (d*g*m*sin(1/20)^2*(M + m))/(M*m*sin(1/20)^2*d^2 + Ip*m + Ip*M), 0,                                                                  0,                                                                  0, 0, 0, 0, 0, 0, 0, 0, 0];
 
Bc = [
                                                                                                                                                                                                                                                                                                                                                                                                                                                            0,     0,     0,     0;
                                                                                                                                                                                                                                                                                                                                                                                                                                                            0,     0,     0,     0;
                                                                                                                                                                                                                                                                                                                                                                                                                                                            0,     0,     0,     0;
                                                                                                                                                                                                                                                                                                                                                                                                                                                            0,     0,     0,     0;
                                                                                                                                                                                                                                                                                                                                                                                                                                                            0,     0,     0,     0;
                                                                                                                                                                                                                                                                                                                                                                                                                                                            0,     0,     0,     0;
                                                                                                                                                                                                                                                                                                                                                                                                                                                            0,     0,     0,     0;
                                                                                                                                                                                                                                                                                                                                                                                                                                                            0,     0,     0,     0;
(d^4*m^4*cos(1/20)^2*sin(1/20)^3 - d^4*m^4*cos(1/20)^2*sin(1/20)^5 - d^4*m^4*cos(1/20)^4*sin(1/20)^3 + Ip*d^2*m^3*cos(1/20)^2*sin(1/20) + M*d^4*m^3*cos(1/20)^2*sin(1/20)^3 + Ip*M*d^2*m^2*cos(1/20)^2*sin(1/20))/((M + m)*(Ip*m + Ip*M + d^2*m^2*sin(1/20)^2 - d^2*m^2*sin(1/20)^4 - d^2*m^2*cos(1/20)^2*sin(1/20)^2 + M*d^2*m*sin(1/20)^2)*(Ip*m + d^2*m^2 + Ip*M - d^2*m^2*cos(1/20)^4 - d^2*m^2*sin(1/20)^2 + M*d^2*m - d^2*m^2*cos(1/20)^2*sin(1/20)^2)),     0,     0,     0;
      (d^4*m^4*cos(1/20)*sin(1/20)^4 - d^4*m^4*cos(1/20)*sin(1/20)^6 - d^4*m^4*cos(1/20)^3*sin(1/20)^4 + Ip*d^2*m^3*cos(1/20)*sin(1/20)^2 + M*d^4*m^3*cos(1/20)*sin(1/20)^4 + Ip*M*d^2*m^2*cos(1/20)*sin(1/20)^2)/((M + m)*(Ip*m + Ip*M + d^2*m^2*sin(1/20)^2 - d^2*m^2*sin(1/20)^4 - d^2*m^2*cos(1/20)^2*sin(1/20)^2 + M*d^2*m*sin(1/20)^2)*(Ip*m + d^2*m^2 + Ip*M - d^2*m^2*cos(1/20)^4 - d^2*m^2*sin(1/20)^2 + M*d^2*m - d^2*m^2*cos(1/20)^2*sin(1/20)^2)),     0,     0,     0;
                                                                                                                                                                                                                                          (Ip*m + d^2*m^2 + Ip*M - d^2*m^2*cos(1/20)^4 + M*d^2*m - d^2*m^2*cos(1/20)^2*sin(1/20)^2)/((M + m)*(Ip*m + d^2*m^2 + Ip*M - d^2*m^2*cos(1/20)^4 - d^2*m^2*sin(1/20)^2 + M*d^2*m - d^2*m^2*cos(1/20)^2*sin(1/20)^2)),     0,     0,     0;
                                                                                                                                                                                                                                                                                                                                                                                                                                                            0, 1/Ixx,     0,     0;
                                                                                                                                                                                                                                                                                                                                                                                                                                                            0,     0, 1/Iyy,     0;
                                                                                                                                                                                                                                                                                                                                                                                                                                                            0,     0,     0, 1/Izz;
                                                                                                                                                                                                                                                                                                                             -(d*m*sin(1/20))/(Ip*m + d^2*m^2 + Ip*M - d^2*m^2*cos(1/20)^4 - d^2*m^2*sin(1/20)^2 + M*d^2*m - d^2*m^2*cos(1/20)^2*sin(1/20)^2),     0,     0,     0;
                                                                                                                                                                                                                                                                                                                                                                                                                                                            0,     0,     0,     0];

% take parametry nutne rucne menit
Ac = subs(Ac, [M Ixx Iyy Izz m d Ip g], [3.3 1.1 2.989 3.9 1 1 1*1^2 9.81]);
Bc = subs(Bc, [M Ixx Iyy Izz m d Ip g], [3.3 1.1 2.989 3.9 1 1 1*1^2 9.81]);

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
rank(R)

% Je system pozorovatelny ?
P = obsv(Ac, Cc_);
rank(P)

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

poles2 = [-4+3j;-4-3j; -3.5-3j;-3.5+3j; -3-2.5j;-3+2.5j;
          -1.5-1j;-1.5+1j; -1-0.8j;-1+0.8j; -0.5-0.6j;-0.5+0.6j;
          -3.5+2.5j;-3.5-2.5j; -3-2j;-3+2j;
          -5; -4.5; -4.2; -3.8];


K_ex = place(Ac_ex, Bc_ex, poles2);
ki = K_ex(:,17:20); % zesileni pro integracni cleny
kp = K_ex(:, 1:16); % zesileni pro stavove cleny

% !!! Dany model nefunguje...nevim, moc velke zesileni
% V druhem modelu s jinym odectem uhlu pro zavazi regulace funguje,
% koeficienty jsou adekvatni
% |
% V
% takze asi budu pracovat s novym modelem
