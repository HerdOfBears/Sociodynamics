function dC_atdt = C_at_dot_YJM(t, proportions, P, R_veg, R_so, F_oc, epsilon, temp_x0_)
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

	epsilon_R = epsilon .* prop_R0 .* In_R;
	epsilon_P = epsilon .* (1-prop_R0) .* In_P;

	dC_atdt = epsilon_P .* ((1-xP)./(1-xP0)) + epsilon_R .* ((1-xR)./(1-xR0)) - P + R_veg + R_so - F_oc;
end