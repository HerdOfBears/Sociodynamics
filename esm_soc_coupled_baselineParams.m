%{

Runs numerical integration up to 2014 using baseline parameters.
Made a separate script s.t. it is easier to get the baseline parameter data
rather than having to replace all of the random sampling with consts. and
back again.

%}
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
tinitial = 1751;
tfinal   = 2014;

rng('default');
N = 2;

temp_y_ = coupled_soc_esm(data);
plot(temp_y_(:,1),temp_y_(:,end))

%csvwrite('Sociodynamics/BestCase_BaselineParams.csv', temp_y_)

hold on
xlim([1900,2200])
ylim([0,5])


function results_dXdt = coupled_soc_esm(data)
    global tinitial
    global tfinal
    %%%%%%%%%%%%%%
    %%%% Parameter values
    %%%%%%%%%%%%%%
    parameters_given = [];

    %%% Initial conditions and distributions (non-deviation initials):
    C_at0   = 596;% (590, 596, 602) 

    C_oc0   = 1.5e5;% (1.4, 1.5, 1.6)e5 % this can't be zero, otherwise we are dividing by zero

    C_veg0  = 550;% (540, 550, 560)

    C_so0   = 1500;% (1480, 1500, 1520)

    T_0     = 288.15;% (288, 288.15, 288.3)

    parameters_given = [C_at0, C_oc0, C_veg0, C_so0, T_0];

    %%% Photosynthesis params.
    k_p   = 0.184;%(0.175, 0.184, 0.193)

    k_MM = 1.478; 
    k_c   = 29e-6;%(26, 29, 32)e-6
    k_M   = 120e-6;% (108, 120, 132) e-6

    k_a  = 1.773.*10^(20); % mole vol. of atmos 

    parameters_given = [parameters_given, k_p, k_MM, k_c, k_M, k_a];

    %%% Plant resp. params:
    k_r   = 0.092;%(0.0828, 0.092, 0.1012)
    k_A   = 8.7039.*10^(9);
    %E_a = 54.83;
    E_a   = 54.83e3;% (54.63, 54.83, 55.03)e3 % In Bury's mathematica nb this is whereas in SI it isn't cubed

    %%% Soil resp. params:
    k_sr = 0.034;% soil resp. rate const.(0.0303, 0.034, 0.037)
    k_B  = 157.072; %

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
    P_0   = 1.4e11;% random(pdP_0, 1,1); % (1.26, 1.4, 1.54)e11 water vapor sat. const.
    F_0   = 2.5e-2;% (2.25, 2.5, 2.75)e-2 ocean flux rate const.
    chi   = 0.3;% (0.2, 0.3, 0.4) characteristic CO2 solubility
    zeta   = 50;% (40, 50, 60) "evasion factor"

    parameters_given = [parameters_given, tao_CH4, P_0, F_0, chi, zeta];


    f_max = 6; % (4,5,6) max of warming cost function f(T)
    omega = 3 % (1,3,5) nonlinearity of warming cost function
    T_c   = 2.5;% (2.4, 2.5, 2.6) critical temperature of f(T)
    t_p   = 10; % num. prev. yrs used for temp pred.
    t_f   = 50; % (0, 25, 50) num yrs ahead for temp. proj.
    s_    = 50;% (30, 50, 70) half-sat. time for epsilon(t) from 2014
    eps_max   = 7;% (4.2, 7, 9.8) max change in epsilon(t) from 2014

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
    tspan = tinitial:1:tfinal;
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
    initial_conditions = [x0; 0.0; 0.0; 0.0; 0.0; 0.0];%288.15];
    tspan = tinitial:1:tfinal;

    temp_history = [t, yprime_woSoc(:, 5)]; % grabs the temperature values from the comptuations that ignore social dynamics.

    opts = odeset('AbsTol',1e-7);
    [t, y_] = ode45(@(t, x_vec) syst_odes_wSocCoupling(t, x_vec, parameters_given, temp_history, x0), tspan, initial_conditions);
    
    results_dXdt = [t, y_];
end
