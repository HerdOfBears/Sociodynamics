function parameters_ = get_parameters(random_yes_no)
    %{
    Returns array of parameters.
    
    Variables:
        random_yes_no : integer
            Switches between returning parameters sampled from triangular
            distributions, or to return baseline params with upper and lower bounds. 
    %}
    
    x0    = 0.1;
    kappa = 0.2;
    delta = 0.5;
    beta  = 0.5;
    k_MM  = 1.478;
    s_    = 50;
    k_A   = 8.7039.*10^(9);
    k_B   = 157.072;

    if ~random_yes_no
        %%%%%%%%%%%%%%
        %%%% Parameter values
        %%%%%%%%%%%%%%
        parameters_given = [];
        
        %x0 = 0.01;
        %%% Initial conditions and distributions (non-deviation initials):
        C_at0   = 596;% (590, 596, 602) 

        C_oc0   = 1.5e5;% (1.4, 1.5, 1.6)e5 % this can't be zero, otherwise we are dividing by zero

        C_veg0  = 550;% (540, 550, 560)

        C_so0   = 1500;% (1480, 1500, 1520)

        T_0     = 288.15;% (288, 288.15, 288.3)

        parameters_given = [x0, C_at0, C_oc0, C_veg0, C_so0, T_0];

        %%% Photosynthesis params.
        k_p   = 0.184;%(0.175, 0.184, 0.193)

        %k_MM = 1.478; 
        k_c   = 29e-6;%(26, 29, 32)e-6
        k_M   = 120e-6;% (108, 120, 132) e-6

        k_a  = 1.773.*10^(20); % mole vol. of atmos 

        parameters_given = [parameters_given, k_p, k_MM, k_c, k_M, k_a];

        %%% Plant resp. params:
        k_r   = 0.092;%(0.0828, 0.092, 0.1012)
        %k_A   = 8.7039.*10^(9);
        %E_a = 54.83;
        E_a   = 54.83e3;% (54.63, 54.83, 55.03)e3 % In Bury's mathematica nb this is whereas in SI it isn't cubed

        %%% Soil resp. params:
        k_sr = 0.0337;% soil resp. rate const.(0.0303, 0.034, 0.037)
        %k_B  = 157.072; %

        parameters_given = [parameters_given, k_r, k_A, E_a, k_sr, k_B];
        %%%% Turnover params:
        k_t = 0.092;%(0.0828, 0.092, 0.1012)

        %%%% Heat cap. of Earth's surface:
        c = 4.69e23;% (4.22, 4.69, 5.16)e23

        parameters_given = [parameters_given, k_t, c];

        %%%% Constants:
        a_E   = 5.101*10^(14); % Earth's surface area 
        sigma = 5.67*10^(-8); % Stefan-Boltzmann const. 
        latent_heat = 43655; 
        R = 8.314; % molar gas const.
        H = 0.5915; % relative humidity; calibrated

        A = 0.225;% surface albedo (0.203, 0.225, 0.248)
        S = 1368;% solar flux (1231, 1368, 1504)

        parameters_given = [parameters_given, a_E, sigma, latent_heat, R, H, A, S];

        tao_CH4 = 0.0231;%random(pdtao_CH4,1,1); % (0.0208, 0.0231, 0.0254) see: atmos_down_flux to resolve potential probs.
        P_0     = 1.4e11;% random(pdP_0, 1,1); % (1.26, 1.4, 1.54)e11 water vapor sat. const.
        F_0     = 2.5e-2;% (2.25, 2.5, 2.75)e-2 ocean flux rate const.
        chi     = 0.3;% (0.2, 0.3, 0.4) characteristic CO2 solubility
        zeta    = 50;% (40, 50, 60) "evasion factor"

        parameters_given = [parameters_given, tao_CH4, P_0, F_0, chi, zeta];


        f_max = 6; % (4,5,6) max of warming cost function f(T)
        omega = 3; % (1,3,5) nonlinearity of warming cost function
        T_c   = 2.5;% (2.4, 2.5, 2.6) critical temperature of f(T)
        t_p   = 10; % num. prev. yrs used for temp pred.
        t_f   = 50; % (0, 25, 50) num yrs ahead for temp. proj.
        %s_    = 50;% (30, 50, 70) half-sat. time for epsilon(t) from 2014
        eps_max   = 7;% (4.2, 7, 9.8) max change in epsilon(t) from 2014

        f_gtm = 8.3259 .* 10^(13); % conversion factor GtC -> C; pg. 1 of Thomas' SI

        parameters_given = [parameters_given, f_max, omega, T_c, t_p, t_f, s_, eps_max, f_gtm];

        %kappa = 0.2;    % (0.02, 0.05, 0.2) social learning rate
        %beta  = 0.5;    % (0.5, 1, 1.5) net cost of being a mitigator
        %delta = 0.5;    % (0.5, 1, 1.5) strength of social norms

        parameters_given = [parameters_given, kappa, beta, delta];
    else
        %%%%%%%%%%%%%%
        %%%% Parameter values
        %%%%%%%%%%%%%%
        parameters_given = [];

        pdx_0 = makedist('Triangular', 'a', 0.01, 'b', 0.05, 'c', 0.1);
        %x_0 = 0.05;%;%random(pdx_0, 1,1);
        
        %%% Initial conditions and distributions (non-deviation initials):
        pdC_at0 = makedist('Triangular', 'a', 590, 'b', 596, 'c', 602);
        C_at0   = random(pdC_at0, 1,1); % (590, 596, 602) 

        pdC_oc0 = makedist('Triangular', 'a', 1.4e5, 'b', 1.5e5, 'c', 1.6e5);
        C_oc0   = random(pdC_oc0, 1,1);%1.5e5;%random(pdC_oc0, 1,1);% (1.4, 1.5, 1.6)e5 % this can't be zero, otherwise we are dividing by zero

        pdC_veg0= makedist('Triangular', 'a', 540, 'b', 550, 'c', 560);
        C_veg0  = random(pdC_veg0, 1,1); % (540, 550, 560)

        pdC_so0 = makedist('Triangular', 'a', 1480, 'b', 1500, 'c', 1520);
        C_so0   = random(pdC_so0, 1,1);% (1480, 1500, 1520)

        pdT_0   = makedist('Triangular', 'a', 288, 'b', 288.15, 'c', 288.3);
        T_0     = random(pdT_0, 1,1); % (288, 288.15, 288.3)

        parameters_given = [x0, C_at0, C_oc0, C_veg0, C_so0, T_0];

        %%% Photosynthesis params.
        pdk_p = makedist('Triangular', 'a', 0.9*0.184, 'b', 0.184, 'c', 1.1*0.184);
        k_p   = random(pdk_p, 1,1); % (0.175, 0.184, 0.193)
        
        %pdk_MM = makedist('Triangular', 'a', 0.9*1.478, 'b', 1.478, 'c', 1.1*1.478);
        %k_MM = 1.478;%;%random(pdk_MM, 1,1); 

        pdk_c = makedist('Triangular', 'a', 0.9*29e-6, 'b', 29e-6, 'c', 1.1*29e-6);
        k_c   = random(pdk_c, 1,1); % (26, 29, 32)e-6

        pdk_M = makedist('Triangular', 'a', 0.9*120e-6, 'b', 120e-6, 'c', 1.1*120e-6);
        k_M   = random(pdk_M, 1,1); % (108, 120, 132) e-6

        k_a  = 1.773.*10^(20); % mole vol. of atmos 

        parameters_given = [parameters_given, k_p, k_MM, k_c, k_M, k_a];

        %%% Plant resp. params:
        pdk_r = makedist('Triangular', 'a', 0.0828, 'b', 0.092, 'c', 0.1012);
        k_r   = random(pdk_r, 1,1); % (0.0828, 0.092, 0.1012)
        
        %pdk_A = makedist('Triangular', 'a', 0.9*8.7039e9, 'b',8.7039e9, 'c', 1.1*8.7039e9);
        %k_A   = 8.7039e9;%;%random(pdk_A, 1,1);
        
        %E_a = 54.83;
        pdE_a = makedist('Triangular', 'a', 0.9*54.83e3, 'b', 54.83e3, 'c', 1.1*54.83e3);
        E_a   = random(pdE_a, 1,1); % (54.63, 54.83, 55.03)e3 % In Bury's mathematica nb this is whereas in SI it isn't cubed

        %%% Soil resp. params:
        pdk_sr = makedist('Triangular', 'a', 0.9*0.034, 'b', 0.0337, 'c', 1.1*0.034);
        k_sr = random(pdk_sr,1,1); % soil resp. rate const.(0.0303, 0.034, 0.037)
        
        %pdk_B = makedist('Triangular', 'a', 0.9*157.072, 'b', 157.072, 'c', 1.1*157.072);
        %k_B  = 157.072;%;%random(pdk_B, 1, 1); %
        

        parameters_given = [parameters_given, k_r, k_A, E_a, k_sr, k_B];
        %%%% Turnover params:
        pdk_t = makedist('Triangular', 'a', 0.9*0.092, 'b', 0.092, 'c', 1.1*0.092);
        k_t = random(pdk_t,1,1); % (0.0828, 0.092, 0.1012)

        %%%% Heat cap. of Earth's surface:
        pdc = makedist('Triangular', 'a', 0.9*4.69e23, 'b', 4.69e23, 'c', 1.1*4.69e23);
        c = random(pdc,1,1); % (4.22, 4.69, 5.16)e23

        parameters_given = [parameters_given, k_t, c];

        %%%% Constants:
        a_E   = 5.101*10^(14); % Earth's surface area 
        sigma = 5.67*10^(-8); % Stefan-Boltzmann const. 
        latent_heat = 43655; 
        R = 8.314; % molar gas const.
        H = 0.5915; % relative humidity; calibrated

        pdA = makedist('Triangular', 'a', 0.9*0.225, 'b', 0.225, 'c', 1.1*0.225);
        A = random(pdA,1,1); % surface albedo (0.203, 0.225, 0.248)

        pdS = makedist('Triangular', 'a', 0.9*1368, 'b', 1368, 'c', 1.1*1368);
        S = random(pdS,1,1); % solar flux (1231, 1368, 1504)

        parameters_given = [parameters_given, a_E, sigma, latent_heat, R, H, A, S];

        pdtao_CH4 = makedist('Triangular', 'a', 0.9*0.0231, 'b', 0.0231, 'c', 1.1*0.0231);
        tao_CH4 = random(pdtao_CH4,1,1); % (0.0208, 0.0231, 0.0254) see: atmos_down_flux to resolve potential probs.

        pdP_0 = makedist('Triangular', 'a', 0.9*1.4e11, 'b', 1.4e11, 'c', 1.1*1.4e11);
        P_0   = random(pdP_0, 1,1); % (1.26, 1.4, 1.54)e11 water vapor sat. const.

        pdF_0 = makedist('Triangular', 'a', 2.25e-2, 'b', 2.5e-2, 'c', 2.75e-2);
        F_0   = random(pdF_0,1,1); % (2.25, 2.5, 2.75)e-2 ocean flux rate const.

        pdChi = makedist('Triangular', 'a', 0.2, 'b', 0.3, 'c', 0.4);
        chi   = random(pdChi,1,1); % (0.2, 0.3, 0.4) characteristic CO2 solubility

        pdZeta = makedist('Triangular', 'a', 40, 'b', 50, 'c', 60);
        zeta   = random(pdZeta,1,1); % (40, 50, 60) "evasion factor"

        parameters_given = [parameters_given, tao_CH4, P_0, F_0, chi, zeta];

        pdf_max = makedist('Triangular', 'a', 4, 'b', 5, 'c', 6);
        f_max = random(pdf_max, 1, 1); % (4,5,6) max of warming cost function f(T)

        pdOmega = makedist('Triangular', 'a', 1, 'b', 3, 'c', 5);
        omega   = random(pdOmega,1,1); % (1,3,5) nonlinearity of warming cost function

        pdT_c = makedist('Triangular', 'a', 2, 'b', 2.5, 'c', 3);
        T_c   = random(pdT_c,1,1); % (2.4, 2.5, 2.6) critical temperature of f(T)
        
        t_p   = 10; % num. prev. yrs used for temp pred.
        
        pdt_f = makedist('Triangular', 'a', 0, 'b', 25, 'c', 40);
        t_f   = 25;%random(pdt_f, 1,1); % (0, 25, 50) num yrs ahead for temp. proj.

        %pds_  = makedist('Triangular', 'a', 30, 'b', 50, 'c', 70);
        %s_    = 50;%;%random(pds_,1,1); % (30, 50, 70) half-sat. time for epsilon(t) from 2014

        pdeps_max = makedist('Triangular', 'a', 4.2, 'b', 7, 'c', 9.8);
        eps_max   = 7;%random(pdeps_max,1,1); % (4.2, 7, 9.8) max change in epsilon(t) from 2014

        f_gtm = 8.3259 .* 10^(13); % conversion factor GtC -> C; pg. 1 of Thomas' SI

        parameters_given = [parameters_given, f_max, omega, T_c, t_p, t_f, s_, eps_max, f_gtm];
        
        %pdkappa = makedist('Triangular', 'a', 0.02, 'b', 0.05, 'c', 0.2);
        %kappa = 0.05;%;%random(pdkappa, 1,1);    % (0.02, 0.05, 0.2) social learning rate
        
        %pdbeta = makedist('Triangular', 'a', 0.5, 'b', 1, 'c', 1.5);
        %beta  = 1.0;%;%random(pdbeta,1,1);    % (0.5, 1, 1.5) net cost of being a mitigator
        
        %pddelta = makedist('Triangular', 'a', 0.5, 'b', 1, 'c', 1.5);
        %delta = 1.0;%;%random(pddelta, 1,1);    % (0.5, 1, 1.5) strength of social norms

        parameters_given = [parameters_given, kappa, beta, delta];
    end
    parameters_ = parameters_given;
end