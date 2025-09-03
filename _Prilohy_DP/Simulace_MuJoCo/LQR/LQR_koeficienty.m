% 23.03.2025
% Vypocet koeficientu LQR (kopie z test_10...)

% 25.07.2025
% nove k a b, nove matice zesileni
% uprava formatu jako pro pole placement

%% LQR
% Rozsireny LQR, Kalmanuv Filtr pro odhad zbyvajicich stavu

% Q - vahy pro stavy
% R - vahy pro vstupy

% Rozsireny stavovy vektor
% [x;y;z;roll;pitch;yaw;alpha;beta; +derivace; +x_ref;y_ref;z_ref;yaw_ref]

% % vahy pro stavy (8x)
% q_weight = [1 1 100 1 1 10 100 100];
% % vahy pro derivace stavu (8x)
% q_dot_weight = [1 1 1 1 1 1 100 100];
% % vahy pro integracni cleny (4x)
% ref_weight = [1 1 10 100];
% 
% Q1 = diag([q_weight, q_dot_weight, ref_weight]);
% 
% % vahy pro vstupy (sily/momenty)
% R1 = diag([1; 5; 5; 10]);
% 
% % vahy pro vstupy (otacky^2 rotoru kopteru)
% Rmot1 = diag([1 1 1 1]/5000); % podle logiky vsechne motory maji stejnou vahu


% volba varianty vahovych matic (index z LQR_matlab_client)
if index == "Sledovani polohy"
    % stavy
    q_w = [20 20 20 1 1 1 100 100];
    % derivace stavu
    q_dot_w = [0.1 0.1 0.1 0.1 0.1 0.1 100 100];
    % ref
    ref_w = [20 20 20 20];
    Q = diag([q_w, q_dot_w, ref_w]);

    % vahy pro vstupy
    R = diag([0.01 0.01 0.01 0.01]); % jesm zvetsil, bylo nestabilni v mujoco

elseif index == "Mene paliva"
    % stavy
    q_w = [10 10 10 1 1 1 100 100];
    % derivace stavu
    q_dot_w = [0.1 0.1 0.1 0.1 0.1 0.1 100 100];
    % ref
    ref_w = [10 10 10 10]*5;
    Q = diag([q_w, q_dot_w, ref_w]);

    % vahy pro vstupy
    R = diag([10 10 10 10]);
else
    disp("error pri volbe sady polu")
end

% Rozsireny stavovy popis Ac_ex, Bc_ex
% P.S. Matice Ac atd z LinSystemMatrix.mat
Cc_ = [
    1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0;
    0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0;
    0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0;
    0     0     0     0     0     1     0     0     0     0     0     0     0     0     0     0];
Ac_ex = [Ac, zeros(16, 4); Cc_, zeros(4, 4)];
Bc_ex = [Bc; zeros(4, 4)];
% Bmc_ex = [Bmc; zeros(4, 4)];


% verze sily a momenty
[K_ex_lqr,~,Plqr] = lqr(Ac_ex, Bc_ex, Q, R);
Ki_lqr = K_ex_lqr(:, 17:20); % zesileni pro integracni cleny
Kp_lqr = K_ex_lqr(:, 1:16); % zesileni pro stavove cleny


% verze otacky^2
% [Kmot_ex_lqr,~,Pmotlqr] = lqr(Ac_ex, Bmc_ex, Q1, Rmot1);
% kimot_lqr = Kmot_ex_lqr(:, 17:20);
% kpmot_lqr = Kmot_ex_lqr(:, 1:16);

% Navrch Kalmanova filtru pro LQR (z test_10)
% inspirace dle https://youtu.be/ouRM4sgoVs8?list=PLn8PRpmsu08pzi6EMiYnR-076Mh-q3tWr&t=291
% Kovariancni matice sumu procesu
Q_kalman = diag(1e-2*ones(1,16));
% Kovariancni matice sumu mereni
R_kalman = diag([repmat(1e-2, 1, 3), repmat(7e-4, 1, 3), repmat(3e-4, 1, 2)]);
% Samplint time
% -> dosazuju timestep primo do bloku White Noise

