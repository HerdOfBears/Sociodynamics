function fin_results = hom_resourceDiff_paramPlane(numSim, tspan, hl, diffH, hu)
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
	t_final = 2200;


	end_results = struct();
	
	end_results.upperBound = []; % 95th percentile
	end_results.IQupp = []; % 75th percentile
	end_results.median_ = [];
	end_results.IQlow   = []; % 25th percentile
	end_results.lowerBound = []; % 5th perce

	end_results.homophily = [];
	end_results.omega_diff = [];
	end_results.omega_ratio = [];	
	end_results.maxTtime = [];
	end_results.temperature_vals = [];

	for omega_R = [0.9*5, 5, 1.1*5]
		for omega_P = fliplr([0.9*3.5, 3.5, 1.1*3.5])
			omega_diff = omega_R - omega_P;
			omega_rati = omega_P./(omega_R);
			disp( strcat("difference = ", num2str(omega_diff)) );


			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%%%%%%%%%% Iterate over homophily values.
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
			%tspan = 2014:0.1:t_final;
			for h_val = hl:diffH:hu
				disp( strcat("homophily = ", num2str(h_val)) );
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

					% initial_conditions(1) = xP0;%0.05;
					% initial_conditions(2) = xR0;
					if length(initial_conditions) == 7
						initial_conditions = [xP0; xR0; initial_conditions(3:end, 1)];
					end				
					if length(initial_conditions) == 6
						initial_conditions = [xP0; xR0; initial_conditions(2:end, 1)];
					end

					size(initial_conditions)
					% size(initial_conditions);
					% initial_conditions(1) = x0;
					%parameters_baseline = parameters_baseline(2:end);
					
					bline_params_results = custom_RK4_YJM(@syst_odes_wSocCoupling_YJM, tspan, initial_conditions, parameters_baseline, test_1751to2014, vec_proportions);
					
					tic
					for idx_ = 1:1:N
						% disp(idx_)
						parameters_given = get_parameters_YJM(random_params_yes_no);

						% parameters_given
						parameters_given.omega_R = omega_R;
						parameters_given.omega_P = omega_P;						
						parameters_given.homophily = h_val;
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
						end
						if idx_>1
							all_results.xPvals = [all_results.xPvals, results_(:,1)];
							all_results.xRvals = [all_results.xRvals, results_(:,2)];				
							all_results.catm   = [all_results.catm,   results_(:,3)];
							all_results.coc    = [all_results.coc,    results_(:,4)];
							all_results.cveg   = [all_results.cveg,   results_(:,5)];
							all_results.cso    = [all_results.cso,    results_(:,6)];
							all_results.T      = [all_results.T,      results_(:,7)];			
						end
					end
					avg_ = avg_./N;
					toc
				end
				all_results.pre2014 = test_1751to2014;
				all_results.blineParams = bline_params_results;

				temperature_vals = all_results.T;
				bline_params_results = all_results.blineParams;

				median_vals = quantile(temperature_vals', 0.5);
				bot_five    = quantile(temperature_vals', 0.05);
				bot_25 = quantile(temperature_vals', 0.25);
				top_five    = quantile(temperature_vals', 0.95);
				top_75 = quantile(temperature_vals', 0.75);


				[maxMed_T_, maxIdx_ ] = max(median_vals);
				bot_five_4maxT = bot_five(maxIdx_);
				top_five_4maxT = top_five(maxIdx_);
				maxT_time = tspan(maxIdx_);

				end_results.upperBound = [end_results.upperBound, top_five_4maxT];
				end_results.IQupp = [end_results.IQupp, top_75(maxIdx_)];
				end_results.median_    = [end_results.median_,    maxMed_T_];
				end_results.IQlow = [end_results.IQlow, bot_25(maxIdx_)];
				end_results.lowerBound = [end_results.lowerBound, bot_five_4maxT];

				end_results.temperature_vals = [end_results.temperature_vals; temperature_vals'];
				end_results.homophily  = [end_results.homophily,  h_val];
				end_results.omega_diff  = [end_results.omega_diff,  omega_diff];
				end_results.omega_ratio = [end_results.omega_ratio, omega_rati];		
				end_results.maxTtime   = [end_results.maxTtime,   maxT_time];					
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			end
		end	

	end

	fin_results = end_results;
end