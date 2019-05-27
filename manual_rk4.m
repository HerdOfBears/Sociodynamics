%myode = @syst_odes_wSocCoupling;
h = 0.1;  % Define Step Size


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


f_max = 5; % (4,5,6) max of warming cost function f(T)
omega = 3; % (1,3,5) nonlinearity of warming cost function
T_c   = 2.5;% (2.4, 2.5, 2.6) critical temperature of f(T)
t_p   = 10; % num. prev. yrs used for temp pred.
t_f   = 25; % (0, 25, 50) num yrs ahead for temp. proj.
s_    = 50;% (30, 50, 70) half-sat. time for epsilon(t) from 2014
eps_max   = 7;% (4.2, 7, 9.8) max change in epsilon(t) from 2014

f_gtm = 8.3259 .* 10^(13); % conversion factor GtC -> C; pg. 1 of Thomas' SI

parameters_given = [parameters_given, f_max, omega, T_c, t_p, t_f, s_, eps_max, f_gtm];

kappa = 0.05;    % (0.02, 0.05, 0.2) social learning rate
beta  = 1;    % (0.5, 1, 1.5) net cost of being a mitigator
delta = 1.5;    % (0.5, 1, 1.5) strength of social norms

parameters_given = [parameters_given, kappa, beta, delta];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Numerically integrating
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initial_conditions = [0.0; 0.0; 0.0; 0.0; 0.0];%288.15];
% initial_conditions = [0.2197e3; 0.0606e3; 0.0776e3; 0.0394e3; 0.0010e3]
tspan = 1751:1:2014;
opts = odeset('AbsTol',1e-7);
%[t, yprime_woSoc] = ode45(@(t, x_vec) syst_odes_woSoc(t, x_vec, parameters_given, data), tspan, initial_conditions);

%temp_history = [t, yprime_woSoc(:, end)]; % grabs the temperature values from the comptuations that ignore social dynamics.



%initial_conditions = [0.0001e3; 0.2197e3; 0.0606e3; 0.0776e3; 0.0394e3; 0.0010e3];
global data
data = csvread('Documents/prelim/global.1751_2014.csv');
data = data(:,[1,2]); % The first two columns are: time, CO2 emissions
data(:,2) = data(:,2)./1000; % Convert from MtC -> GtC

data_1741_to_2014 = csvread('./Sociodynamics/baselineParams_woSoc_1751to2014.csv');
temp_history = data_1741_to_2014(:,[1,end]);

%initial_conditions = [0.05 ,data_1741_to_2014(end,2:end)];%[0.05; 0;0;0;0;0];
%initial_conditions = [0.05; 0;0;0;0;0];
test_1751to2014  = csvread('test_1751to2014.csv');
initial_conditions  = test_1751to2014(end,2:end)' %transposed
t_final = 2200;
tspan = 2014:0.01:t_final;
y = zeros(numel(tspan),6);
x0=0.05;
avg_ = 0;
N=1;
for idx_ = 1:1:N

    results_ = RK4(@syst_odes_wSocCoupling, tspan, initial_conditions, parameters_given, test_1751to2014, x0);
%    results_ = RK4(@syst_odes_wSocCoupling, tspan, initial_conditions, parameters_given, temp_history, x0);
    avg_ = avg_ + results_(:,2:end);
    disp(size(tspan'))
    disp(size(results_))
    csvwrite('test_2014to2200.csv',[tspan', results_])
end
%y(1,:) = initial_conditions;  % y0

%{
% You know the value a t = 0, thats why you'll state with t = h i.e. i = 2
for i = 2:numel(t)
    k1 = h*f(t(i-1),y(i-1,:), parameters_given, temp_history, x0);
    k2 = h*f(t(i-1)+h/2, y(i-1,:)+k1/2, parameters_given, temp_history, x0);
    k3 = h*f(t(i-1)+h/2, y(i-1,:)+k2/2, parameters_given, temp_history, x0);
    k4 = h*f(t(i-1)+h, y(i-1,:)+k3, parameters_given, temp_history, x0);
    y(i) = y(i-1) + (k1+2*k2+2*k3+k4)/6;
    disp([t(i) y(i)]);
end
%}
function y = RK4(odefun, tspan, y0, params_given, temp_history, x0)
% ODEFUN contains the ode functions of the system
% TSPAN  is a 1D vector of equally spaced t values
% Y0     contains the intial conditions for the system variables

    % Initialise step-size variables
    t = tspan(:); % ensure column vector = (0:h:1)';
    h = t(2)-t(1);% define h from t
    N = length(t);

    % Initialise y vector, with a column for each equation in odefun
    y = zeros(N, numel(y0));
    % Starting conditions
    y(1, :) = y0(:)';  % Set intial conditions using row vector of y0

    k = zeros(4, numel(y0));              % Initialise K vectors
    b = repmat([1 2 2 1]', 1, numel(y0)); % RK4 coefficients
    
    t_p=10./h;
    
    % Iterate, computing each K value in turn, then the i+1 step values
    for i = 1:(N-1)
        T_prev=0;
        if i <= -1
            T_prev = interp1(temp_history(:,1), temp_history(:,end), t(i)); 
        end
        if t(i)>2014 && t(i)<2024%i>t_p
            disp(1000-i)
            T_prev = temp_history(end - (1000 - i),end);
            %T_prev = y(i-1000,end);
        end
        if t(i)>2024
            T_prev = y(i-1000,end);
        end
        k(1, :) = odefun(t(i), y(i,:), params_given, T_prev, x0);        
        k(2, :) = odefun(t(i) + (h/2), y(i,:) + (h/2)*k(1,:), params_given, T_prev, x0);        
        k(3, :) = odefun(t(i) + (h/2), y(i,:) + (h/2)*k(2,:), params_given, T_prev, x0);
        %{
        if t(i)>2014%i>t_p
            disp(i+1-1000)
            T_prev = y(i+1-1000,end);
        end
        %}
        k(4, :) = odefun(t(i) + h, y(i,:) + h*k(3,:), params_given, T_prev, x0);

        y(i+1, :) = y(i, :) + (h/6)*sum(b.*k);    
    end    
end
