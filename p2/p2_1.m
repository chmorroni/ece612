
% setup
% plant = zpk(-1, [-2 -3], 1);
% w1_wt = zpk([], [], 1); % disturbance
% w2_wt = zpk([], [], 1e-2); % measurement noise, not strictly proper
% z1_wt = zpk([], [-1e-3], 1); % error, strictly proper
% z2_wt = zpk([], [], 1e-2); % control signal, not strictly proper

plant = zpk(1, [-1 2], 1);
w1_wt = zpk([], [-1], 1); % disturbance
w2_wt = zpk([], [], 1e-2); % measurement noise, not strictly proper
z1_wt = zpk([], [-1e-3], 1); % error, strictly proper
z2_wt = zpk([-1e-3], [-1], 1); % control signal, not strictly proper

% construct system
systemnames = 'plant w1_wt w2_wt z1_wt z2_wt';
inputvar = '[w{2}; u]';
outputvar = '[z1_wt; z2_wt; w1_wt + w2_wt - plant]';
input_to_plant = '[u]';
input_to_w1_wt = '[w(1)]';
input_to_w2_wt = '[w(2)]';
input_to_z1_wt = '[w1_wt - plant]';
input_to_z2_wt = '[u]';
cleanupsysic = 'yes';
sys_full = ss(sysic);
sys = minreal(sys_full);

% choose a synthesis method
%[k, sys_cl] = h2syn(sys, 1, 1);
[k, sys_cl] = hinfsyn(sys, 1, 1);

% analyze
[~, ~, ~, order] = minfo(k)
max_pole = max(real(pole(sys_cl)))
h2_norm = norm(sys_cl, 2)
hinf_norm = norm(sys_cl, inf)

% make CL system without weights
sys_cl_unweighted = minreal((k * plant) / (1 + (k * plant)));
sys_control_signal = minreal(k / (1 + (k * plant)));

figure
step(sys_cl_unweighted)
grid
title("Step Response")

figure
step(sys_control_signal)
grid
title("Control Signal Step Response")

om_range = logspace(-3, 4, 100);
sys_cl_unweighted_f = frd(sys_cl_unweighted, om_range);
figure
bode(sys_cl_unweighted_f)
grid
title("Closed-Loop Bode")

sys_control_signal_f = frd(sys_control_signal, om_range);
figure
bode(sys_control_signal_f)
grid
title("Control Signal Bode")
