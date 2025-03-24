% 23.03.2025
% Vypocet koeficientu metodou Pole Placement (kopie z test_10...)


%% Pole Placement
% Rozsireny stavovy regulator s pozorovatelem (Luemberguv)

% Rozsireny stavovy vektor
% [x;y;z;roll;pitch;yaw;alpha;beta; +derivace; +x_ref;y_ref;z_ref;yaw_ref]

% Volba polu (16+4ref)
poles2 = [-4;-4.1;-4.2; 
          -3.5+3j;-3.5-3j;-2;
          -1.5-1j;-1.5+1j; 

          -1-0.8j;-1+0.8j;-0.5-0.6j;
          -0.5+0.6j;-0.4;-2.5;
          -3-2j;-3+2j;

          -5; -4.5; -3.8; -1];
% Bohuzel poly nejsou spojeny se stavy (proto LQR je lepsi)

% poly pro pozorovatele 2-6x rychlejsi (leveji od Im osy)
poles_obs = poles2(1:16)*5;

% Rozsireny stavovy popis Ac_ex, Bc_ex
% P.S. Matice Ac atd z LinSystemMatrix.mat
Cc_ = [
    1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0;
    0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0;
    0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0;
    0     0     0     0     0     1     0     0     0     0     0     0     0     0     0     0];
Ac_ex = [Ac, zeros(16, 4); Cc_, zeros(4, 4)];
Bc_ex = [Bc; zeros(4, 4)];
Bmc_ex = [Bmc; zeros(4, 4)];

% verze sily a momenty
K_ex_other_angles = place(Ac_ex, Bc_ex, poles2);
ki = K_ex_other_angles(:, 17:20); % zesileni pro integracni cleny
kp = K_ex_other_angles(:, 1:16); % zesileni pro stavove cleny

% verze otacky^2
Kmot_ex_other_angles = place(Ac_ex, Bmc_ex, poles2);
kimot = Kmot_ex_other_angles(:, 17:20);
kpmot = Kmot_ex_other_angles(:, 1:16);

% Koeficienty pro pozorovatele - vyuzit princip duality
% Take pozor je pouzita jina matice C!!! (vychozi)
% protoze merime polohu, orientace a 2 uhly zavazi
L_obs = place(Ac', Cc', poles_obs)';