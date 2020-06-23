function fitnesses = compute_payoffs(time_,proportions, parameters_, T, T_f, In_P, In_R)
	%{
	Need to compute the payoffs for the strategies for each subpop.

	T   : is the 'actual' temperature deviation
	T_f : is the 'forecasted' temperature deviation by the individuals of each subpop.  
	%}

	%%% Parameters
	f_max = parameters_.f_max;
	omega = parameters_.omega;
	T_c   = parameters_.T_c;

	alpha_P0 = parameters_.alpha_P0;
	alpha_P1 = parameters_.alpha_P1;
	alpha_R0 = parameters_.alpha_R0;
	delta    = parameters_.delta;
	prop_R0  = parameters_.prop_R0;
	homophily = parameters_.homophily;
	
	k_R = parameters_.k_R;
	c_R = parameters_.c_R;
	k_P = parameters_.k_P;
	c_P = parameters_.c_P;

	Omega =	parameters_.Omega;
	Td_c = parameters_.Td_c;
	% Baseline per-capita income for rich and poor
	omega_R = parameters_.omega_R;
	omega_P = parameters_.omega_P;

	xP = proportions(1);
	xP0 = parameters_.xP0;

	xR = proportions(2);
	xR0 = parameters_.xR0;
	%%% Functions
	% % Once temperature (T) deviates above some critical deviation (say, +1.5 Celsius)
	% % then it starts impacting the income-per-capita
	T_0 = 1.5;
	% In_R = omega_R - k_R.* max(0,T - T_0);%.* exp(c_R .* (T - T_0));
	% In_P = omega_P - k_P.* max(0,T - T_0);%.* exp(c_P .* (T - T_0));

	% In_R = max(0, omega_R - c_R.* 1./(exp(-k_R.*(T-T_0)) + 1) );%.* exp(c_R .* (T - T_0));
	% In_P = max(0, omega_P - c_P.* 1./(exp(-k_P.*(T-T_0)) + 1) );%.* exp(c_P .* (T - T_0));

	% dissatisfaction_measure = ( (prop_R0 - xR)./prop_R0 ).*( (In_R - In_P)./(omega_R - omega_P) ); % currently only affects the resource-poor subpop.
	dissatisfaction_measure = ( (prop_R0 - xR)./prop_R0 ).*( (In_R./In_P).*(omega_P./omega_R) ); % currently only affects the resource-poor subpop.	
	% disp(dissatisfaction_measure)
	% parameters_.homophily = (1./(1 + exp(-8.*(dissatisfaction_measure - 0.85) )) ); 
	% dissatisfaction_measure = ( prop_R0 - xR ).*(In_R - In_P); % currently only affects the resource-poor subpop. 
	% alpha_P1 = 1.0;

	alpha_P = alpha_P0 + alpha_P1 .* (1.0./( 1 + exp(-Omega.*(dissatisfaction_measure - Td_c)) ) );
	alpha_R = alpha_R0;

	cost_climate_ = 0.5.*cost_climate(T_f, f_max, omega, T_c);

	pay_P_M = (-1).*alpha_P + cost_climate_ + delta.*((xP) + (1-homophily).*xR);
	pay_P_N = -cost_climate_ + delta .* (  (1-homophily).*(prop_R0-xR) - ((1-prop_R0) - xP)  );%( (1-prop_R0)-xP );
	pay_R_M = (-1).*alpha_R + cost_climate_ + delta.*((1-homophily).*xP + xR);
	pay_R_N = -cost_climate_ + delta .* (  (prop_R0-xR) - (1-homophily).*((1-prop_R0) - xP)  );%( prop_R0 - xR );


	% %% HERE WE ARE TRYING TO NORMALIZE THE NORMS:
	% pay_P_M = (-1).*alpha_P + cost_climate_ + delta.*((xP) + (1-homophily).*xR).*(1./( 1-homophily.*prop_R0));
	% pay_P_N = -cost_climate_ + delta .* (  (1-homophily).*(prop_R0-xR) - ((1-prop_R0) - xP)  ).*(1./( 1-homophily.*prop_R0));%( (1-prop_R0)-xP );
	% pay_R_M = (-1).*alpha_R + cost_climate_ + delta.*((1-homophily).*xP + xR).*(1./(1 - homophily + homophily.*prop_R0) );
	% pay_R_N = -cost_climate_ + delta .* (  (prop_R0-xR) - (1-homophily).*((1-prop_R0) - xP)  ).*(1./(1 - homophily + homophily.*prop_R0) );%( prop_R0 - xR );	

	fitnesses = [pay_P_M, pay_P_N; pay_R_M, pay_R_N];
	% disp(fitnesses)	
end