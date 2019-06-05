function total = getTotEndow(vecAgents)
	% Function to sum over all the agents to compute the
	% total endowment in the system.

	numAgents = length(vecAgents);
	total_ = 0;

	for i=1:numAgents
		agent_ = vecAgents{i};
		temp_  = agent_.TotalEndowment;
		total_ = total_ + temp_;
	end

	total = total_;
end