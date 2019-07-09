function fitnesses = compute_payoffs()
	%{
	Need to compute the payoffs for the strategies for each subpop.
	%}

	In_R = 
	In_P = 

	dissatisfaction_measure = ( prop_R0 - xR ).*(In_R - In_P);

	alpha_P = alpha_P0 + alpha_P1 .* ( 1 - k.*exp(dissatisfaction_measure) );
	alpha_R = alpha_R0

	pay_P_M = -alpha_P + cost_climate() + delta.*xP;
	pay_P_N = cost_climate() + delta .* ( (1-prop_R0)-xP );
	pay_R_M = -alpha_R + cost_climate() + delta.*xR;
	pay_P_N = cost_climate() + delta .* ( prop_R0 - xR );


end