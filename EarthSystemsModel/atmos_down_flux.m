function flux_down = atmos_down_flux(pCO2a, A, S, P_0, L, T, tao_CH4, T_0)
    % "Grey-atmosphere approximation"
    % Models some atmos. dynamics
    %{
    Computes net downward flux of radiation absorbed at the planet's
    surface
    
    Variables:
        pCO2a = mixing ratio of CO2 in atmos. as above
        T     = temperature
    Parameters:
        A   = surface albedo
        S   = incoming solar flux
        P_0 = water vapor saturation const.
        L   = latent heat per mole of water
        R   = molar gas const.
        H   = relative humidity
        T_0 = initial temperature value
    Computed parameters:
        tao = vertical opacity of the greenhouse atmosphere
    %}
    H = 0.5915;
    %H = 0.5848;
    R = 8.314;
    
    tao_CO2 = 1.73 .* (pCO2a).^(0.263);
    % plus T_0 because we are treating T as DeltaT
    tao_H2O = 0.0126.* ( H.* P_0.*exp( -(L./(R.*(T+T_0)))) ).^(0.503);
    tao_ = tao_CH4 + tao_CO2 + tao_H2O;
    
    flux_down = ( ((1-A).*S)./4 ).*(1+(3/4).*tao_);
end