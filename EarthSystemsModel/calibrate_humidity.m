function hum_ = calibrate_humidity(P_0, lheat, A, S, tao_ch4, tao_co2)
	%{
	We want to choose our humidity parameter such that we can impose an 
	initial temperature that matches the historical record for any 
	sampled parameters. 
	We can solve for this algebraically, this is the result.
	%}

	% 1/0.503 == 1.98807157058
	% tao_ch4 is sampled from a tri dist.
	% tao_co2 is a product of parameters sampled from tri dists
	% T_0 is set to be 288.15K
	% R_gas is UNIVERSAL
	% lheat is constant
	% A is sampled
	% S is sampled
	T_0    = 288.15;
	R_gas  = 8.314;
	sigma_ = 5.67e-8;

	hum_  = (1./P_0) .* exp(lheat./(R_gas .* T_0)) .* ((1./0.0126) .* ((4./3).*(sigma_.*(T_0.^4).* (4 ./ ( (1-A).*S) ) - 1) - tao_ch4 - tao_co2)).^(1.98807157058);
end