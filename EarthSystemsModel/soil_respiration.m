function resp_soil = soil_respiration(T, C_so, k_sr, k_B, T_0, C_so0)
    % Soil resp. model
    %{
    Variables:
        T    = temperature
        C_so = deviation in CO2 in soil
    Parameters:
        k_sr = soil resp. rate const.
        k_B  = soil resp. rate normalization const.
        T_0  = initial average atmos. temp.
        C_so0= initial carbon in soil
    %}
    %resp_soil = k_sr.*C_so .* k_B .* exp( -(308.56)./(T-227.13) );
    resp_soil = k_sr.*(C_so+C_so0) .* k_B .* exp( (-1).*(308.56)./(T + T_0 - 227.13) );    
    % disp('resp_soil=')
    % disp(resp_soil)
end