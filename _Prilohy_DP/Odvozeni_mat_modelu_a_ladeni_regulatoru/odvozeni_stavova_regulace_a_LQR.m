% 03.03.2025
% Navrch stavove zpetne vazby pro soustavu kvadrokoptery
% se zavazim S JINYM ODECNEM UHLU ZAVAZI 

% 21.06.2025 - nove hodnoty k_thrust a b_moment

% Asi tady bude 2 zpusoby-> pole placement a LQR

run("parametry_kopter_se_zavazim.m")
%% State Feedback 
% Rozsirena stavova regulace s pozorovatelem (Luemberguv)

% Analyza stability vychoziho systemu
% Matice Ac a Bc z odvozeni_nelin_rovnic_OTHER_ANGLES.mlx, 
% bod linearizace Xs=[0;0;...], Us = [(M+m)*g; 0;0;0]
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

% matice Bmc pro vstupy ve tvaru druhych mocnic otacek rotoru !!!
% Ostatni postupy asi stejne, jenom je zmenena matice B
% P.S. Matice Amc je stejna jako matice Ac
syms k_thrust b_moment l
Bmc = [
                0,                 0,                 0,                0;
                0,                 0,                 0,                0;
                0,                 0,                 0,                0;
                0,                 0,                 0,                0;
                0,                 0,                 0,                0;
                0,                 0,                 0,                0;
                0,                 0,                 0,                0;
                0,                 0,                 0,                0;
                0,                 0,                 0,                0;
                0,                 0,                 0,                0;
 k_thrust/(M + m),  k_thrust/(M + m),  k_thrust/(M + m), k_thrust/(M + m);
 (k_thrust*l)/Ixx, -(k_thrust*l)/Ixx, -(k_thrust*l)/Ixx, (k_thrust*l)/Ixx;
-(k_thrust*l)/Iyy, -(k_thrust*l)/Iyy,  (k_thrust*l)/Iyy, (k_thrust*l)/Iyy;
     b_moment/Izz,     -b_moment/Izz,      b_moment/Izz,    -b_moment/Izz;
                0,                 0,                 0,                0;
                0,                 0,                 0,                0];

% take parametry nutne rucne menit
Ac = subs(Ac, [M Ixx Iyy Izz m d g], [2 0.0222 0.0222 0.0429 1 1 9.81]);
Bc = subs(Bc, [M Ixx Iyy Izz m d g], [2 0.0222 0.0222 0.0429 1 1 9.81]);
Bmc = subs(Bmc, [M Ixx Iyy Izz m d g k_thrust b_moment l], [2 0.0222 0.0222 0.0429 1 1 9.81 9.3e-6 3.6e-7 0.2051]);

Ac = double(Ac); % a tohle uz muzeme analyzovat
Bc = double(Bc);
Bmc = double(Bmc);

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

% Je system riditelny?
% R = ctrb(Ac, Bc);
% rank(R) %--> 16, super

% Je system pozorovatelny ?
% P = obsv(Ac, Cc_);
% rank(P) %--> 16, super
% rank(obsv(Ac, Cc)); --> take 16, super

% Rozsireny stavovy popis -->
% --> referencni x, y, z, yaw
% --> +4 integracnich clenu v rozsirenem popisu
Ac_ex = [Ac, zeros(16, 4); Cc_, zeros(4, 4)];
Bc_ex = [Bc; zeros(4, 4)];
Bmc_ex = [Bmc; zeros(4, 4)];
rank(ctrb(Ac_ex, Bc_ex));
% --> 20, super, je riditelny

% Volba polu a vypocet koeficientu (16+4ref)
poles1 = [-1; -1.1; -1.2;
          -2-2j; -2+2j; -2.2;
          -3; -3.1;
          -1.3; -1.4; -1.5;
          -2.1-3j; -2.1+3j; -2.3;
          -3.2; -3.3;
          -25; -25.01; -25.02; -25.03];

poles2 = [
-2.5+2.5j; -2.5-2.5j;
-4+2j; -4-2j;
-3+3j; -3-3j;
-3.2+3j; -3.2-3j;
-2.8; -2.9; -3.1; -3.2;
-3.8; -3.9; -4.1; -4.2;
-25; -25.01; -25.02; -25.03
];

poles3 = [
-1+0.5j; -1-0.5j;
-1.2+1.1j; -1.2-1.1j;
-1.4+2j; -1.4-2j;
-1.6+4j; -1.6-4j;
-1; -1.1; -1.2; -1.3; -1.4; -1.5; -1.6; -0.5;
-25; -25.01; -25.02; -25.03
];

% poles4 = [
% -4+20j; -4-20j;
% -4+2.5j; -4-2.5j;
% -4.5+1.5j; -4.5-1.5j;
% -4.5+1.55j; -4.5-1.55j;
% -3.1; -3.3; -3.5; -3.7; -3.9; -4.1; -4.3; -4.5;
% -15; -15.01; -15.02; -15.03
% ];

% ChatGPT doporuceni
% moc rychle
% polesSada0 = [-2.5 + 2.5i, -2.5 - 2.5i,...
%     -3.0 + 3.0i, -3.0 - 3.0i,...  
%     -3.5 + 3.5i, -3.5 - 3.5i,...  
%     -4.0 + 4.0i, -4.0 - 4.0i,...   
%     -5, -6, -7, -8,...           
%     -9, -10, -11, -12, -13, -14, -15, -16];

polesSada1 = [
    -0.6 + 0.6i, -0.6 - 0.6i,...  
    -0.6 + 0.7i, -0.6 - 0.7i,...  
    -0.8 + 0.5i, -0.8 - 0.5i,...  
    -1.0 + 0.7i, -1.0 - 0.7i,... 
    -2.0 + 2.0i, -2.0 - 2.0i,...  
    -2.5 + 1.5i, -2.5 - 1.5i,...  
    -3, -3.1, -3.2, -3.3,...            
    -25, -25.01, -25.02, -25.03 
];

polesSada2 = [
    -1.5 + 1.0i, -1.5 - 1.0i,...  
    -1.5 + 1.2i, -1.5 - 1.2i,...  
    -2.0 + 0.8i, -2.0 - 0.8i,...  
    -2.5 + 1.0i, -2.5 - 1.0i,...  
    -4.0 + 3.0i, -4.0 - 3.0i,... 
    -4.5 + 2.5i, -4.5 - 2.5i,...  
    -5, -5.1, -5.2, -5.3,...           
    -25, -25.01, -25.02, -25.03 
];

% Finalni volba polu pro DP
poles_smooth = [
    -0.9 + 1.2j, -0.9 - 1.2j,...
    -1.1 + 0.9j, -1.1 - 0.9j,...   
    -1.3 + 1.5j, -1.3 - 1.5j,... 
    -1.6, -1.7, -1.8, -1.9,...     
    -2.0 + 1.2j, -2.0 - 1.2j,...
    -2.2, -2.5, -2.7, -2.9,...     
    -25, -25.01, -25.02, -25.03
];

poles_aggressive = [
    -2.5 + 3.0j, -2.5 - 3.0j,...   
    -3.0 + 3.5j, -3.0 - 3.5j,... 
    -3.2 + 2.5j, -3.2 - 2.5j,... 
    -3.5, -3.6, -3.7, -3.8,...    
    -4.0 + 2j, -4.0 - 2j,...  
    -4.2, -4.4, -4.6, -4.8,...
    -25, -25.01, -25.02, -25.03
];


% Vyber sady polu
% poles = poles1;
% poles = poles2;
% poles = poles3;
% poles = poles4;
% poles = polesSada0;
% poles = polesSada1;
% poles = polesSada2;

% !!! POUZIVAM TOHLE !!!
% odkomentovaz pozadovanou sadu polu pro simulaci
% poles = poles_smooth;
poles = poles_aggressive;

% vykresleni poloh polu URO a vychoziho systemu
% figure;
% set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 16 5]);
% hold on
% plot(real(ev), imag(ev), 'bx', 'MarkerSize', 10, 'LineWidth', 1.2);
% plot(real(poles),imag(poles),"rx", 'MarkerSize', 10, 'LineWidth', 1.2)
% yline(0, '--k', 'LineWidth', 1);
% xline(0, '--k', 'LineWidth', 1);
% xlabel('Re(s)', 'FontSize', 12, 'FontName', 'Times New Roman');
% ylabel('Im(s)', 'FontSize', 12, 'FontName', 'Times New Roman');
% legend({'Výchozí systém', 'URO', '', ''}, ...
%     'FontSize', 12, 'FontName', 'Times New Roman', ...
%     'Location', 'best');
% grid on
% ylim([-4, 4])
% set(gca, 'LineWidth', 1.5, 'FontSize', 12, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman')
% tightfig;
% saveas(gcf, fullfile('stavova_regulace_pmap.svg'), 'svg');

% poly pro pozorovatele 2-6x rychlejsi nez nejpomalejsi v poles
% minmaxpoles = flip(sort(poles)); % od min do max polu
poles_obs = poles(1:16)*5; 

% Koeficietnty pro zpetnou vazbu (sily a momenty)
K_ex_other_angles = place(Ac_ex, Bc_ex, poles);
Ki = K_ex_other_angles(:, 17:20); % zesileni pro integracni cleny
Kp = K_ex_other_angles(:, 1:16); % zesileni pro stavove cleny

% Koeficietnty pro zpetnou vazbu ( (rad/s)^2)
% Kmot_ex_other_angles = place(Ac_ex, Bmc_ex, poles);
% kimot = Kmot_ex_other_angles(:, 17:20);
% kpmot = Kmot_ex_other_angles(:, 1:16);

% aby dron ne padal (inicializace integratoru)
xss= Xinit_ss;
uss = Uinit;
% umss = Uws;
init_int_ref = -Ki\(Kp*xss+uss); % pro vstup sily a momenty
init_int_dref = -Ki\((Uinit-Us)+Kp*(Xinit_ss-Xs));

% init_int_ref_motor = -kimot\(kpmot*xss + umss); % pro uhlove rychlosti^2

% Koeficienty pro pozorovatele - vyuzit princip duality
% Take pozor je pouzita jina matice C!!! (vychozi)
% protoze merime polohu, orientace a 2 uhly zavazi
L_obs = place(Ac', Cc', poles_obs)';



%% LQR
% Budu s nekonecnym horizontem, 
% Q - pro stavy
% R - pro vstupy
% [x;y;z;roll;pitch;yaw;alpha;beta;+derivace;+x_ref;y_ref;z_ref;yaw_ref]

% % vahy pro stavy (8x)
% q_weight = [1 1 1 1 1 1 1 1];
% % vahy pro derivace stavu (8x)
% q_dot_weight = [1 1 1 1 1 1 1 1];
% % vahy pro integracni cleny (4x)
% ref_weight = [1 1 1 1];
% 
% Q = diag([q_weight, q_dot_weight, ref_weight]);
% 
% % vahy pro vstupy (sily a momenty)
% R = diag([1; 1; 1; 1])/10;

% sada = "Brysonovo pravidlo";
% sada = "Penalizace poloh";
% sada = "Penalizace vstupu";
% sada = "ChatGPT Мягкий, экономичный контроль";
% sada = "ChatGPT Сбалансированный";
% sada = "ChatGPT Жёсткий контроль";

% !!! POUZIVAM TOHLE !!!
% odkomentovaz pozadovanou sadu polu pro simulaci
% sada = "DP. Vice sledovani polohy";
sada = "DP.  Mensi paliva";

if sada == "Brysonovo pravidlo"
    disp("--> Vysledky pro sadu 'Brysonovo pravidlo'")
    % stavy
    q_w = [1/10^2 1/10^2 1/10^2 1/0.78^2 1/0.78^2 1/3.14^2 1/0.17^2 1/0.17^2];
    % derivace stavu
    q_dot_w = [1/10^2 1/10^2 1/10^2 1 1 1 1 1];
    % ref
    ref_w = [1/10^2 1/10^2 1/10^2 1/3.14^2];
    Q = diag([q_w, q_dot_w, ref_w]);

    % vahy pro vstupy
    R = diag([1/110^2; 1/0.6^2; 1/0.6^2; 1/0.1^2]);

    % Vysledek:
    % Где-то аж 25 сек для положения. Углы дрона максимум 0.5 градуса.
    % Груза максимум -0.8, 0.2 градуса. Силы и моменты очень мало.

elseif sada == "Penalizace poloh"
    disp("--> Vysledky pro sadu 'Penalizace poloh'")
    % stavy
    q_w = [1 1 1 10 10 10 100 100];
    % derivace stavu
    q_dot_w = [1 1 1 1 1 1 1 1];
    % ref
    ref_w = [10 10 10 10];
    Q = diag([q_w, q_dot_w, ref_w]);

    % vahy pro vstupy
    R = diag([1/110^2; 1/0.6^2; 1/0.6^2; 1/0.1^2]);

    % Vysledek:
    % Уже более резкая регулировка, до 8 сек. Не сильные перерегулирования.
    % Углы дрона до 4 градусов. Груз -8, 4 градуса. Сила тяги 50-55 Н.
 
elseif sada == "Penalizace vstupu"
    disp("--> Vysledky pro sadu 'Penalizace vstupu'")
    % stavy
    q_w = [1 1 1 1 1 1 50 50];
    % derivace stavu
    q_dot_w = [1 1 1 1 1 1 1 1];
    % ref
    ref_w = [10 10 10 10];
    Q = diag([q_w, q_dot_w, ref_w]);

    % vahy pro vstupy
    R = diag([50 50 50 50]);

    % Vysledek: //название не совсем//
    % Есть перерегулировки для, время до 8 сек про x/y и до 16 сек про z.
    % Углы дрона до -5/5 градусов. Груз -10/5 градуса. 
    % Сила тяги 29+-1 Н -> вот и штрафование. Моменты чуть ниже

elseif sada == "ChatGPT Мягкий, экономичный контроль"
    % stavy
    q_w = [1 1 1 0.01 0.01 0.01 1 1];
    % derivace stavu
    q_dot_w = [0.01 0.01 0.01 0.01 0.01 0.01 1 1];
    % ref
    ref_w = [10 10 10 10];
    Q = diag([q_w, q_dot_w, ref_w]);

    % vahy pro vstupy
    R = diag([1 1 1 1]);

elseif sada == "ChatGPT Сбалансированный"
    % stavy
    q_w = [10 10 10 2 2 2 10 10];
    % derivace stavu
    q_dot_w = [1 1 1 1 1 1 10 10];
    % ref
    ref_w = [20 20 20 20];
    Q = diag([q_w, q_dot_w, ref_w]);

    % vahy pro vstupy
    R = diag([0.5 0.5 0.5 0.5]);


elseif sada == "ChatGPT Жёсткий контроль"
    % stavy
    q_w = [100 100 100 10 10 10 50 50];
    % derivace stavu
    q_dot_w = [2 2 2 2 2 2 20 20];
    % ref
    ref_w = [50 50 50 50];
    Q = diag([q_w, q_dot_w, ref_w]);

    % vahy pro vstupy
    R = diag([0.1 0.1 0.1 0.1]);

elseif sada == "DP. Vice sledovani polohy"
    % nejak na zaklade Penalizace poloh
    disp("--> Vysledky pro sadu 'DP. Vice sledovani polohy'")
    % stavy
    q_w = [20 20 20 1 1 1 100 100];
    % derivace stavu
    q_dot_w = [0.1 0.1 0.1 0.1 0.1 0.1 100 100];
    % ref
    ref_w = [20 20 20 20];
    Q = diag([q_w, q_dot_w, ref_w]);

    % vahy pro vstupy
    R = diag([0.01 0.01 0.01 0.01]);

elseif sada == "DP.  Mensi paliva"
    % nejak na zaklade Penalizace poloh
    disp("--> Vysledky pro sadu 'DP. Mensi paliva'")
    % stavy
    q_w = [10 10 10 1 1 1 100 100];
    % derivace stavu
    q_dot_w = [0.1 0.1 0.1 0.1 0.1 0.1 100 100];
    % ref
    ref_w = [10 10 10 10]*5;
    Q = diag([q_w, q_dot_w, ref_w]);

    % vahy pro vstupy
    R = diag([10 10 10 10]);
end


% vahy pro vstupy (otacky motoru, (rad/s)^2 )
% Rmot = diag([1 1 1 1]); % podle logiky vsechne motory maji stejnou vahu

[K_ex_lqr,~,polesLQR] = lqr(Ac_ex, Bc_ex, Q,R);
Ki_lqr = K_ex_lqr(:, 17:20); % zesileni pro integracni cleny
Kp_lqr = K_ex_lqr(:, 1:16); % zesileni pro stavove cleny

% [Kmot_ex_lqr,~,polesmotLQR] = lqr(Ac_ex, Bmc_ex, Q, Rmot);
% kimot_lqr = Kmot_ex_lqr(:, 17:20);
% kpmot_lqr = Kmot_ex_lqr(:, 1:16);


% aby dron ne padal (inicializace integratoru)
xss= Xinit_ss;
uss = Uinit;
umss = Uws;
init_int_ref_lqr = -Ki_lqr\(Kp_lqr*xss+uss); % pro vstup sily a momenty
init_int_dref_lqr = -Ki_lqr\((Uinit-Us)+Kp_lqr*(Xinit_ss-Xs));

% mapa polu, ktere navrhnul LQR
% figure;
% set(gcf, 'Color', 'w', 'Units', 'centimeters', 'Position', [0 0 16 5]);
% hold on
% plot(real(ev), imag(ev), 'bx', 'MarkerSize', 10, 'LineWidth', 1.2);
% plot(real(polesLQR),imag(polesLQR),"rx", 'MarkerSize', 10, 'LineWidth', 1.2)
% yline(0, '--k', 'LineWidth', 1);
% xline(0, '--k', 'LineWidth', 1);
% xlabel('Re(s)', 'FontSize', 12, 'FontName', 'Times New Roman');
% ylabel('Im(s)', 'FontSize', 12, 'FontName', 'Times New Roman');
% legend({'Výchozí systém', 'LQR',}, ...
%     'FontSize', 12, 'FontName', 'Times New Roman', 'Location', 'northwest');
% grid on
% % ylim([-4, 4])
% set(gca, 'LineWidth', 1.5, 'FontSize', 12, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Times New Roman')
% tightfig;
% saveas(gcf, fullfile('LQR_pmap.svg'), 'svg');

% Navrch Kalmanova filtru pro LQR
% inspirace dle https://youtu.be/ouRM4sgoVs8?list=PLn8PRpmsu08pzi6EMiYnR-076Mh-q3tWr&t=291
% Do bloku Kalman Filter dosazujeme:
% A: Ac
% B: Bc resp. Bmc pokud model se vstupy ve tvaru otacky^2
% C: Cc
% D: Dc

% Kovariance sumu procesu (pro kazdou velicinu bude svuj rozpty sigma^2)
% Q_kalman = diag([repmat(1e-4, 1, 8), repmat(2.5e-2, 1, 8)]);
Q_kalman = diag(1e-2*ones(1,16));

% Matice sumu mereni R_kalman, 8x8
% 3 polohy -> chyba mereni +-10 cm -> 0.1^2=0.01= 1e-2
% 3 uhly dronu -> cbyba mereni +-1.5 deg -> 0.0262 rad -> ~7e-4
% 2 uhly zavazi -> chyba mereni +-1 deg -> 0.0175 rad -> ~3e-4
R_kalman = diag([repmat(1e-2, 1, 3), repmat(7e-4, 1, 3), repmat(3e-4, 1, 2)]);

% Sampling time
Ts = 0.01; %[s]

run("parametry_kopter_se_zavazim.m")


