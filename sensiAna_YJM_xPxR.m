function Results = sensiAna_YJM_xPxR(percentage_, vary_prop_)

	if nargin<1
		vary_prop_= 0;
		parameters_ = params4SensiAna_YJM;
	else
		if nargin < 2
			vary_prop_ =0;
			parameters_ = params4SensiAna_YJM_perc(percentage_);
		else
			parameters_ = params4SensiAna_YJM_perc(percentage_, vary_prop_); 
		end
	end




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


	test_1751to2014  = csvread('Sociodynamics/data/blineParams_1800to2014.csv');
	initial_conditions  = test_1751to2014(end,2:end)'; %transposed
	t_final = 2100;
	% t_final = 2614;

	tspan = 2014:0.1:t_final;
	y = zeros(numel(tspan),7);

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
		temp_fldname = temp_fldname{1}; % gets the str fieldname
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

				tao_co2 = 1.73.*(mixingCO2a(0, parameters2give.C_at0, parameters2give.f_gtm, parameters2give.k_a)).^0.263;
				parameters2give.H = calibrate_humidity(parameters2give.P_0, parameters2give.latent_heat, parameters2give.A, parameters2give.S, parameters2give.tao_CH4, tao_co2);

				if vary_prop_
					% Since we're using parameters2give here, we won't end up with row vector.
					parameters2give.xP0 = 0.05*(1-parameters2give.prop_R0);
					parameters2give.xR0 = 0.05*parameters2give.prop_R0;					
				end
				if ~vary_prop_
					parameters2give.xP0   = parameters2give.x0_ .* (1 - parameters2give.prop_R0);
					parameters2give.xR0   = parameters2give.x0_ .* parameters2give.prop_R0;			
				end					

				xP0 = parameters2give.xP0;
				xR0 = parameters2give.xR0;
				vec_proportions = [xP0, xR0];		
				% initial_conditions(1) = 0.05;%x0;
				%parameters_baseline = parameters_baseline(2:end);

				if length(initial_conditions) == 6
					initial_conditions = [xP0; xR0; initial_conditions(2:end, 1)];
				else
					initial_conditions = [xP0; xR0; initial_conditions(3:end, 1)];
				end

				%% Run sim
				integrated_ = custom_RK4_YJM(@syst_odes_wSocCoupling_YJM, tspan, initial_conditions, parameters2give, test_1751to2014, vec_proportions);				
				% integrated_ = custom_RK4(@syst_odes_wSocCoupling, tspan, initial_conditions, parameters2give, test_1751to2014, x0);


                xP = integrated_(:,1);
                xR = integrated_(:,2);
				avg_ = (xP+xR);
				xP_ = xP./(1-parameters2give.prop_R0);
				xR_ = xR./(parameters2give.prop_R0);
				% avg_= (xP_+xR_)./2;
				avg_ = abs(xR + xP);
				maxMitigate = max(avg_);
				avg_size = size(avg_);
				length_ = max(avg_size);
				% maxMitigate = avg_(length_);

				if j == 1
					allResults.(temp_fldname) = [maxMitigate];
				else
					allResults.(temp_fldname) = [allResults.(temp_fldname), maxMitigate];
				end

			end



			% reset the parameter varied to its baseline value.
			indices.(temp_fldname) = 2;
		end
	end
	Results.maxSocial    = allResults;
	Results.paramsVaried = paramsVaried;

end