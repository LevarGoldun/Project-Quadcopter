classdef my_function_pid < handle
    properties
        Ts, kp, ki, kd, umax, umin, tau, eprev, uprev, udfiltprev  
    end
    methods
        function obj = my_function_pid(Ts, kp, ki, kd, umax, umin, tau)
            % Pokud vstupnich parametru je mene nez 5, tak ostatni parametry se nastavuji automaticky
            if nargin < 5 
                umax = Inf;
            end
            if nargin < 6
                umin = -Inf;
            end
            if nargin < 7
                tau = 0;
            end
            
            obj.Ts = Ts; % Sampling period (s)
            obj.kp = kp; % Proportional gain
            obj.ki = ki; % Integral gain
            obj.kd = kd; % Derivative gain
            obj.umax = umax; % Upper output saturation limit
            obj.umin = umin; % Lower output saturation limit
            obj.tau = tau; % Derivative term filter time constant (s)
            
            obj.eprev = [0, 0]; % Previous errors e[n-1], e[n-2]
            obj.uprev = 0; % Previous controller output u[n-1]
            obj.udfiltprev = 0; % Previous derivative term filtered value
        end

        % PID control function
        function u = control(obj, ysp, y)
            % ysp - setpoint, desired value 
            % y - actual value
            % Calculating error e[n]
            e = ysp - y;

            % Calculating proportional term
            up = obj.kp * (e - obj.eprev(1));
            
            % Calculating integral term (with anti-windup)
            ui = obj.ki * obj.Ts * e;
            if (obj.uprev >= obj.umax) || (obj.uprev <= obj.umin)
                ui = 0;
            end
            
            % Calculating derivative term
            ud = obj.kd / obj.Ts * (e - 2 * obj.eprev(1) + obj.eprev(2));
            
            % Filtering derivative term
            udfilt = (obj.tau / (obj.tau + obj.Ts)) * obj.udfiltprev + ...
                     (obj.Ts / (obj.tau + obj.Ts)) * ud;
                 
            % Calculating PID controller output u[n]
            u = obj.uprev + up + ui + udfilt;
            
            % Updating previous time step errors e[n-1], e[n-2]
            obj.eprev(2) = obj.eprev(1);
            obj.eprev(1) = e;
            
            % Updating previous time step output value u[n-1]
            obj.uprev = u;
            
            % Updating previous time step derivative term filtered value
            obj.udfiltprev = udfilt;
            
            % Limiting output (just to be safe)
            if u < obj.umin
                u = obj.umin;
            elseif u > obj.umax
                u = obj.umax;
            end
        end
   end
end