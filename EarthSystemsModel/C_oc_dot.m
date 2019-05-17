function dC_ocdt = C_oc_dot(t, F_oc)
    % Time rate of change for C_oc, the carbon in the ocean
    %{
    Variables:
        F_oc = Flux of CO2 from atmos. to ocean
    %}
    dC_ocdt = F_oc;
end