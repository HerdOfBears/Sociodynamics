function dc_Tdt = c_T_dot(t, F_d, T, c, T_0)
    % Time rate of change for average temp., scaled by c
    %{
    Variables:
        t = time
        F_d = net downward flux of radiation as defined in the function
                (atmos_down_flux)
        T   = average temp.
    Parameters:
        sigma = Stefan-Blotzmann const.
        a_E   = Earth's surface area
        c     = Heat cap. of atmos.
        T_0   = Initial temperature value
    %}
    sigma = 5.67 .* 10^(-8);
    a_E   = 5.101.* 10^(14);
    SecondsToYrs = 60*60*24*365;
    % 0.0381 = secondstoyrs*a_E/c = 0.0343
    dc_Tdt = (F_d - sigma.*(T+T_0).^4).*0.0343;%.*SecondsToYrs.*a_E.*(1./c);
end