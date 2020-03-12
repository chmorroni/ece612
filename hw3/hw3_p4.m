
echo off

% plant and constraints
g = tf(1, [1 2]);
w1_high = tf(0);
w1_low = tf(2.65);
w2 = tf([10 1], [0.2 20]);

% find 0dB crossing frequencies
f_perf_end = 1;
[~,~,~,f_rob_start] = margin(w2);

% frequency ranges
f_range = logspace(-2, 3, 100);
perf_f_range = logspace(-2, log10(f_perf_end), 100);
rob_f_range = logspace(log10(f_rob_start), 3, 100);

% performance-critical bound |w1| > 1
w1s_low_f = frd(w1_low, perf_f_range);
w2_low_f = frd(w2, perf_f_range);
b_perf = abs(w1s_low_f) / (1 - abs(w2_low_f));

% robustness-critical bound |w2| > 1
w1_high_f = frd(w1_high, rob_f_range);
w2_high_f = frd(w2, rob_f_range);
b_rob = (1 - abs(w1_high_f)) / abs(w2_high_f);

% find a good loop gain
loop = tf(3.2*0.8*[1/2 1], [1 0.8/1.5 0.8]);
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

% join signals to form w1*s
w1_low_f_range = logspace(-2, 0, 100);
w1_high_f_range = logspace(0.01, 3, 100);
w1s_low_f = frd(w1_low * s, w1_low_f_range);
w1s_high_f = frd(w1_high * s, w1_high_f_range);
w1s_f = fcat(w1s_low_f, w1s_high_f);

% plot gamma to determine RP
w2t_f = frd(w2 * t, [w1_low_f_range w1_high_f_range]);
gamma_f = abs(w1s_f) + abs(w2t_f);
figure(2)
bodemag(gamma_f)
grid

echo on
% in case graph is ambiguous, check Hinf norm
hinfnorm(gamma_f) % must be < 1
echo off

loop
k = loop / g

echo on
