function finResults = tempvsinequality(numSim, tspan)
	% Yellow Jacket Model version

	%h = 0.1;  % Define Step Size
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


	test_1751to2014  = csvread('Sociodynamics/data/blineParams_1800to2014.csv');
	initial_conditions  = test_1751to2014(end,2:end)'; %transposed


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%% Initializations of output arrays
	end_result_peakTempVals = zeros(length(homophilyValues), numSim);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%% Iterate over simulations. Sample params. Iterate over homophily vals. 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	%%% Iterate through the number of simulations (numSim) we are doing.         
	%%% 1) FETCH parameters, sampled from triangle distributions
	%%% Iterate through homophily values
	%%% 2) REPLACE inputted params. 
	%%% 3) numerically INTEGRATE system, getting results for those params
	%%% 4) Compute max of median, and median of max
	%%% 5) Collect into struct for output. 
	for omega_R = [0.9*5, 5, 1.1*5, 1.3*5, 1.5*5,2*5]
		for omega_P = fliplr([ 3.5])
			omega_diff = omega_R - omega_P;
			omega_rati = omega_P./(omega_R);
			disp( strcat("difference = ", num2str(omega_diff)) );
			y = zeros(numel(tspan),6);


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

				% initial_conditions(1) = xP0;%0.05;
				% initial_conditions(2) = xR0;
				if length(initial_conditions) == 7
					initial_conditions = [xP0; xR0; initial_conditions(3:end, 1)];
				end				
				if length(initial_conditions) == 6
					initial_conditions = [xP0; xR0; initial_conditions(2:end, 1)];
				end

				% size(initial_conditions)
				% size(initial_conditions);
				% initial_conditions(1) = x0;
				%parameters_baseline = parameters_baseline(2:end);
				
				bline_params_results = custom_RK4_YJM(@syst_odes_wSocCoupling_YJM, tspan, initial_conditions, parameters_baseline, test_1751to2014, vec_proportions);
				
				tic
				for idx_ = 1:1:N
					% disp('N = ',N)
					% disp(idx_)
					parameters_given = get_parameters_YJM(random_params_yes_no);

					% parameters_given
					% parameters_given.homophily = 0;
					parameters_given.omega_R = omega_R;
					parameters_given.omega_P = omega_P;
					xP0 = parameters_given.xP0;
					xR0 = parameters_given.xR0;
					vec_proportions = [xP0, xR0];

					initial_conditions(1) = xP0;
					initial_conditions(2) = xR0;			
					% size(initial_conditions)
					%parameters_given= parameters_given(2:end);
					
					results_ = custom_RK4_YJM(@syst_odes_wSocCoupling_YJM, tspan, initial_conditions, parameters_given, test_1751to2014, vec_proportions);
					avg_ = avg_ + results_(:,2:end);

				end
				avg_ = avg_./N;
				toc
			end
			temperature_vals = all_results.T;
			bline_params_results = all_results.blineParams;

			[maxMed_T_, maxIdx_ ]    = max(median_vals);
	end



	finResults = end_results;
end