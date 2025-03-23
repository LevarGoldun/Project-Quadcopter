% 23.03.2025
% Vypocet koeficientu LQR (kopie z test_10...)

%% LQR
% asi s nekonecnym horizontem, zatim nechapu rozdil
% Q - pro stavy
% R - pro vstupy

% Rozsireny stavovy vektor
% [x;y;z;roll;pitch;yaw;alpha;beta; +derivace; +x_ref;y_ref;z_ref;yaw_ref]

% vahy pro stavy (8x)
q_weight = [1 1 100 1 1 10 100 100];
% vahy pro derivace stavu (8x)
q_dot_weight = [1 1 1 1 1 1 100 100];
% vahy pro integracni cleny (4x)
ref_weight = [1 1 1 100];

Q1 = diag([q_weight, q_dot_weight, ref_weight]);

% vahy pro vstupy (sily/momenty)
R1 = diag([0.1; 5; 5; 10]);

% vahy pro vstupy (otacky^2 rotoru kopteru)
Rmot1 = diag([1 1 1 1]/5000); % podle logiky vsechne motory maji stejnou vahu

% Rozsireny stavovy popis
Cc_ = [
    1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0;
    0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0;
    0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0;
    0     0     0     0     0     1     0     0     0     0     0     0     0     0     0     0];
Ac_ex = [Ac, zeros(16, 4); Cc_, zeros(4, 4)];
Bc_ex = [Bc; zeros(4, 4)];
Bmc_ex = [Bmc; zeros(4, 4)];


% verze sily a momenty
[K_ex_lqr,~,Plqr] = lqr(Ac_ex, Bc_ex, Q1, R1);
ki_lqr = K_ex_lqr(:, 17:20); % zesileni pro integracni cleny
kp_lqr = K_ex_lqr(:, 1:16); % zesileni pro stavove cleny


% verze otacky^2
[Kmot_ex_lqr,~,Pmotlqr] = lqr(Ac_ex, Bmc_ex, Q1, Rmot1);
kimot_lqr = Kmot_ex_lqr(:, 17:20);
kpmot_lqr = Kmot_ex_lqr(:, 1:16);

% Navrch Kalmanova filtru pro LQR (vic matlab_client.m)
% inspirace dle https://youtu.be/ouRM4sgoVs8?list=PLn8PRpmsu08pzi6EMiYnR-076Mh-q3tWr&t=291
