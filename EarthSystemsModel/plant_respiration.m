function resp_plant = plant_respiration(C_veg, T, k_r, k_A, E_a, T_0, C_veg0)
    % Plant resp. model
    %{
    variables:
        C_veg = deviation in CO2 in veg.
        T     = temperature
    Parameters:
        k_r = plant resp. const. 
        k_A = plant resp. normalization const.
        E_a = plant resp. activation energy
        R   = molar gas const. 
        T_0 = initial average atmos. temp
        C_veg0 = initial carbon in vegetaion
    %}
    R = 8.314;
    
    %resp_plant = k_r .* C_veg .* k_A .* exp( -(E_a)./(R.*(T)) );
    resp_plant = k_r .* (C_veg+C_veg0) .* k_A .* exp( -(E_a)./(R.*(T+T_0)) );
end