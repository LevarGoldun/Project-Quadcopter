% Elementarni matice rotace
syms roll pitch yaw

R_x = [1, 0, 0; 
       0, cos(roll), -sin(roll);
       0, sin(roll), cos(roll)];

R_y = [cos(pitch), 0, sin(pitch); 
       0, 1, 0; 
      -sin(pitch), 0, cos(pitch)];

R_z = [cos(yaw), -sin(yaw), 0; 
       sin(yaw), cos(yaw), 0; 
       0, 0, 1];

%% matice pro prevod uhlovych rychlosti (clanky)
% matice pro prevod uhlovych rychlosti dle
% https://andrew.gibiansky.com/blog/physics/quadcopter-dynamics/ [1]
% a https://www.youtube.com/watch?v=xCoFaTyn5dg [2]

% inverzni verze v
% http://dspace.ucuenca.edu.ec/bitstream/123456789/21401/1/IEE_17_Romero%20et%20al.pdf
% [3]

% Vsiml jsem si, ze asi tato "matie" je pto poradi rotace kvadrokoptery ZXY

maticeZYX = [1 0 -sin(pitch); 
    0 cos(roll) cos(pitch)*sin(roll);
    0 -sin(roll) cos(pitch)*cos(roll)];

% vychozi matice
disp('MaticeZYX')
disp(maticeZYX)

% inertovana matice 
disp('Inverze MaticeZYX')
disp(simplify(inv(maticeZYX)))

%% moje odvozeni poznamky Richard
% dle zdroje jsem se snazil odvodit svoji "matici" pro poradi XYZ...ale asi
% chybne...nevim, snazil jsem pochopit craig
maticeXYZ = [cos(pitch)*cos(yaw), sin(yaw), 0;
    -cos(pitch)*sin(yaw), cos(yaw), 0;
    sin(pitch), 0, 1];

disp('MaticeXYZ')
disp(maticeXYZ)

disp('Inverze MaticeXYZ')
disp(simplify(inv(maticeXYZ)))

% Chci zkontrolovat odvozenou mnou matici dle poznamek Richarda
% Ale zaprve odvodim MaticeZYX dle poznamek

syms roll pitch yaw droll dpitch dyaw
w = simplify( inv(R_x) )*[droll; 0; 0] +...
    simplify( inv(R_x) * inv(R_y) )*[0; dpitch; 0] +...
    simplify( inv(R_x) * inv(R_y) * inv(R_z))*[0 ; 0; dyaw];

[maticeZYX_kontrola, ~] = equationsToMatrix(w, [droll; dpitch; dyaw]);
disp('Odvozeni MaticeZYX pres vzorek Richarda')
disp(maticeZYX_kontrola)
% JO, VZORECEK RICHARDA FUNGUJE

% Ted zkotroluji svoji matici MaticeXYZ
w2 = simplify( inv(R_z) * inv(R_y) * inv(R_x))*[droll; 0; 0] + ...
     simplify( inv(R_z) * inv(R_y) )*[0; dpitch; 0] +...
     simplify( inv(R_z) )*[0; 0; dyaw];

[maticeXYZ_kontrola, ~] = equationsToMatrix(w2, [droll; dpitch; dyaw]);
disp('Odvozeni MaticeXYZ pres vzorek Richarda')
disp(maticeXYZ_kontrola)

%% Nejaka kontrola
syms roll pitch yaw

% % Elementarni matice rotace
% R_x = [1, 0, 0; 
%        0, cos(roll), -sin(roll);
%        0, sin(roll), cos(roll)];
% 
% R_y = [cos(pitch), 0, sin(pitch); 
%        0, 1, 0; 
%       -sin(pitch), 0, cos(pitch)];
% 
% R_z = [cos(yaw), -sin(yaw), 0; 
%        sin(yaw), cos(yaw), 0; 
%        0, 0, 1];
% 
% Rxyz = R_x*R_y*R_z;
% Rzyx = R_z*R_y*R_x;
% double(subs(Rxyz, [roll, pitch, yaw], [30*pi/180, 45*pi/180, 60*pi/180]))*[1;2;3]
% double(subs(Rzyx, [roll, pitch, yaw], [30*pi/180, 45*pi/180, 60*pi/180]))*[1;2;3]
% 
% % неработает моя логика как я думал...