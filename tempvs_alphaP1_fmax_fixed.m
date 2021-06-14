function finResults = tempvs_alphaP1_fmax_fixed(numSim, tspan, homophilyVal, alphaP1Values, fmax_)
	% Yellow Jacket Model version
    % Script created 2020-05-28 by jmenard
    % previous version sampled new parameters for each different homophily and alpha_P1 val, while we want to sample 
    % different params each simulation, not each homophily value.  


    homophilyValues = homophilyVal;% hl:diffH:hu;
    % fmax_ = 5; % this is the baseline amplitude of the Cost of Climate Change fctn

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

	rng('default');

	global data
	data = csvread('Sociodynamics/data/co2TotalEmissions.csv');
	data = data(:,[1,2]); % The first two columns are: time, CO2 emissions
	data(:,2) = data(:,2); % Convert from MtC -> GtC


	test_1751to2014  = csvread('Sociodynamics/data/blineParams_1800to2014.csv');
	initial_conditions  = test_1751to2014(end,2:end)'; %transposed

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%% Initializations of output arrays
    end_result_peakTempVals = zeros(length(alphaP1Values), numSim);
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

		random_params_yes_no = 1; % 1 == sample from triangle dist.; 0 == baseline
        
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

        %%% FETCH params
        parameters_given = get_parameters_YJM(random_params_yes_no);

        %%% Gets the results using baseline parameters. 
        % initial_conditions(1) = x0;
        % parameters_baseline = parameters_baseline(2:end);
        % bline_params_results = custom_RK4_YJM(@syst_odes_wSocCoupling_YJM, tspan, initial_conditions, parameters_baseline, test_1751to2014, vec_proportions);
        
        for hValIdx = 1:1:length(homophilyValues)
            for ap1ValIdx_ = 1:1:length(alphaP1Values)
                h_val   = homophilyValues(hValIdx);
                ap1_val = alphaP1Values(ap1ValIdx_);
    
                %%% REPLACE with inputted params; parameters_given
                parameters_given.homophily = h_val;
                parameters_given.alpha_P1  = ap1_val;
                parameters_given.f_max     = fmax_;                
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
                end_result_peakTempVals(ap1ValIdx_, idx_) = peak_T_val_;
            end
        end % Gives result for 1 sample of parameters over each homophily value.         
	end


    finResults = end_result_peakTempVals;
end