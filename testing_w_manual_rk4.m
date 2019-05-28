%{

Baseline parameters used only. Testing to be sure that the manual_rk4
method correctly produces the piecewise sol'n 1751to2014 & 2014to2200

%}
%myode = @syst_odes_wSocCoupling;
h = 0.1;  % Define Step Size
addpath('./Sociodynamics/EarthSystemsModel');
addpath('./Sociodynamics/SocialDynamicsModel');
addpath('./Sociodynamics/data');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Numerically integrating
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initial_conditions = [0.0; 0.0; 0.0; 0.0; 0.0];%288.15];
% initial_conditions = [0.2197e3; 0.0606e3; 0.0776e3; 0.0394e3; 0.0010e3]
tspan = 1800:1:2014;
opts = odeset('AbsTol',1e-7);
%[t, yprime_woSoc] = ode45(@(t, x_vec) syst_odes_woSoc(t, x_vec, parameters_given, data), tspan, initial_conditions);

%temp_history = [t, yprime_woSoc(:, end)]; % grabs the temperature values from the comptuations that ignore social dynamics.
rng('default');


%initial_conditions = [0.0001e3; 0.2197e3; 0.0606e3; 0.0776e3; 0.0394e3; 0.0010e3];
global data
%data = csvread('Documents/prelim/global.1751_2014.csv');
data = csvread('Sociodynamics/data/co2TotalEmissions.csv');
data = data(:,[1,2]); % The first two columns are: time, CO2 emissions
data(:,2) = data(:,2); % Convert from MtC -> GtC

data_1741_to_2014 = csvread('./Sociodynamics/baselineParams_woSoc_1751to2014.csv');
temp_history = data_1741_to_2014(:,[1,end]);

%initial_conditions = [0.05 ,data_1741_to_2014(end,2:end)];%[0.05; 0;0;0;0;0];
%initial_conditions = [0.05; 0;0;0;0;0];
%test_1751to2014  = csvread('Sociodynamics/test_1751to2014.csv');
test_1751to2014  = csvread('Sociodynamics/blineParams_1800to2014.csv');
initial_conditions  = test_1751to2014(end,2:end)'; %transposed
t_final = 2200;



tspan = 2014:0.1:t_final;
y = zeros(numel(tspan),6);
x0=0.05;
initial_conditions(1) = x0;
avg_ = 0;
ssd_ = 0;
%N=2;

%%% Gets results for baseline parameters starting from 1800
%{
tspan = 1800:0.1:2014;
initial_conditions = [0.0;0;0;0;0;0];
parameters_baseline  = get_parameters(0);
x0 = 0;%parameters_baseline(1);
parameters_baseline = parameters_baseline(2:end);
disp(x0)
disp(parameters_baseline(1:6))
wtf_is_happening = custom_RK4(@syst_odes_wSocCoupling, tspan, initial_conditions, parameters_baseline, test_1751to2014, x0);
wtf_is_happening = [tspan', wtf_is_happening];
initial_conditions = wtf_is_happening(end, 2:end);
return

%}
tspan = 2014:0.1:t_final;

temperature_vals = 0;

random_params_yes_no = 1; % 1 == sample from triangle dist.; 0 == baseline
for N = [100]
    
        
    disp('test:')
    disp(N)
    parameters_baseline  = get_parameters(0);
    x0 = parameters_baseline(1);
    initial_conditions(1) = x0;
    parameters_baseline = parameters_baseline(2:end);
    
    bline_params_results = custom_RK4(@syst_odes_wSocCoupling, tspan, initial_conditions, parameters_baseline, test_1751to2014, x0);
    
    tic
    for idx_ = 1:1:N
        parameters_given = get_parameters(random_params_yes_no);
        x0 = parameters_given(1);
        initial_conditions(1) = x0;
        parameters_given= parameters_given(2:end);
        
        results_ = custom_RK4(@syst_odes_wSocCoupling, tspan, initial_conditions, parameters_given, test_1751to2014, x0);
    %    results_ = RK4(@syst_odes_wSocCoupling, tspan, initial_conditions, parameters_given, temp_history, x0);
        diff_frm_bline = (results_ - bline_params_results).^2;
        avg_ = avg_ + results_(:,2:end);
        ssd_ = ssd_ + diff_frm_bline(:,2:end);
        if idx_==1
            temperature_vals = results_(:,end);
        end
        if idx_>1
            temperature_vals = [temperature_vals, results_(:,end)];
        end
        %disp(size(tspan'))
        %disp(size(results_))
        %csvwrite('test_2014to2200.csv',[tspan', results_])
    end
    avg_ = avg_./N;
    ssd_ = ssd_./(N);
    toc
end
plot(test_1751to2014(:,1), test_1751to2014(:,end))
hold on
plot(tspan, avg_(:,end))
xlim([1900,2200])
ylim([0,5])
size(temperature_vals)
%plot(tspan, bline_params_results(:,end)+sqrt(ssd_(:,end)), '--')
%plot(tspan, bline_params_results(:,end)-sqrt(ssd_(:,end)),'--')
median_vals = quantile(temperature_vals', 0.5);
bot_five    = quantile(temperature_vals', 0.05);
top_five    = quantile(temperature_vals', 0.95);
%plot(tspan, temperature_vals)
plot(tspan, bline_params_results(:,end))
plot(tspan, median_vals, 'LineWidth', 1.5)
plot(tspan, top_five, '--')
plot(tspan, bot_five, '--')
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
function y = custom_RK4(odefun, tspan, y0, params_given, temp_history, x0)
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
            %disp(1000-i)
            %size(temp_history)
            T_prev = temp_history(end - (100 - i),end);
            %T_prev = y(i-1000,end);
        end
        if t(i)>2024
            T_prev = y(i-100,end);
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
        if t(i)>2024
            T_prev = y(i+1-100,end);
        end
        k(4, :) = odefun(t(i) + h, y(i,:) + h*k(3,:), params_given, T_prev, x0);

        y(i+1, :) = y(i, :) + (h/6)*sum(b.*k);    
    end    
end
