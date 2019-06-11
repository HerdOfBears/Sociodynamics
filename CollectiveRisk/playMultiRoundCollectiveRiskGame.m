function gameResult = playMultiRoundCollectiveRiskGame(agents, alpha_, c, beta_, numRounds)
	%{
	Implements the collective-risk social dilemma. 
	The threshold for winning is dependent on the number of active players.

	Parameters:
		agents : cell array
		alpha_ : change threshold; 0 <= alpha_ <= 1
		c : contribution amount; c < b == the initial amount
		beta_ : nonlinearity of risk function
		numRounds : number of rounds to before the game 'ends'
	%}

	numPlayers = length(agents);
	T = numPlayers * alpha_; % threshold to win
	giveAmount = c;
	
	num_c = 0; % count number of cooperators
	
	tot_  = 0;
	numRounds = 10;

	for round_ = 1:1:numRounds
		for i=1:numPlayers
			agent = agents{i};
			Prisk = round_./numRounds; % Prisk is linearly increasing. 
			giveAmount = agent.decideGiveAmount(Prisk);
			tot_ = tot_ + agent.make_action(giveAmount);
			if agent.isCooperator
				num_c = num_c + 1;
			end
		end


		% Check if the players won early
		if tot_>=T
			% players win and get payoff. 
			gameResult = 2;
			return
		end
	end
	% played numRounds rounds. 

	% If the script reaches here, then the players lost. 
	% Now check if the players lose everything or not.. 
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
			return
		end
		if p_i > risk_
			% players lose but don't lose endowment
			gameResult = 1;
			return
		end
	end
end

%{
might have to separete into two functions, one for playing a round and one to check 
whether the players win or lose or neither. It might be easier to do things to the agents
like update their perceived risk or not. 

Also, tropical geometry? Continous version of SOC for Chris and Madhur's models. 
	
%}