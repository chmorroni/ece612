
% given transfer functions
K = tf(1, [1 1]);
P = tf(1, [1 5 6]);
F = 10;
W1 = tf(1, [1 10]);
W2 = tf([10 50], [1 50]);

% construct G
systemnames = ' F P W1 W2 ';
inputvar = '[d; n; u]';
outputvar = '[W2; W1; -F]';
input_to_F = '[n+P]';
input_to_P = '[d+u]';
input_to_W1 = '[u]';
input_to_W2 = '[P]';
sysoutname = 'G';
cleanupsysic = 'yes';
sysic;

% rename outputs
G.OutputName = {'v' 'uf' 'y'};

% construct closed-loop
F_lower_G_K = lft(G, K);

isstable(F_lower_G_K)
