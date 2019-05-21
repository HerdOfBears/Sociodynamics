function yprime = syst_odes_wSocCoupling(t, x_vec, parameters_, temp_history, x0)

    global data
    temp_pred_ON = 1; % Whether to use temp. pred. for indiv. or not ( ON == 1; OFF == 0)
    
    x      = x_vec(1);
    C_at   = x_vec(2);
    C_oc   = x_vec(3);
    C_veg  = x_vec(4);
    C_so   = x_vec(5);
    T      = x_vec(6);

    %%% Initial conditions (non-deviation initials):
    x0      = x0; 
    C_at0   = parameters_(1); %596; 
    C_oc0   = parameters_(2); %1.5.*10^(5);% % this can't be zero, otherwise we are dividing by zero
    C_veg0  = parameters_(3); %550;
    C_so0   = parameters_(4); %1500;
    T_0     = parameters_(5); %288.15;
    
    %%% Photosynthesis params.
    k_p  = parameters_(6); %0.184;
    k_MM = parameters_(7); %1.478;
    k_c  = parameters_(8); %29.* 10^(-6);
    k_M  = parameters_(9); %120.* 10^(-6);
    
    k_a  = parameters_(10); %1.773.*10^(20); % mole vol. of atmos
    
    %%% Plant resp. params:
    k_r = parameters_(11); %0.092;
    k_A = parameters_(12); %8.7039.*10^(9);
    %E_a = parameters_(13) %54.83;
    E_a = parameters_(13); %(54.83).*10^(3); % In Bury's mathematica nb this is whereas in SI it isn't cubed
    
    %%% Soil resp. params:
    k_sr = parameters_(14); %0.034; % soil resp. rate const.
    k_B  = parameters_(15); %157.072;
    
    %%%% Turnover params:
    k_t = parameters_(16); %0.092;
    
    %%%% Heat cap. of Earth's surface:
    c = parameters_(17); %4.69 .* 10^(23); %
    
    %%%% Constants:
    a_E   = parameters_(18); %5.101*10^(14); % Earth's surface area
    sigma = parameters_(19); %5.67*10^(-8); % Stefan-Boltzmann const. 
    latent_heat = parameters_(20); %43655; 
    R = parameters_(21); % 8.314; % molar gas const.
    H = parameters_(22); % 0.5915; % relative humidity; calibrated
    A = parameters_(23); % 0.225; % surface albedo
    S = parameters_(24); % 1368; % solar flux
    
    tao_CH4 = parameters_(25); % 0.0231; % see: atmos_down_flux to resolve potential probs.
    P_0 = parameters_(26); % 1.4 .* 10^(11); % water vapor sat. const.
    F_0 = parameters_(27); % 2.5 .* 10^(-2); % ocean flux rate const.
    
    chi  = parameters_(28); % 0.3; % characteristic CO2 solubility
    zeta = parameters_(29); % 50; % "evasion factor"
    
    f_max   = parameters_(30); % 5; % max of warming cost function f(T)
    omega   = parameters_(31); % 3; % nonlinearity of warming cost function
    T_c     = parameters_(32); % 2.5; % critical temperature of f(T)
    t_p     = parameters_(33); % 10; % num. prev. yrs used for temp pred.
    t_f     = parameters_(34); % 0; % num yrs ahead for temp. proj.
    s_      = parameters_(35); % 50; % half-sat. time for epsilon(t) from 2014
    eps_max = parameters_(36); % 7; % max change in epsilon(t) from 2014
    
    f_gtm = parameters_(37); % 8.3259 .* 10^(13); % conversion factor GtC -> C; pg. 1 of Thomas' SI
    
    kappa = parameters_(38); % social learning rate
    beta  = parameters_(39);  % net cost of being a mitigator
    delta = parameters_(40);  % strength of social norms

    
    %%%%%%%%%%%%%%%%
    %%% Functions
    %%%%%%%%%%%%%%%%
    
    
    %%%% Compute intermediates (resp. and photosynthesis etc.)
    
    pCO2a = mixingCO2a(C_at, C_at0, f_gtm, k_a);
    
    P     = photosynthesis(C_at, T, pCO2a, k_p, C_veg0, k_a, k_MM, k_c, k_M, T_0);
    R_veg = plant_respiration(C_veg, T, k_r, k_A, E_a, T_0, C_veg0);
    R_so  = soil_respiration(T, C_so, k_sr, k_B, T_0, C_so0);
    L_    = turnover(C_veg, k_t, C_veg0);
    F_oc  = ocean_flux(C_at, C_oc, F_0, chi, zeta, C_at0, C_oc0);
    F_d   = atmos_down_flux(pCO2a, A, S, P_0, latent_heat, T, tao_CH4, T_0);

    epsilon_T = baseline_CO2_emis(t, eps_max, s_, data);
    
    %%%%%%%%%%%%%%%%
    %%%%% ODEs
    %%%%%%%%%%%%%%%%
    
    %%%% Socio-dynamics model
    y1 = 0;
    if (temp_pred_ON == 1) && (t>2014)
        % use temperature solution at previous times to obtain a linear
        % prediction for a time horizon later
        
        %{
        if (t - floor(t) < 0.5)
            temp_time = floor(t);
        end
        if (ceil(t) - t < 0.5)
            temp_time = ceil(t);
        end
        disp(t)
        temp_time = temp_time - 1751;
        %}
        T_prev = interp1(temp_history(:,1), temp_history(:,2), t-t_p);
        %T_prev = temp_history(temp_time-t_p);
        T_f   = T + (t_f./t_p).*(T - T_prev);
        f_T_f = cost_climate(T_f, f_max, omega, T_c);
        y1 = dXdt(x, f_T_f, kappa, beta, delta);
    end
    if (temp_pred_ON == 0) && (t>2014)
        % Just use current temperature value
        f_T_f = cost_climate(T, f_max, omega, T_c);
        y1 = dXdt(x, f_T_f, kappa, beta, delta);
    end

    %%% Carbon uptake/transport DEs
    
    y2 = C_at_dot(t, x, P, R_veg, R_so, F_oc, epsilon_T, x0);  % Atmospheric
    y3 = C_oc_dot(t, F_oc);  % Ocean
    y4 = C_veg_dot(t, P, R_veg, L_); % Vegetation
    y5 = C_so_dot(t, R_so, L_);  % Soil
    
    
    %%% Temperature change
    y6 = c_T_dot(t, F_d, T, c, T_0);

    %%% RESULT
    yprime = [y1; y2; y3; y4; y5; y6];
end