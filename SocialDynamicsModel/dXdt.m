function dXdt_ = dXdt(x, f_T_f, kappa, beta, delta)
    % Time rate of change of the number of mitigators in our population
    %{
    Variables:
        x     = number of mitigators in the population
        f_T_f = Cost of warming put through a nonlinear function f; f(T_f)
    Parameters:
        kappa = Social learning rate; rate at which an alternative strategy
                propagates throughout a pop.
        beta  = net cost of mitigation (of being a mitigator)
        delta = strength of social norms
    %}
    
    dXdt_ = kappa .* x .* (1-x) .* ( (-1).*beta + f_T_f + delta.*(2.*x - 1) );
end