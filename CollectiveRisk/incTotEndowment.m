function incTotEndowment(vecAgents, deltaU)
	% gives each agent a small amount. 

	numAgents = length(vecAgents);
	for i = 1:numAgents
		agent_ = vecAgents{i};
		agent_.TotalEndowment = agent_.TotalEndowment + deltaU;
	end
end