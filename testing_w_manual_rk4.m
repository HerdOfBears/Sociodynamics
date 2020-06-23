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

rng('default');


%initial_conditions = [0.0001e3; 0.2197e3; 0.0606e3; 0.0776e3; 0.0394e3; 0.0010e3];
global data
%data = csvread('Documents/prelim/global.1751_2014.csv');
data = csvread('Sociodynamics/data/co2TotalEmissions.csv');
data = data(:,[1,2]); % The first two columns are: time, CO2 emissions
data(:,2) = data(:,2); % Convert from MtC -> GtC


test_1751to2014  = csvread('Sociodynamics/blineParams_1800to2014.csv');
initial_conditions  = test_1751to2014(end,2:end)'; %transposed
t_final = 2200;



tspan = 2014:0.1:t_final;
y = zeros(numel(tspan),6);

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

avg_ = 0;
temperature_vals = 0;
all_results = struct();
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
		disp(idx_)
		parameters_given = get_parameters(random_params_yes_no);
		x0 = parameters_given(1);
		initial_conditions(1) = x0;
		parameters_given= parameters_given(2:end);
		
		results_ = custom_RK4(@syst_odes_wSocCoupling, tspan, initial_conditions, parameters_given, test_1751to2014, x0);
		avg_ = avg_ + results_(:,2:end);
		if idx_==1
			temperature_vals = results_(:,end);

			all_results.xvals = [results_(:,1)];
			all_results.catm  = [results_(:,2)];
			all_results.coc   = [results_(:,3)];
			all_results.veg   = [results_(:,4)];
			all_results.cso   = [results_(:,5)];
			all_results.T     = [results_(:,6)];
		end
		if idx_>1
			temperature_vals = [temperature_vals, results_(:,end)];
			all_results.xvals = [all_results.xvals, results_(:,1)];
			all_results.catm  = [all_results.catm,   results_(:,2)];
			all_results.coc   = [all_results.coc,   results_(:,3)];
			all_results.veg   = [all_results.veg,   results_(:,4)];
			all_results.cso   = [all_results.cso,   results_(:,5)];
			all_results.T     = [all_results.T,     results_(:,6)];			
		end
	end
	avg_ = avg_./N;
	toc
end
median_vals = quantile(temperature_vals', 0.5);
bot_five    = quantile(temperature_vals', 0.05);
top_five    = quantile(temperature_vals', 0.95);


plot(test_1751to2014(:,1), test_1751to2014(:,end))
hold on
plot(tspan, avg_(:,end))
xlim([1900,2200])
ylim([0,5])
size(temperature_vals)

plot(tspan, bline_params_results(:,end))
plot(tspan, median_vals, 'LineWidth', 2)
plot(tspan, top_five, '--', 'LineWidth', 1.5)
plot(tspan, bot_five, '--', 'LineWidth', 1.5)


%{
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
			%T_prev = temp_history(end - (10000 - i),end);
			T_prev = interp1(temp_history(:,1), temp_history(:,end), t(i)-10);
			%T_prev = y(i-1000,end);
		end
		if t(i)>2024
			T_prev = y(i-1000,end);
		end
		k(1, :) = odefun(t(i), y(i,:), params_given, T_prev, x0);        
		k(2, :) = odefun(t(i) + (h/2), y(i,:) + (h/2)*k(1,:), params_given, T_prev, x0);        
		k(3, :) = odefun(t(i) + (h/2), y(i,:) + (h/2)*k(2,:), params_given, T_prev, x0);


		if t(i)>2014%i>t_p
			disp(i+1-1000)
			T_prev = y(i+1-1000,end);
		end


		if t(i)>2024
			T_prev = y(i+1-1000,end);
		end
		k(4, :) = odefun(t(i) + h, y(i,:) + h*k(3,:), params_given, T_prev, x0);

		y(i+1, :) = y(i, :) + (h/6)*sum(b.*k);    
	end    
end
%}