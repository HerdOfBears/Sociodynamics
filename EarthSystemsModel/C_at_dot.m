function dC_atdt = C_at_dot(t, x, P, R_veg, R_so, F_oc, epsilon, x0)
    % Time rate of change for C_at
    %{
    Variables:
        t       = time
        x       = number of mitigators
        P       = carbon uptake from photosynthesis
        R_veg   = Resp. from vegetation
        R_so    = Resp. from soil
        F_oc    = Flux of CO2 from atmos. to ocean
        epsilon = baseline CO2 emissions
    %}
    
    dC_atdt = epsilon .* ((1-x)./(1-x0)) - P + R_veg + R_so - F_oc;   
end