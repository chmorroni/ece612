
function siso_analysis(m, t, w)
    fprintf("  Furthest-right pole of M: %.3f\n", max(real(pole(m))))
    fprintf("  Hinf( W*T ): %.3f\n", norm(t*w, inf))
    
    % plot W*T
    omega_range = logspace(-2, 2, 100);
    wt_f = frd(w*t, omega_range);
    figure
    bodemag(wt_f)
    grid
    title("W*T vs Frequency")
    xlabel("Frequency (rad/s)")
    ylabel("W*T")
end
