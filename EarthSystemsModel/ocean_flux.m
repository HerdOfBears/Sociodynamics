function flux_ocean = ocean_flux(C_at, C_oc, F_0, chi, zeta, C_at0, C_oc0)
    % 
    %{
    Variables:
        C_at = deviation in atmos. CO2
        C_oc = deviation in ocean CO2
    Parameters:
        F_0   = ocean flux rate const.
        chi   = characteristic CO2 solubility
        zeta  = "evasion factor"
        C_at0 = initial CO2 in atmos.
        C_oc0 = initial val. of C_oc
    %}
    flux_ocean = F_0 .* chi .* ((C_at+C_at0) - zeta.*(C_at0./C_oc0).*(C_oc+C_oc0));
    %flux_ocean = F_0 .* chi .* ((C_at) - zeta.*(C_at0./C_oc0).*(C_oc));
end