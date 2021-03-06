clear all, close all, clc
addpath('./Sociodynamics/EarthSystemsModel');
addpath('./Sociodynamics/SocialDynamicsModel');

global data
global tinitial
global tfinal

data = csvread('Documents/prelim/global.1751_2014.csv');
data = data(:,[1,2]); % The first two columns are: time, CO2 emissions
data(:,2) = data(:,2)./1000; % Convert from MtC -> GtC
%data(:,1) = data(:,1) - 1751;

data_bestCase_medParams = csvread('./Sociodynamics/BestCase_medParams.csv');
data_1741_to_2014       = csvread('./Sociodynamics/BestCase_BaselineParams.csv');

tinitial = 2014;
tfinal   = 2200;

rng('default');
doing_stats = 0;

if doing_stats
    N = 200;
    for idx_ = 1:1:N
        temp_y_ = coupled_soc_esm(data);
        if idx_==1
            temp_tot = temp_y_;
            temp_var = ( temp_y_(:,end) - data_bestCase_medParams(end-(2200-2014):end,end) ).^2;
        end
        if idx_>1
            temp_tot = temp_tot + temp_y_;
            temp_var = temp_var + ( temp_y_(:,end) - data_bestCase_medParams(end-(2200-2014):end,end) ).^2;
        end
    end
    temp_avg = temp_tot ./ (N);
    temp_var = temp_var ./ (N-1);
    t  = temp_avg(:,1);
    y_ = temp_avg(:,2:end);
    
    temp_std = sqrt(temp_var);
    upper_y_ = data_bestCase_medParams(end-(2200-2014):end,end)+temp_std;
    lower_y_ = data_bestCase_medParams(end-(2200-2014):end,end)-temp_std;
    %plot(t, upper_y_)
    %plot(t, lower_y_)
    
end

if ~doing_stats
    temp_y_ = coupled_soc_esm(data);
    t  = temp_y_(:,1);
    y_ = temp_y_(:,2:end);
end

%plot(t, y_(:,end))
hold on
plot(data_bestCase_medParams(1:(2014-1750),1), data_1741_to_2014(:,end))
plot(data_bestCase_medParams(:,1),data_bestCase_medParams(:,end))

xlim([1900,2200])
ylim([0,5])

plot(t, upper_y_)
plot(t, lower_y_)

% csvwrite('Sociodynamics/BestCase_medParams.csv', temp_avg)

function results_dXdt = coupled_soc_esm(data)
    global tinitial
    global tfinal
    %%%%%%%%%%%%%%
    %%%% Parameter values
    %%%%%%%%%%%%%%
    parameters_given = [];

    %%% Initial conditions and distributions (non-deviation initials):
    pdC_at0 = makedist('Triangular', 'a', 590, 'b', 596, 'c', 602);
    C_at0   = random(pdC_at0, 1,1); % (590, 596, 602) 

    pdC_oc0 = makedist('Triangular', 'a', 1.4e5, 'b', 1.5e5, 'c', 1.6e5);
    C_oc0   = random(pdC_oc0, 1,1);% (1.4, 1.5, 1.6)e5 % this can't be zero, otherwise we are dividing by zero

    pdC_veg0= makedist('Triangular', 'a', 540, 'b', 550, 'c', 560);
    C_veg0  = random(pdC_veg0, 1,1); % (540, 550, 560)

    pdC_so0 = makedist('Triangular', 'a', 1480, 'b', 1500, 'c', 1520);
    C_so0   = random(pdC_so0, 1,1);% (1480, 1500, 1520)

    pdT_0   = makedist('Triangular', 'a', 288, 'b', 288.15, 'c', 288.3);
    T_0     = random(pdT_0, 1,1); % (288, 288.15, 288.3)

    parameters_given = [C_at0, C_oc0, C_veg0, C_so0, T_0];

    %%% Photosynthesis params.
    pdk_p = makedist('Triangular', 'a', 0.175, 'b', 0.184, 'c', 0.193);
    k_p   = random(pdk_p, 1,1); % (0.175, 0.184, 0.193)

    k_MM = 1.478; 

    pdk_c = makedist('Triangular', 'a', 26e-6, 'b', 29e-6, 'c', 32e-6);
    k_c   = random(pdk_c, 1,1); % (26, 29, 32)e-6

    pdk_M = makedist('Triangular', 'a', 108e-6, 'b', 120e-6, 'c', 132e-6);
    k_M   = random(pdk_M, 1,1); % (108, 120, 132) e-6

    k_a  = 1.773.*10^(20); % mole vol. of atmos 

    parameters_given = [parameters_given, k_p, k_MM, k_c, k_M, k_a];

    %%% Plant resp. params:
    pdk_r = makedist('Triangular', 'a', 0.0828, 'b', 0.092, 'c', 0.1012);
    k_r   = random(pdk_r, 1,1); % (0.0828, 0.092, 0.1012)
    k_A   = 8.7039.*10^(9);
    %E_a = 54.83;
    pdE_a = makedist('Triangular', 'a', 54.63e3, 'b', 54.83e3, 'c', 55.03e3);
    E_a   = random(pdE_a, 1,1); % (54.63, 54.83, 55.03)e3 % In Bury's mathematica nb this is whereas in SI it isn't cubed

    %%% Soil resp. params:
    pdk_sr = makedist('Triangular', 'a', 0.0303, 'b', 0.034, 'c', 0.037);
    k_sr = random(pdk_sr,1,1); % soil resp. rate const.(0.0303, 0.034, 0.037)
    k_B  = 157.072; %

    parameters_given = [parameters_given, k_r, k_A, E_a, k_sr, k_B];
    %%%% Turnover params:
    pdk_t = makedist('Triangular', 'a', 0.0828, 'b', 0.092, 'c', 0.1012);
    k_t = random(pdk_t,1,1); % (0.0828, 0.092, 0.1012)

    %%%% Heat cap. of Earth's surface:
    pdc = makedist('Triangular', 'a', 4.22e23, 'b', 4.69e23, 'c', 5.16e23);
    c = random(pdc,1,1); % (4.22, 4.69, 5.16)e23

    parameters_given = [parameters_given, k_t, c];

    %%%% Constants:
    a_E   = 5.101*10^(14); % Earth's surface area 
    sigma = 5.67*10^(-8); % Stefan-Boltzmann const. 
    latent_heat = 43655; 
    R = 8.314; % molar gas const.
    H = 0.5915; % relative humidity; calibrated

    pdA = makedist('Triangular', 'a', 0.203, 'b', 0.225, 'c', 0.248);
    A = random(pdA,1,1); % surface albedo (0.203, 0.225, 0.248)

    pdS = makedist('Triangular', 'a', 1231, 'b', 1368, 'c', 1504);
    S = random(pdS,1,1); % solar flux (1231, 1368, 1504)

    parameters_given = [parameters_given, a_E, sigma, latent_heat, R, H, A, S];

    pdtao_CH4 = makedist('Triangular', 'a', 0.0208, 'b', 0.0231, 'c', 0.0254);
    tao_CH4 = random(pdtao_CH4,1,1); % (0.0208, 0.0231, 0.0254) see: atmos_down_flux to resolve potential probs.

    pdP_0 = makedist('Triangular', 'a', 1.26e11, 'b', 1.4e11, 'c', 1.54e11);
    P_0   = random(pdP_0, 1,1); % (1.26, 1.4, 1.54)e11 water vapor sat. const.

    pdF_0 = makedist('Triangular', 'a', 2.25e-2, 'b', 2.5e-2, 'c', 2.75e-2);
    F_0   = random(pdF_0,1,1); % (2.25, 2.5, 2.75)e-2 ocean flux rate const.

    pdChi = makedist('Triangular', 'a', 0.2, 'b', 0.3, 'c', 0.4);
    chi   = random(pdChi,1,1); % (0.2, 0.3, 0.4) characteristic CO2 solubility

    pdZeta = makedist('Triangular', 'a', 40, 'b', 50, 'c', 60);
    zeta   = random(pdZeta,1,1); % (40, 50, 60) "evasion factor"

    parameters_given = [parameters_given, tao_CH4, P_0, F_0, chi, zeta];


    f_max = 6; % (4,5,6) max of warming cost function f(T)

    pdOmega = makedist('Triangular', 'a', 1, 'b', 3, 'c', 5);
    omega   = random(pdOmega,1,1); % (1,3,5) nonlinearity of warming cost function

    pdT_c = makedist('Triangular', 'a', 2.4, 'b', 2.5, 'c', 2.6);
    T_c   = random(pdT_c,1,1); % (2.4, 2.5, 2.6) critical temperature of f(T)
    t_p   = 10; % num. prev. yrs used for temp pred.
    t_f   = 50; % (0, 25, 50) num yrs ahead for temp. proj.

    pds_  = makedist('Triangular', 'a', 30, 'b', 50, 'c', 70);
    s_    = random(pds_,1,1); % (30, 50, 70) half-sat. time for epsilon(t) from 2014

    pdeps_max = makedist('Triangular', 'a', 4.2, 'b', 7, 'c', 9.8);
    eps_max   = random(pdeps_max,1,1); % (4.2, 7, 9.8) max change in epsilon(t) from 2014

    f_gtm = 8.3259 .* 10^(13); % conversion factor GtC -> C; pg. 1 of Thomas' SI

    parameters_given = [parameters_given, f_max, omega, T_c, t_p, t_f, s_, eps_max, f_gtm];

    kappa = 0.2;    % (0.02, 0.05, 0.2) social learning rate
    beta  = 0.5;    % (0.5, 1, 1.5) net cost of being a mitigator
    delta = 0.5;    % (0.5, 1, 1.5) strength of social norms

    parameters_given = [parameters_given, kappa, beta, delta];

    
    
    %%%%%%%%%%% WITHOUT SOCIAL DYNAMICS 
    % Mostly used to compute the temperature history. 
    %%%%%%%%%%%%%%%%%%%%%%
    %%%%% Initial conditions.
    %%%%%%%%%%%%%%%%%%%%%%
    %{
    Most are initially zero because we are computing deviations from
    the initial value. 
    %}
    initial_conditions = [0.0; 0.0; 0.0; 0.0; 0.0];%288.15];
    % initial_conditions = [0.2197e3; 0.0606e3; 0.0776e3; 0.0394e3; 0.0010e3]
    tspan = 1751:1:tfinal;
    opts = odeset('AbsTol',1e-7);
    [t, yprime_woSoc] = ode45(@(t, x_vec) syst_odes_woSoc(t, x_vec, parameters_given, data), tspan, initial_conditions);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%% WITH SOCIAL DYNAMICS COUPLING
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Initial conditions.
    %{
    Most are initially zero because we are computing deviations from
    the initial value. 
    %}
    x0 = 0.05; % (0.01, 0.05, 0.1 )
    %initial_conditions = [x0; 0.0; 0.0; 0.0; 0.0; 0.0];%288.15];
    initial_conditions = [0.0001e3; 0.2197e3; 0.0606e3; 0.0776e3; 0.0394e3; 0.0010e3];    
    tspan = tinitial:1:tfinal;

    temp_history = [t, yprime_woSoc(:, 5)]; % grabs the temperature values from the comptuations that ignore social dynamics.

    opts = odeset('AbsTol',1e-7);
    [t, y_] = ode45(@(t, x_vec) syst_odes_wSocCoupling(t, x_vec, parameters_given, temp_history, x0), tspan, initial_conditions);
    
    results_dXdt = [t, y_];
end
