function fitnesses = compute_payoffs(proportions, parameters_, T, T_f, In_P, In_R)
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
	
	k_R = parameters_.k_R;
	c_R = parameters_.c_R;
	k_P = parameters_.k_P;
	c_P = parameters_.c_P;


	% Baseline per-capita income for rich and poor
	omega_R = parameters_.omega_R;
	omega_P = parameters_.omega_P;

	xP = proportions(1);
	xR = proportions(2);

	%%% Functions
	% % Once temperature (T) deviates above some critical deviation (say, +1.5 Celsius)
	% % then it starts impacting the income-per-capita
	% T_0 = 1.5;
	% In_R = omega_R - k_R .* exp(c_R .* (T - T_0));
	% In_P = omega_P - k_P .* exp(c_P .* (T - T_0));

	dissatisfaction_measure = ( prop_R0 - xR ).*(In_R - In_P);

	alpha_P = alpha_P0 + alpha_P1 .* ( 1 - exp(dissatisfaction_measure) );
	alpha_R = alpha_R0;

	cost_climate_ = cost_climate(T_f, f_max, omega, T_c);

	pay_P_M = (-1).*alpha_P + cost_climate_ + delta.*xP;
	pay_P_N = cost_climate_ + delta .* ( (1-prop_R0)-xP );
	pay_R_M = (-1).*alpha_R + cost_climate_ + delta.*xR;
	pay_R_N = cost_climate_ + delta .* ( prop_R0 - xR );

	fitnesses = [pay_P_M, pay_P_N; pay_R_M, pay_R_N];
end