function yprime = syst_odes_wSocCoupling_YJM(t, x_vec, parameters_, temp_history, xP0, xR0)
	% Yellow Jacket Model

	global data
	temp_pred_ON = 1; % Whether to use temp. pred. for indiv. or not ( ON == 1; OFF == 0)
	
	xP     = x_vec(1);
	xR	   = x_vec(2);
	C_at   = x_vec(3);
	C_oc   = x_vec(4);
	C_veg  = x_vec(5);
	C_so   = x_vec(6);
	T      = x_vec(7);

	%%% Initial conditions (non-deviation initials):
	xP0    = parameters_.xP0;
	xR0    = parameters_.xR0;	
	C_at0  = parameters_.C_at0; %596; 
	C_oc0  = parameters_.C_oc0; %1.5.*10^(5);% % this can't be zero, otherwise we are dividing by zero
	C_veg0 = parameters_.C_veg0; %550;
	C_so0  = parameters_.C_so0; %1500;
	T_0    = parameters_.T_0; %288.15;

	%%% Photosynthesis params.
	k_p  = parameters_.k_p; %0.184;
	k_MM = parameters_.k_MM; %1.478;
	k_c  = parameters_.k_c; %29.* 10^(-6);
	k_M  = parameters_.k_M; %120.* 10^(-6);
	
	k_a = parameters_.k_a; %1.773.*10^(20); % mole vol. of atmos
	
	%%% Plant resp. params:
	k_r = parameters_.k_r; %0.092;
	k_A = parameters_.k_A; %8.7039.*10^(9);
	%E_a = parameters_(13) %54.83;
	E_a = parameters_.E_a; %(54.83).*10^(3); % In Bury's mathematica nb this is whereas in SI it isn't cubed
	
	%%% Soil resp. params:
	k_sr = parameters_.k_sr; %0.034; % soil resp. rate const.
	k_B  = parameters_.k_B; %157.072;
	
	%%%% Turnover params:
	k_t = parameters_.k_t; %0.092;
	
	%%%% Heat cap. of Earth's surface:
	c = parameters_.c; %4.69 .* 10^(23); %
	
	%%%% Constants:
	a_E = parameters_.a_E; %5.101*10^(14); % Earth's surface area
	sigma = parameters_.sigma; %5.67*10^(-8); % Stefan-Boltzmann const. 
	latent_heat = parameters_.latent_heat; %43655; 
	R = parameters_.R; % 8.314; % molar gas const.
	H = parameters_.H; % 0.5915; % relative humidity; calibrated
	A = parameters_.A; % 0.225; % surface albedo
	S = parameters_.S; % 1368; % solar flux
	%disp('S = ')
	%disp(S)
	%disp('A = ')
	%disp(A)
	
	tao_CH4 = parameters_.tao_CH4; % 0.0231; % see: atmos_down_flux to resolve potential probs.
	P_0 = parameters_.P_0; % 1.4 .* 10^(11); % water vapor sat. const.
	F_0 = parameters_.F_0; % 2.5 .* 10^(-2); % ocean flux rate const.
	
	chi  = parameters_.chi; % 0.3; % characteristic CO2 solubility
	zeta = parameters_.zeta; % 50; % "evasion factor"
	
	f_max = parameters_.f_max; % 5; % max of warming cost function f(T)
	omega = parameters_.omega; % 3; % nonlinearity of warming cost function
	T_c = parameters_.T_c; % 2.5; % critical temperature of f(T)
	t_p = parameters_.t_p; % 10; % num. prev. yrs used for temp pred.
	t_f = parameters_.t_f; % 0; % num yrs ahead for temp. proj.
	s_  = parameters_.s_; % 50; % half-sat. time for epsilon(t) from 2014
	eps_max = parameters_.eps_max; % 7; % max change in epsilon(t) from 2014
	
	f_gtm = parameters_.f_gtm; % 8.3259 .* 10^(13); % conversion factor GtC -> C; pg. 1 of Thomas' SI
	
	kappa = parameters_.kappa; % social learning rate
	beta  = parameters_.beta;  % net cost of being a mitigator
	delta = parameters_.delta;  % strength of social norms

	
	%%%%%%%%%%%%%%%%
	%%% Functions
	%%%%%%%%%%%%%%%%
	
	
	%%%% Compute intermediates (resp. and photosynthesis etc.)
	
	pCO2a = mixingCO2a(C_at, C_at0, f_gtm, k_a);
	
	P     = photosynthesis(C_at, T, pCO2a, k_p, C_veg0, k_a, k_MM, k_c, k_M, T_0);
	R_veg = plant_respiration(C_veg, T, k_r, k_A, E_a, T_0, C_veg0);
	R_so  = soil_respiration(T, C_so, k_sr, k_B, T_0, C_so0);
	L_    = turnover(C_veg, k_t, C_veg0);
	F_oc  = ocean_flux(C_at, C_oc, F_0, chi, zeta, C_at0, C_oc0);
	F_d   = atmos_down_flux(pCO2a, A, S, P_0, latent_heat, T, tao_CH4, T_0, H);

	epsilon_T = baseline_CO2_emis(t, eps_max, s_, data);
	
	%%%%%%%%%%%%%%%%
	%%%%% ODEs
	%%%%%%%%%%%%%%%%
	
	%%%% Socio-dynamics model
	%y1 = 0;
	temp_x0_ = 0;
	%%% Create proportions array
	prop_R0 = parameters_.prop_R0;
	proportions(1,1) = xP0;
	proportions(1,2) = (1-prop_R0)-xP0;
	proportions(2,1) = xR0;
	proportions(2,2) = prop_R0-xR0;

	if (temp_pred_ON == 1) && (t>=2014)
		% use temperature solution at previous times to obtain a linear
		% prediction for a time horizon later
		
		%{
		if (t - floor(t) < 0.5)
			temp_time = floor(t);
		end
		if (ceil(t) - t < 0.5)
			temp_time = ceil(t);
		end		
		disp(t)
		temp_time = temp_time - 1751;
		%}
		
		meeting_rates(1) = 1-prop_R0;
		meeting_rates(2) = prop_R0;

		homophily = parameters_.homophily;

		%T_prev = interp1(temp_history(:,1), temp_history(:,2), t-t_p);
		%T_prev = temp_history(temp_time-t_p);
		T_prev = temp_history;
		T_f   = T + (t_f./t_p).*(T - T_prev); % Each subpop. 'forecasts' temperature in the same linear way.
		% f_T_f = cost_climate(T_f, f_max, omega, T_c);

		% Get the payoffs for each subpop. and strategy.
		fitnesses = compute_payoffs(proportions, parameters_, T, T_f);

		temp_x0_ = [xP0, xR0];
		dPdt = replicator_equation(proportions, meeting_rates, fitnesses, homophily);
		y1 = dPdt(1); % poor
		y2 = dPdt(2); % rich 
	end
	if (temp_pred_ON == 0) && (t>2014)
		% Just use the current temperature value, not the future projection T_f
		% Get the payoffs for each subpop. and strategy.
		fitnesses = compute_payoffs(proportions, parameters_, T, T);

		temp_x0_ = [xP0, xR0];
		dPdt = replicator_equation(proportions, meeting_rates, fitnesses, homophily);
		y1 = dPdt(1); % poor
		y2 = dPdt(2); % rich 
	end
	if (t<2014)
		y1 =0;
		y2 =0;
	end
	%%% Carbon uptake/transport DEs
	y3 = C_at_dot_YJM(t, proportions, P, R_veg, R_so, F_oc, epsilon_T, temp_x0_);  % Atmospheric
	y4 = C_oc_dot(t, F_oc);  % Ocean
	y5 = C_veg_dot(t, P, R_veg, L_); % Vegetation
	y6 = C_so_dot(t, R_so, L_);  % Soil
	
	
	%%% Temperature change
	y7 = c_T_dot(t, F_d, T, c, T_0);

	%%% RESULT
	yprime = [y1; y2; y3; y4; y5; y6; y7];
end