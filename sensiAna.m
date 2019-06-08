function Results = sensiAna()

	parameters_ = params4SensiAna;


	f_gtm = 8.3259 .* 10^(13); % conversion factor GtC -> C; pg. 1 of Thomas' SI
	
	fldnames = fieldnames(parameters_);
	len_fldnames = length(fldnames);

	% Need to make a way to assign everything to its baseline value initially
	% some parameters have only one possible value.
	indices = struct();
	parameters2give = struct();
	allResults   = struct();
	paramsVaried = struct();


	%initial_conditions = [0.0001e3; 0.2197e3; 0.0606e3; 0.0776e3; 0.0394e3; 0.0010e3];
	global data
	%data = csvread('Documents/prelim/global.1751_2014.csv');
	data = csvread('Sociodynamics/data/co2TotalEmissions.csv');
	data = data(:,[1,2]); % The first two columns are: time, CO2 emissions
	data(:,2) = data(:,2); % Convert from MtC -> GtC


	test_1751to2014  = csvread('Sociodynamics/blineParams_1800to2014.csv');
	initial_conditions  = test_1751to2014(end,2:end)'; %transposed
	t_final = 2200;
	t_final = 2600;

	tspan = 2014:1:t_final;
	y = zeros(numel(tspan),6);

	all_results = struct();

	for i = 1:len_fldnames
		fldname_ = fldnames{i};
		if length(parameters_.(fldname_)) > 1
			indices.(fldname_) = 2;
		end
		if length(parameters_.(fldname_)) ==1
			indices.(fldname_) = 1;
		end
	end

	for i = 1:len_fldnames
		temp_fldname = fldnames(i); % gets the cell arr containing the fieldname
		temp_fldname = temp_fldname{1};
		%temp_fldname = fldnames{1}; % gets the fieldname in string type

		if length(parameters_.(temp_fldname)) > 1
			% Check if there are lower and upper bounds.
			% if the length is  1, then the param doesn't need to be varied.
			paramsVaried.(temp_fldname) = [];


			if temp_fldname == 'H'
				continue
			end

			% Grabs lower bnd, baseline, then upper
			for j = 1:3
				indices.(temp_fldname) = j;


				%%% Initial conditions (non-deviation initials):
				% updates another structure of the parameters we actually want 
				% to give to the model to use to run the simulation.
				for k_idx = 1:len_fldnames
					fldname_ = fldnames{k_idx};
					parameters2give.(fldname_) = parameters_.(fldname_)( indices.(fldname_) );
				end
				paramsVaried.(temp_fldname) = [paramsVaried.(temp_fldname), parameters_.(temp_fldname)( indices.(temp_fldname) )];

				x0 = parameters2give.x0;
				initial_conditions(1) = x0;
				%parameters_baseline = parameters_baseline(2:end);
				
				integrated_ = custom_RK4(@syst_odes_wSocCoupling, tspan, initial_conditions, parameters2give, test_1751to2014, x0);

				maxT = max(integrated_(:,6));
				if j == 1
					allResults.(temp_fldname) = [maxT];
				else
					allResults.(temp_fldname) = [allResults.(temp_fldname), maxT];
				end

			end



			% reset the parameter varied to its baseline value.
			indices.(temp_fldname) = 2;
		end
	end
	Results.maxT = allResults;
	Results.paramsVaried = paramsVaried;

end