function income_cost = income_cost_exp(T, parameters_, population_)

	initial_income = parameters_.(strcat("omega_",population_));
	c_i = parameters_.(strcat("c_",population_));
	k_i = parameters_.(strcat("k_",population_));

	income_cost = initial_income - exp((1/k_i)*T);
end