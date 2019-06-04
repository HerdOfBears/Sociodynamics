function gameResult = playCollectiveRiskGame(agents, alpha_, c, beta_)
	%{
	Implements the collective-risk social dilemma. 
	The threshold for winning is dependent on the number of active players.

	Parameters:
		agents : cell array
		alpha_ : change threshold; 0 <= alpha_ <= 1
		c : contribution amount; c < b == the initial amount
		beta_ : nonlinearity of risk function
	%}

	numPlayers = length(agents);
	T = numPlayers * alpha_; % threshold to win
	giveAmount = c;
	
	num_c = 0; % count number of cooperators
	tot_  = 0;
	for i=1:numPlayers
		agent = agents{i};
		tot_ = tot_ + agent.make_action(giveAmount);
		if agent.isCooperator
			num_c = num_c + 1;
		end
	end


	if tot_ < T
		if num_c < T
			risk_ = ( (T-num_c)./T )^beta_;
		end
		if num_c >=T
			risk_ = 0;
		end
		p_i = unifrnd(0,1);
		if p_i <= risk_
			% Worst case: all players lose all endowment
			gameResult = 0;
		end
		if p_i > risk_
			% players lose but don't lose endowment
			gameResult = 1;
		end
	end
	if tot_>=T
		% players win and get payoff. 
		gameResult = 2;
	end
end