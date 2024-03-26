syms fi teta psi

% matice pro prevod uhlovych rychlosti dle https://andrew.gibiansky.com/blog/physics/quadcopter-dynamics/
% a inverzni verze v http://dspace.ucuenca.edu.ec/bitstream/123456789/21401/1/IEE_17_Romero%20et%20al.pdf

matice = [1 0 -sin(teta); 
    0 cos(fi) cos(teta)*sin(fi);
    0 -sin(fi) cos(teta)*cos(fi)];

% vychozi matice 
disp(matice)

% inertovana matice 
disp(simplify(inv(matice)))