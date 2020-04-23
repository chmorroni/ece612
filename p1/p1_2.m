
%% setup

% load given controllers
load ("k_example.mat")

% plant model from in-class example
g_a = [0 10; -10 0];
g_b = [1 0; 0 1];
g_c = [1 10; -10 1];
g_d = [0 0; 0 0];
g = ss(g_a, g_b, g_c, g_d);

% given weights for uncertainty
w1 = tf([1 9], [1/40 45]);
w2 = tf([1 9], [1/40 45]);
w = [w1 0; 0 w2];

% construct ka/g loop
systemnames = ' g ka w ';
inputvar = '[u{2}]';
outputvar = '[w]';
input_to_g = '[u+ka]';
input_to_ka = '[g]';
input_to_w = '[ka]';
sleanupsysic = 'yes';
ma = sysic;

% construct kb/g loop
systemnames = ' g kb w ';
inputvar = '[u{2}]';
outputvar = '[w]';
input_to_g = '[u+kb]';
input_to_kb = '[g]';
input_to_w = '[kb]';
sleanupsysic = 'yes';
mb = sysic;


%% loop-at-a-time analysis for ka

ma_11 = minreal(ma(1, 1)); % get minimum realization
pole(ma_11); % 2 poles in LHP (@ -1, -1800)

ma_22 = minreal(ma(2, 2)); % get minimum realization
pole(ma_22); % 2 poles in LHP (@ -1, -1800)


%% MIMO robustness analysis for ka

% check nominal stability
pole(ma); % 4 poles in LHP (2 each @ -1, -1800)

% calculate bounds for mu
omega_range = logspace(-2, 2, 100);
ma_f = frd(ma, omega_range);
blk = [1 1; 1 1]; % 2x 1x1 deltas
mu_bounds = mussv(ma_f, blk, 'o'); % 'o' for old (not sure why)

% plot mu bounds
figure
semilogx(mu_bounds)
grid
title("Mu Bounds vs Frequency for Ka")
xlabel("Frequency (rad/s)")
ylabel("Mu Bounds")

% find peak mu
peak_mu = norm(mu_bounds(1, 1), inf); % = 2.0099

% build uncertainty model
del1 = ultidyn('del1',[1 1]);
del2 = ultidyn('del2',[1 1]);
del = blkdiag(del1, del2);
a_cl_f = lft(del, ma_f);

% calculate smallest(ish) destabilizing perturbation
[~, unc] = robuststab(a_cl_f);
delta1 = unc.del1;
delta2 = unc.del2;
delta = blkdiag(delta1, delta2);

% check delta
max(real(pole(delta))); % = -0.0071, so delta is stable
norm(delta, inf); % = 0.4975, 1/peak_mu


%% loop-at-a-time analysis for kb

mb_11 = minreal(mb(1, 1)); % get minimum realization
pole(mb_11); % 7 poles in LHP

mb_22 = minreal(mb(2, 2)); % get minimum realization
pole(mb_22) % 6 poles in LHP


%% MIMO robustness analysis for kb

% check nominal stability
pole(mb); % 7 poles in LHP

% calculate bounds for mu
omega_range = logspace(-2, 2, 100);
mb_f = frd(mb, omega_range);
blk = [1 1; 1 1]; % 2x 1x1 deltas
mu_bounds = mussv(mb_f, blk, 'o'); % 'o' for old (not sure why)

% plot mu bounds
figure
semilogx(mu_bounds)
grid
title("Mu Bounds vs Frequency for Kb")
xlabel("Frequency (rad/s)")
ylabel("Mu Bounds")

% find peak mu
peak_mu = norm(mu_bounds(1, 1), inf) % = 1.0980

% build uncertainty model
del1 = ultidyn('del1',[1 1]);
del2 = ultidyn('del2',[1 1]);
del = blkdiag(del1, del2);
b_cl_f = lft(del, mb_f);

% calculate smallest(ish) destabilizing perturbation
[marg, unc] = robuststab(b_cl_f);
delta1 = unc.del1;
delta2 = unc.del2;
delta = blkdiag(delta1, delta2);

% check delta
max(real(pole(delta))) % = -0.0071, so delta is stable
norm(delta, inf) % = 0.9107, 1/peak_mu
