function finResults = ParamPlane(vary1, vary1values, vary2, vary2values, numSim, tspan)
	% Yellow Jacket Model version
    % Script created 2020-006-09 by jmenard 
    % Final script for making param planes. 
    % Input: variable1, array, variable2, array
    % vary1, vary2             : strings. Names of the variables to iterate through. 
    % vary1values, vary2values : arrays. Values to iterate over. 
    
    % If numSim >1, we'll sample the other parameters randomly and take the median(max(temperature_value)).
    if numSim>1
        numSim=1;
        disp("currently unable to accomodate numSim>1")
        disp("fmax = 5")
        disp("homophily = 0.5")
    end
	addpath('Documents/socioclimate/Sociodynamics/EarthSystemsModel');
	addpath('Documents/socioclimate/Sociodynamics/SocialDynamicsModel');
	addpath('Documents/socioclimate/Sociodynamics/data');

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%% Numerically integrating
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	rng('default');
    % rng('shuffle');

	global data
	data = csvread('Sociodynamics/data/co2TotalEmissions.csv');
	data = data(:,[1,2]); % The first two columns are: time, CO2 emissions
	data(:,2) = data(:,2); % Convert from MtC -> GtC


	test_1751to2014  = csvread('Sociodynamics/data/blineParams_1800to2014.csv');
	initial_conditions  = test_1751to2014(end,2:end)'; %transposed

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Initializations of output arrays
    vary1values_length = length(vary1values);
    vary2values_length = length(vary2values);    
    end_result_peakTempVals = zeros(vary1values_length, vary2values_length);
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

        random_params_yes_no = 0;
        if numSim > 1
    		random_params_yes_no = 1; % 1 == sample from triangle dist.; 0 == use baseline
        end

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

        if numSim == 1
            tic
        end

        for v1_idx = 1:1:vary1values_length
            for v2_idx = 1:1:vary2values_length
                v1 = vary1values(v1_idx);
                v2 = vary2values(v2_idx);

                %%% REPLACE with inputted params; parameters_given
                parameters_given.(vary1) = v1;
                parameters_given.(vary2) = v2;
                %parameters_given.homophily = 0.5;
                %parameters_given.f_max = 5;

                cond1 = (vary1=="prop_R0");
                cond2 = (vary2=="prop_R0");
                if cond1|cond2
                    parameters_given.xP0   = 0.05 .* (1 - parameters_given.prop_R0);
                    parameters_given.xR0   = 0.05 .* parameters_given.prop_R0;
                end

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
                end_result_peakTempVals(v1_idx, v2_idx) = peak_T_val_;
            end
        end
        if numSim == 1
            toc
        end
	end


    finResults = end_result_peakTempVals;
end
