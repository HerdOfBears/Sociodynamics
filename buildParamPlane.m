function simResults = buildParamPlane(param1, param1_L, param1_H, param2, param2_L, param2_H, dt)

	random_params_yes_no = 0; % 0: no; 1: yes

	tspan = 2014:0.1:2150;

	%% Get params
	parameters_given = get_parameters_YJM(random_params_yes_no);
	% parameters_given
	xP0 = parameters_given.xP0;
	xR0 = parameters_given.xR0;
	vec_proportions = [xP0, xR0];


	global data
	%data = csvread('Documents/prelim/global.1751_2014.csv');
	data = csvread('Sociodynamics/data/co2TotalEmissions.csv');
	data = data(:,[1,2]); % The first two columns are: time, CO2 emissions
	data(:,2) = data(:,2); % Convert from MtC -> GtC

	test_1751to2014  = csvread('Sociodynamics/data/blineParams_1800to2014.csv');
	initial_conditions  = test_1751to2014(end,2:end)'; %transposed


	initial_conditions = [xP0; xR0; initial_conditions(2:end, 1)];
	% size(initial_conditions)
	%parameters_given= parameters_given(2:end);
	
	allResults = struct();


	for param1_newVal = param1_L:(dt):param1_H
		for param2_newVal = param2_L:(dt):param2_H


			%% Change params
			parameters_given.(param1) = param1_newVal;
			parameters_given.(param2) = param2_newVal;

			%% Run sim
			integrated_ = custom_RK4_YJM(@syst_odes_wSocCoupling_YJM, tspan, initial_conditions, parameters_given, test_1751to2014, vec_proportions);

			%% Grab the peak temperature difference
			maxT = max(integrated_(:,7));
			fin_xP = integrated_(end,1);
			fin_xR = integrated_(end,2);

			if (param1_newVal == param1_L) && (param2_newVal == param2_L) 

				allResults.('maxT') = [maxT];
				allResults.('xP') = fin_xP;
				allResults.('xR') = fin_xR;
				allResults.(param1) = [param1_newVal];
				allResults.(param2) = [param2_newVal];				
			else
				allResults.('maxT') = [allResults.('maxT'), maxT];
				allResults.('xP') = [allResults.('xP'), fin_xP];
				allResults.('xR') = [allResults.('xR'), fin_xR];
				allResults.(param1) = [allResults.(param1), param1_newVal];
				allResults.(param2) = [allResults.(param2), param2_newVal];
			end

		end
	end


	simResults = allResults;

end