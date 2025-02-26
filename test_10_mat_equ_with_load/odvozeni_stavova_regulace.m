% 25.02.2025
% Navrch stavove zpetne vazby pro soustavu kvadrokoptery
% se zavazim

% Asi tady bude 2 zpusoby-> pole placement a LQR (tenhle jeste neumim)

%% State Feedback 
% Rozsirena stavova regulace s pozorovatelem (Luemberguv)

% Analyza stability vychoziho systemu
% Matice Ac a Bc z odvozeni_nelin_rovnic_INERTIA_LOAD.mlx, POKUD SE ZMENI,
% NUTNE RUCNE ZMENIT TADY:
syms M m g d Ip Ixx Iyy Izz
Ac = [
0, 0, 0,  0,                                                0, 0,                                        0, 0, 1, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 1, 0, 0, 0, 0, 0, 0;
0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 1, 0, 0, 0, 0, 0;
0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 1, 0, 0, 0, 0;
0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 1, 0, 0, 0;
0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 1, 0, 0;
0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 0, 1, 0;
0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 0, 0, 1;
0, 0, 0,  0, (g*(M + m)*(m*d^2 + Ip))/(M*m*d^2 + Ip*m + Ip*M), 0,      (d^2*g*m^2)/(M*m*d^2 + Ip*m + Ip*M), 0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0, -g,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,  0,         -(d*g*m*(M + m))/(M*m*d^2 + Ip*m + Ip*M), 0, -(d*g*m*(M + m))/(M*m*d^2 + Ip*m + Ip*M), 0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0,  0,                                                0, 0,                                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

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
Ac = subs(Ac, [M Ixx Iyy Izz m d Ip g], [3.3 1.1 2.989 3.9 1 1 1*1^2 9.81]);
Bc = subs(Bc, [M Ixx Iyy Izz m d Ip g], [3.3 1.1 2.989 3.9 1 1 1*1^2 9.81]);

Ac = double(Ac); % a tohle uz muzeme analyzovat
Bc = double(Bc);
Cc = eye(8, 16); % na vystup pouze poloha, orientace a uhly zavazi

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
% //ну это понятно, собственные числа пиздец//

% Je system riditelny?
R = ctrb(Ac, Bc);
rank(R) % --> 14...hm...co dal?

% Je system pozorovatelny ?
P = obsv(Ac, Cc);
rank(P) % --> 16, tohle uz super