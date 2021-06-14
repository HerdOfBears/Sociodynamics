function finResults = tempvshomophily(numSim, tspan, homophilyValues)
	% Yellow Jacket Model version
    % Script created 2020-05-27 by jmenard
    % previous version sampled new parameters for each different homophily value, while we want to sample 
    % different params each simulation, not each homophily value.  


    % homophilyValues = hl:diffH:hu;

    if numSim < 1
        numSim = 2;
    end

	% addpath('./Sociodynamics/EarthSystemsModel');
	% addpath('./Sociodynamics/SocialDynamicsModel');
	% addpath('./Sociodynamics/data');
	addpath('./Documents/socioclimate/Sociodynamics/EarthSystemsModel');
	addpath('./Documents/socioclimate/Sociodynamics/SocialDynamicsModel');
	addpath('./Documents/socioclimate/Sociodynamics/data');

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%% Numerically integrating
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% rng('default');
    rng('shuffle');

	global data
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
    tic
    for idx_ = 1:1:numSim
        if rem(idx_, 10) == 0
            disp( strcat("simulation number = ", num2str(idx_)) );
            toc
            tic
        end
        % y = zeros(numel(tspan),6);

		random_params_yes_no = 1; % 1 == sample from triangle dist.; 0 == use baseline
        
        %%% FETCH params
        parameters_given = get_parameters_YJM(random_params_yes_no);

        parameters_baseline  = get_parameters_YJM(0); % Fetches baseline parameters
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
        
        for hValIdx = 1:1:length(homophilyValues)
            
            h_val = homophilyValues(hValIdx);

            %%% REPLACE with inputted params; parameters_given
            parameters_given.homophily = h_val;
            xP0 = parameters_given.xP0;
            xR0 = parameters_given.xR0;
            vec_proportions = [xP0, xR0];

            initial_conditions(1) = xP0;
            initial_conditions(2) = xR0;
            
            %%% INTEGRATE system to get results using those parameters. 
            results_ = custom_RK4_YJM(@syst_odes_wSocCoupling_YJM, tspan, initial_conditions, parameters_given, test_1751to2014, vec_proportions);
            
            %%% COLLECT results over the runs.
            %%% Grab the peak temperature over the series. 
            temperature_vals_ = results_(:,7);
            peak_T_val_ = max(temperature_vals_);
            end_result_peakTempVals(hValIdx, idx_) = peak_T_val_;
        end % Gives result for 1 sample of parameters over each homophily value.         
	end


    finResults = end_result_peakTempVals;
end