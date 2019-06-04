function numCoops = countCooperators(vecAgents)
	num_c = 0;
	numAgents = length(vecAgents);
	for idx = 1:1:numAgents
		agent = vecAgents{idx};
		num_c = num_c + agent.isCooperator;
	end
	numCoops = num_c;
end