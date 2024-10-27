function [roll, pitch] = roll_pitch_calculation(quaternions)
% quaterniony z Python je v poradi [w, x, y, z]
% quat2eul poziva na vstupu poradi [w, x, y, z]
radians = quat2eul(quaternions, 'xyz'); % pouzivam poradi XYZ
% roll = kolem osy x, pitch = kolem osy y
roll = rad2deg(radians(1));
pitch = rad2deg(radians(2));
end
