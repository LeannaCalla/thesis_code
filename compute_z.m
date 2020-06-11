function [Z, u] = compute_z(pig, c0, cs, start_time, end_time)
% compute_z: using the model in the form T=u + v to break the ODE
% into two, we compute du/dt - this is the heating due to environmental
% changes
opts = odeset('RelTol',1e-6,'AbsTol',1e-8);
tspan = linspace(start_time, end_time, end_time-start_time+1); 
    function[du] = t0_u(t, u, cs, c0)
        du = c0*(ppval(cs, t) -u);
    end
% initial condition will be taken from ground truth data set
[t, u] = ode45(@(t, u) t0_u(t, u, cs, c0), tspan, pig(start_time, 1), opts);

% subtract off ground truth to obtain heating from environment
Z = u-pig(start_time:end_time, 1);
end