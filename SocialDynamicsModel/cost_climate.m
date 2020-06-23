function f_T_f = cost_climate(T, f_max, omega, T_c)
    % Nonlinear approx. to a cost of climate change
    %{
    Variables:
        T = temperature projection
    Parameters:
        f_max = scaled f maximum cost (see pg 5 of Tom's SI)
        omega = degree of nonlinearity of the sigmoid
        T_c   = crit. temp. about which costs are most sensitive to change
    %}
    f_T_f = f_max ./ ( 1 + exp(-omega.*(T-T_c)) );
end