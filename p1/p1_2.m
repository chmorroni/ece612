
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
w1 = tf([1 2], [1/60 20]);
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

outputvar = '[ka]';
ta = sysic;


% construct kb/g loop
systemnames = ' g kb w ';
inputvar = '[u{2}]';
outputvar = '[w]';
input_to_g = '[u+kb]';
input_to_kb = '[g]';
input_to_w = '[kb]';
sleanupsysic = 'yes';
mb = sysic;

outputvar = '[kb]';
tb = sysic;


%% analyze Ma

fprintf("Ma LaaT loop 1:\n")
siso_analysis(ma(1, 1), ta(1, 1), w(1, 1));
fprintf("\n")

fprintf("Ma LaaT loop 2:\n")
siso_analysis(ma(2, 2), ta(2, 2), w(2, 2));
fprintf("\n")

fprintf("Ma MIMO:\n")
mimo_analysis(ma);
fprintf("\n")


%% analyze Mb

fprintf("Mb LaaT loop 1:\n")
siso_analysis(mb(1, 1), tb(1, 1), w(1, 1));
fprintf("\n")

fprintf("Mb LaaT loop 2:\n")
siso_analysis(mb(2, 2), tb(2, 2), w(2, 2));
fprintf("\n")

fprintf("Mb MIMO:\n")
mimo_analysis(mb);
fprintf("\n")
