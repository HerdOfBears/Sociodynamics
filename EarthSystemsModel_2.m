clear all, close all, clc
addpath('./EarthSystemsModel');

global data
data = csvread('Documents/prelim/global.1751_2014.csv');
data = data(:,[1,2]); % The first two columns are: time, CO2 emissions
data(:,2) = data(:,2)./1000; % Convert from MtC -> GtC


% Initial conditions.
%{
Most are initially zero because we are computing deviations from
the initial value. 
%}
initial_conditions = [0; 0; 0; 0; 0];%288.15];
tspan = 1950:1960;
[t, y_] = ode45(@syst_odes, tspan, initial_conditions)

function yprime = syst_odes(t, x_vec)

    global data

    C_at   = x_vec(1);
    C_oc   = x_vec(2);
    C_veg  = x_vec(3);
    C_so   = x_vec(4);
    T      = x_vec(5);
    
    %%% Initial conditions (non-deviation initials):
    C_at0   = 590;
    C_oc0   = 1.4.*10^(5);% % this can't be zero, otherwise we are dividing by zero
    C_veg0  = 540;
    C_so0   = 1480;
    T_0     = 288.15;
    
    %%% Photosynthesis params.
    k_p  = 0.175;
    k_MM = 1.478;
    k_c  = 26.* 10^(-6);
    k_M  = 108.* 10^(-6);
    
    k_a  = 1.773.*10^(20); % mole vol. of atmos
    
    %%% Plant resp. params:
    k_r = 0.0828;
    k_A = 8.7039*10^(9);
    %E_a = 54.63;
    E_a = (54.63).*10^(3); % In Bury's mathematica nb this is whereas in SI it isn't cubed
    
    %%% Soil resp. params:
    k_sr = 0.0303; % soil resp. rate const.
    k_B  = 157.072;
    
    %%% Turnover params:
    k_t = 0.0828;
    
    % Heat cap. of Earth's surface:
    c = 4.22 .* 10^(23); %
    
    % Constants:
    a_E   = 5.101*10^(14); % Earth's surface area
    sigma = 5.67*10^(-8); % Stefan-Boltzmann const. 
    latent_heat = 43655; 
    R = 8.314; % molar gas const.
    H = 0.5915; % relative humidity; calibrated
    A = 0.203; % surface albedo
    S = 1231; % solar flux
    
    tao_CH4 = 0.0208; % see: atmos_down_flux to resolve potential probs.
    P_0 = 1.26 .* 10^(11); % water vapor sat. const.
    F_0 = 2.25 .* 10^(-2); % ocean flux rate const.
    
    chi = 0.2; % characteristic CO2 solubility
    zeta = 40; % "evasion factor"
    
    f_max = 4; % max of warming cost function f(T)
    omega = 1; % nonlinearity of warming cost function
    T_c   = 2.4; % critical temperature of f(T)
    t_p   = 10; % num. prev. yrs used for temp pred.
    t_f   = 0; % num yrs ahead for temp. proj.
    s_    = 30; % half-sat. time for epsilon(t) from 2014
    eps_max = 4.2; % max change in epsilon(t) from 2014
    
    f_gtm = 8.3259 .* 10^(13); % conversion factor GtC -> C; pg. 1 of Thomas' SI
    
    
    %%%%%%%%%%%%%%%%
    %%% Functions to solve
    %%%%%%%%%%%%%%%%
    
    % Socio-dynamics model
    
    % Compute intermediates (resp. and photosynthesis etc.)
    pCO2a = mixingCO2a(C_at, C_at0, f_gtm, k_a);
%     disp('pCO2a = ')
%     disp(pCO2a)
    
    P     = photosynthesis(C_at, T, pCO2a, k_p, C_veg0, k_a, k_MM, k_c, k_M, T_0);
    R_veg = plant_respiration(C_veg, T, k_r, k_A, E_a, T_0, C_veg0);
    R_so  = soil_respiration(T, C_so, k_sr, k_B, T_0, C_so0);
    L_    = turnover(C_veg, k_t, C_veg0);
    F_oc  = ocean_flux(C_at, C_oc, F_0, chi, zeta, C_at0, C_oc0);
    F_d   = atmos_down_flux(pCO2a, A, S, P_0, latent_heat, T, tao_CH4, T_0);
    
    % disp(F_d)
    
    epsilon_T = baseline_CO2_emis(t, eps_max, s_, data);
    %%% Carbon uptake DEs
    x=0;
    
    y2 = C_at_dot(t, x, P, R_veg, R_so, F_oc, epsilon_T);  % Atmospheric
    y3 = C_oc_dot(t, F_oc);  % Ocean
    y4 = C_veg_dot(t, P, R_veg, L_); % Vegetation
    y5 = C_so_dot(t, R_so, L_);  % Soil
    
    
    %%% Temperature change
    y6 = c_T_dot(t, F_d, T, c, T_0);
    %disp(F_oc)
    disp(T)
    disp('C_oc = ')
    disp(C_oc)
    %%% RESULT
    yprime = [y2; y3; y4; y5; y6];
end