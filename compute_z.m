function [Z, u] = compute_z(pig, c0, cs, start_time, end_time)
opts = odeset('RelTol',1e-6,'AbsTol',1e-8);
tspan = linspace(start_time, end_time, end_time-start_time+1); %(start_time, end_time, end_time-start_time+1);
    function[du] = t0_u(t, u, cs, c0)
        du = c0*(ppval(cs, t) -u);
    end
[t, u] = ode45(@(t, u) t0_u(t, u, cs, c0), tspan, pig(start_time, 1), opts);

Z = u-pig(start_time:end_time, 1);
end