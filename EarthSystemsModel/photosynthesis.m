function photo = photosynthesis(C_at, T, pCO2a, k_p, C_veg0, k_a, k_MM, k_c, K_M, T_0)
    % Photosynthesis model from (Lenton 2000) Earth System Model
    %{
    Carbon uptake from the atmos. via photosynthesis
    Variables:
        C_at  = carbon uptake atmos.
        T     = Temperature
        pCO2a = Mixing ratio of CO2 in the atmosphere
                (function name: mixingCO2a)
    Parameters:
        k_p    = photosynthesis rate const.
        C_veg0 = initial carbon in vegetation 
        k_a    = tot. molecules in the atmos.
        k_MM   = photosynthesis normalizing const.
        k_c    = photosynthesis compensation point
        K_M    = MIchaelis-Menton rate const.; half-sat. pt. for photo.
        T_0    = initial temp. 
    %}
    cond1 = (pCO2a > k_c);
    %cond2 = ((T-T_0) >=-15) & ((T-T_0)<=25);
    cond2 = (T >-15) & (T<25);
    if cond1 && cond2
        %photo = k_p .* C_veg0 .* k_MM .* ( (pCO2a - k_c)./(K_M + pCO2a -k_c) ).*( (((15+(T-T_0)).^2).*(25-(T-T_0)))./(5625) );
        photo = k_p .* C_veg0 .* k_MM .* ( (pCO2a - k_c)./(K_M + pCO2a -k_c) ).*( (((15+(T)).^2).*(25-(T)))./(5625) );    
    else
        photo = 0;
    end
    disp('phto = ')
    disp(photo)
end