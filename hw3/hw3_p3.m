
echo off

% plant and constraints
g = tf(1, [0.01 1]) * tf(1, [0.01 1]);
w1 = tf(10, [1 2 2 1]);
w2 = tf([0.1 0], [0.05 1]);

% find 0dB crossing frequencies
[~,~,~,f_perf_end] = margin(w1);
[~,~,~,f_rob_start] = margin(w2);

% frequency ranges
f_range = logspace(-1, 3, 100);
perf_f_range = logspace(-1, log10(f_perf_end), 100);
rob_f_range = logspace(log10(f_rob_start), 3, 100);

% performance-critical bound |w1| > 1
w1_low_f = frd(w1, perf_f_range);
w2_low_f = frd(w2, perf_f_range);
b_perf = abs(w1_low_f) / (1 - abs(w2_low_f));

% robustness-critical bound |w2| > 1
w1_high_f = frd(w1, rob_f_range);
w2_high_f = frd(w2, rob_f_range);
b_rob = (1 - abs(w1_high_f)) / abs(w2_high_f);

% find a good loop gain
loop = tf(20, [1 1]) * tf([1/3 1], [1 1]);
loop_f = frd(loop, f_range);

% plot bounds and loop gain
figure(1)
bodemag(loop_f, b_perf, b_rob)
grid

% determine NS
s = 1 / (1 + loop);
t = loop / (1 + loop);

echo on
max(real(pole(t))) % must be < 0
echo off

% plot gamma to determine RP
w1s_f = frd(w1 * s, f_range);
w2t_f = frd(w2 * t, f_range);
gamma_f = abs(w1s_f) + abs(w2t_f);
figure(2)
bodemag(gamma_f)
grid

echo on
% in case graph is ambiguous, check Hinf norm
hinfnorm(gamma_f) % must be < 1
echo off

echo on
