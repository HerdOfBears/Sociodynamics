function dPdt = replicator_equation(proportions, meeting_rates, fitnesses, homophily, kappa_)
	%{
	
	proportions : array of values for the current 
			proportion of the total population that each subpop.
			constitutes.
			Each column is a strategy. Each row is a subpop.

	meeting_rates : array of constants denoting the rate a given subpop.
			meets some other subpop.
	
	fitnesses : array of fitnesses of each strategy in a subpop. 
				rows are subpops. First poor, then rich. 
				cols are strats.  First mitigative, then non-mitigative. 
	
	homophily : array of homophily parameters, determining how willing
			each subpop. is to listen to other subpops.
	%}

	if nargin<5
		kappa_ = 1.0;
	end

	[num_subpops, num_strats] = size(proportions);
	tot_change = [];
	h = homophily;
	
	for i= 1:1:num_subpops

		% Grab subpop. to update
		x = proportions(i,1); % ASSUME TWO STRATEGIES
		
		% Update from same subpopulation
		for j = 1:1:num_strats
			if j ~= 1
				nu_ij = meeting_rates(i);
				y = proportions(i,j); 
				fitness_i1 = fitnesses(i,1);
				fitness_ij = fitnesses(i,j);

				if i == 20 % never reaches 20
					disp("nu_ij = " + num2str(nu_ij))
					disp("y = " + num2str(y))
					disp("fitness_i1 = " + num2str(fitness_i1))
					disp("fitness_ij = " + num2str(fitness_ij))
				end

				% tot_change(i) = nu_ij.*x.*y.*(fitness_i1 - fitness_ij);
				tot_change(i) = x.*y.*(fitness_i1 - fitness_ij);				
			end
		end
		% disp("subpop = " + num2str(i))
		% disp("dPdt = " + num2str(tot_change(i)))		
		
		% Update from other subpops.
		temp_subpop_contr = 0;
		for b = 1:1:num_subpops

			% Ensure we don't redo the above loop
			if b ~= i
				for j = 1:1:num_strats
					nu_ib = meeting_rates(b);
					P_b1 = proportions(b, 1); 
					P_aj = proportions(i, j);
					P_bj = proportions(b, j);
					P_a1 = proportions(i, 1);
					
					fitness_b1 = fitnesses(b, 1);
					fitness_aj = fitnesses(i, j);
					fitness_bj = fitnesses(b, j);
					fitness_a1 = fitnesses(i, 1); 
					
					gain_ = P_b1 .* P_aj .* max( [fitness_b1 - fitness_aj, 0] );
					loss_ = P_bj .* P_a1 .* max( [fitness_bj - fitness_a1, 0] );
					
					% temp_subpop_contr = temp_subpop_contr + nu_ib.*(gain_ - loss_);
					temp_subpop_contr = temp_subpop_contr + (gain_ - loss_);					
				end
			end
		end
		
		% Include the contribution to dPdt from other subpopulations.
		% When homophily is 1, there will be no contribution from other
		% subpopulations
		tot_change(i) = tot_change(i) + (1-h).*temp_subpop_contr;
	end
	% End of updating subpop i
	
	if num_strats == 2
		
	end

	% disp("nu = " + num2str(meeting_rates))
	% disp("proportions  = " + num2str(proportions))
	% disp(tot_change)
	dPdt = kappa_ .* tot_change;

	
end