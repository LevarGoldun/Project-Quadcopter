% Parametry modelu kvadrokoptery v MuJoCo
%% Parametry
g = 9.81;
L = 1.3535; %[m] poloviční délka kvadrokoptéry
d = 0.5; %[m] délka lana

M = 3.3; % hmotnost kvadrokoptery mujoco [kg]
m = 0.5; %[kg]
Ikv = 2.99; % setrvačnost kvadrokoptéry mujoco kolem Y osy [kg*m^2]


%==============priklad koeficientu je z DP Tomase Ira======================
% tlumení kvadrokoptéry ve směru pohybu x a y
c_x = 0.001*0; %[kg/s]
c_y = 0.001*0;
% tlumení při pootočení kvadrokoptéry
c_fi = 0.0013*0;

% tlumení kývání zátěže
c_alfa = 0.0013*0;

% % koeficient umernosti sily na rotoru k jeho uhlove rychlosti
% % koef = 9.876e-5; 
% koef = 0.1;
% 
% %[nevim, ale podle diplomky 1.2 kg pri 120 "hodnoty Matlabu", kde
% % asi 120 je uhlova rychlost rotoru. Priklad rychlosti z internetu je 
% % 6500 ot/m--> 108 ot/s. Takze asi 120 ma jednotku ot/s.
% 
% % Priblizny vypocet dovolenych otacek na rotoru
% % max. tazna sila na 1 rotoru (M+m)*g*5/2
% Fmax = (M+m)*g*5/2; %[N]
% % max. uhlova rychlost 
% wmax = sqrt(Fmax/koef); %[ot/s]