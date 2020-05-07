
%% setup the system

g0 = [87.8 -86.4; 108.2 -109.6];
dyne = tf(1, [75 1]);
dyn = append(dyne, dyne);
g = ss(dyn*g0);

wpe = zpk([-1], [-1e-6], 0.5); 
wp = ss(append(wpe, wpe));

wie = zpk([-20], [-200], 2);
wi = ss(append(wie, wie));

inverter = [-1 0; 0 -1];

systemnames = 'g inverter wp wi';
inputvar = '[u_del{2}]; w{2}; u{2}';
outputvar = '[wi; wp; inverter]';
input_to_g = '[u+u_del]';
input_to_inverter = '[g+w]';
input_to_wp = '[g+w]';
input_to_wi = '[u]';
cleanupsysic = 'yes';
p = ss(sysic);

nmeas = 2;
ncont = 2;
blks = [1 1; 1 1];
blkp = [1 1; 1 1; 2 2];
om_range = logspace(-3, 3, 50);

sdel1 = ultidyn('sdel1', [1 1]);
sdel2 = ultidyn('sdel2', [1 1]);
sdel = blkdiag(sdel1, sdel2);

pu = lft(sdel, p);


%% design

pref = dkitopt;
pref.FrequencyVector = om_range;
pref.AutoIter = 'on';

k = dksyn(pu, nmeas, ncont, pref);
[~, ~, ~, order] = minfo(k)
[ak, bk, ck, dk] = ssdata(k);

k = reduce(k, 12, "algorithm", "hankelmr");


%% analyze

% Partition N
n = lft(p, k);
n11 = n([1:2], [1:2]);
n22 = n([3:4], [3:4]);

% Check Nominal Stability
ns_test = max(real(pole(n)))

% Frequency response
ng = frd(n, om_range);
n11g = frd(n11, om_range);
n22g = frd(n22, om_range);

% Uncertainty structures
blkrs = [1 1; 1 1];
blknp = [2 2];
blkrp = [blkrs; blknp];

% Mu bounds calculation
bndsnp = mussv(n22g,blknp,'o');
bndsrs = mussv(n11g,blkrs,'o');
bndsrp = mussv(ng,blkrp,'o');

figure
semilogx(bndsnp(1,1),bndsrs(1,1),bndsrp(1,1))
legend('NP','RS','RP')
grid
title('Mu for NP,RS,RP')
xlabel('Frequency (rad/s)')
ylabel('Mu (Upper) Bound')

figure
sys = feedback(g*k, eye(size(g*k)));
t = 0:0.01:50;
in_sig = lsim(tf(1, [1]), ones(length(t), 1), t);
lsim(sys, [in_sig zeros(length(t), 1)], t)
grid
title("Response to Step on Input 1")

figure
sys = feedback(g*[1.2 0; 0 0.8]*k, eye(size(g*k)));
in_sig = lsim(tf(1, [1]), ones(length(t), 1), t);
lsim(sys, [in_sig zeros(length(t), 1)], t)
grid
title("Perturbed Response to Step on Input 1")
