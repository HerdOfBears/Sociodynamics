function finResults = simESM_w_soc_YJM(numSim, tspan, homophily, alpha_P1)
	% Yellow Jacket Model version

	%h = 0.1;  % Define Step Size
	addpath('./Documents/socioclimate/Sociodynamics/EarthSystemsModel');
	addpath('./Documents/socioclimate/Sociodynamics/SocialDynamicsModel');
	addpath('./Documents/socioclimate/Sociodynamics/data');


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


	test_1751to2014  = csvread('Sociodynamics/data/blineParams_1800to2014.csv');
	initial_conditions  = test_1751to2014(end,2:end)'; %transposed
	t_final = 2200;



	%tspan = 2014:0.1:t_final;
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

	if numSim < 1
		numSim = 2;
	end

	avg_ = 0;
	temperature_vals = 0;
	all_results = struct();
	random_params_yes_no = 1; % 1 == sample from triangle dist.; 0 == baseline
	for N = [numSim]
		
			
		% disp('test:')
		% disp(N)
		parameters_baseline  = get_parameters_YJM(0);
		xP0 = parameters_baseline.xP0;
		xR0 = parameters_baseline.xR0;
		vec_proportions = [xP0, xR0];

		initial_conditions = [xP0; xR0; initial_conditions(2:end, 1)];
		
		bline_params_results = custom_RK4_YJM(@syst_odes_wSocCoupling_YJM, tspan, initial_conditions, parameters_baseline, test_1751to2014, vec_proportions);
		
		tic
		for idx_ = 1:1:N
			if rem(idx_,10) == 0
				disp(idx_)
			end
			% get parameters and set custom ones. 
			parameters_given = get_parameters_YJM(random_params_yes_no);
			parameters_given.homophily = homophily;

			if nargin==4
				parameters_given.alpha_P1 = alpha_P1;
				parameters_given.f_max = 5;
				% parameters_given.xR0 = 0.0;
				% parameters_given.xP0 = 0.0;

				% %%% Checking solar flux mechanism 
				% C_at0 = parameters_given.C_at0;
				% f_gtm = parameters_given.f_gtm;
				% k_a   = parameters_given.k_a;
				% P_0   = parameters_given.P_0;
				% latent_heat = parameters_given.latent_heat;
				% A = parameters_given.A;				
				% parameters_given.S = alpha_P1; % not really alpha_P1 here
				% tao_CH4 = parameters_given.tao_CH4;
				% S = parameters_given.S;

				% parameters_given.tao_co2 = 1.73.*(mixingCO2a(0, C_at0, f_gtm, k_a)).^0.263;
				% tao_co2 = parameters_given.tao_co2; 
				% parameters_given.H = calibrate_humidity(P_0, latent_heat, A, S, tao_CH4, tao_co2);					
			end

			% parameters_given.xP0 = 0.05;
			% parameters_given.xR0 = 0.05;			

			% parameters_given
			xP0 = parameters_given.xP0;
			xR0 = parameters_given.xR0;
			vec_proportions = [xP0, xR0];

			initial_conditions(1) = xP0;
			initial_conditions(2) = xR0;			
			% size(initial_conditions)
			%parameters_given= parameters_given(2:end);
			
			results_ = custom_RK4_YJM(@syst_odes_wSocCoupling_YJM, tspan, initial_conditions, parameters_given, test_1751to2014, vec_proportions);
			avg_ = avg_ + results_(:,2:end);
			if idx_==1
				all_results.xPvals = [results_(:,1)];
				all_results.xRvals = [results_(:,2)];				
				all_results.catm   = [results_(:,3)];
				all_results.coc    = [results_(:,4)];
				all_results.cveg   = [results_(:,5)];
				all_results.cso    = [results_(:,6)];
				all_results.T      = [results_(:,7)];
				all_results.params = [parameters_given];
				all_results.prop_R0= [parameters_given.prop_R0];
			end
			if idx_>1
				all_results.xPvals = [all_results.xPvals, results_(:,1)];
				all_results.xRvals = [all_results.xRvals, results_(:,2)];				
				all_results.catm   = [all_results.catm,   results_(:,3)];
				all_results.coc    = [all_results.coc,    results_(:,4)];
				all_results.cveg   = [all_results.cveg,   results_(:,5)];
				all_results.cso    = [all_results.cso,    results_(:,6)];
				all_results.T      = [all_results.T,      results_(:,7)];
				all_results.params = [all_results.params, parameters_given];
				all_results.prop_R0= [all_results.prop_R0, parameters_given.prop_R0];				
			end
		end
		avg_ = avg_./N;
		toc
	end
	all_results.pre2014 = test_1751to2014;
	finResults = all_results;
end