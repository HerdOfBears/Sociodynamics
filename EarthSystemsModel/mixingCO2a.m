function pCO2a = mixingCO2a(C_at, C_at0, f_gtm, k_a)
    % Computes mixing ratio of CO2 in the atmos.
    %{
    Variables:
        C_at  = deviation of atmos. CO2 (from initial val.)
        C_at0 = initial val for C_at
    Parameters:
        f_gtm = conversion factor from GtC to moles of Carbon
        k_a   = tot. molecules in the atmos.
    %}
    f_gtm = 8.3259 .* 10^(13);
    pCO2a = (f_gtm.*(C_at + C_at0))./(k_a);
end