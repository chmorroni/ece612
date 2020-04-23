
function mimo_analysis(m)
    % check nominal stability
    fprintf("  Furthest-right pole of M: %.3f\n", max(real(pole(m))))

    % calculate bounds for mu
    omega_range = logspace(-2, 2, 100);
    ma_f = frd(m, omega_range);
    blk = [1 1; 1 1]; % 2x 1x1 deltas
    mu_bounds = mussv(ma_f, blk, 'os'); % 'o' for old (not sure why), 's' for silent

    % plot mu bounds
    figure
    semilogx(mu_bounds)
    grid
    title("Mu Bounds vs Frequency")
    xlabel("Frequency (rad/s)")
    ylabel("Mu Bounds")

    % find peak mu
    fprintf("  Peak of mu: %.3f\n",norm(mu_bounds(1, 1), inf))

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
    fprintf("  Furthest-right pole of delta: %.3f\n", max(real(pole(delta))))
    fprintf("  Size of delta: %.3f\n", norm(delta, inf))
end
