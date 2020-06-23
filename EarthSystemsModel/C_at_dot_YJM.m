function dC_atdt = C_at_dot_YJM(t, proportions, P, R_veg, R_so, F_oc, epsilon, temp_x0_, prop_R0, In_P, In_R, In_P0, In_R0)
	% Time rate of change for C_at
	%{
	Variables:
		t       = time
		xP      = number 'poor' of mitigators
		xR      = number 'rich' of mitigators
		P       = carbon uptake from photosynthesis
		R_veg   = Resp. from vegetation
		R_so    = Resp. from soil
		F_oc    = Flux of CO2 from atmos. to ocean
		epsilon = baseline CO2 emissions
	%}

	xP = proportions(1,1);
	xR = proportions(2,1);

	xP0 = temp_x0_(1);
	xR0 = temp_x0_(2);
	normalizer_ = ( ((1-prop_R0)-xP0).*In_P0 + (prop_R0-xR0).*In_R0 );

	% epsilon_R = epsilon .* ((     prop_R0  - xR )./normalizer_ ) .* (In_R./(In_R0 + In_P0));
	% epsilon_P = epsilon .* (( (1- prop_R0) - xP )./normalizer_ ) .* (In_P./(In_P0 + In_R0));

	% INTERESTING RESULTS
	% epsilon_R = epsilon .* ((     prop_R0  - xR )./(prop_R0-xR0) ) .* (In_R./(In_R0 + In_P0));
	% epsilon_P = epsilon .* (( (1- prop_R0) - xP )./((1-prop_R0)-xP0) ) .* (In_P./(In_P0 + In_R0));

	%% NORMALIZATION 3
	% epsilon_R = epsilon .* ((     prop_R0  - xR )./(prop_R0-xR0) ) .* (In_R./(In_R0));
	% epsilon_P = epsilon .* (( (1- prop_R0) - xP )./((1-prop_R0)-xP0) ) .* (In_P./(In_P0));

	% NEW NORMALIZATION as per Tom's suggestion
	epsilon_R = epsilon .* (     prop_R0  - xR ).*(In_R);
	epsilon_P = epsilon .* ( (1- prop_R0) - xP ).*(In_P);		

	%% GOES WITH NORMALIZATION 3
	% dC_atdt = (0.5).*(epsilon_P + epsilon_R) - P + R_veg + R_so - F_oc;

	dC_atdt = ( (epsilon_P + epsilon_R)./normalizer_ ) - P + R_veg + R_so - F_oc;
end