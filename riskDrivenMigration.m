function resultsStruct = riskDrivenMigration(tspan, MCsteps, intlEndowment, randomNumbers, vecAgents, parameters, initial_positions)

	% Returns a structure of results. Each one has a different fieldname. 

	kappa  = parameters(1); 
	alpha_ = parameters(2);
	c      = parameters(3);
	beta_  = parameters(4);
	Length = parameters(5);
	Width  = parameters(6);
	numAgents = length(vecAgents);
	%%% Populate vector of agents
	for idx_=1:numAgents
		vecAgents{idx_} = Agent;
	end

	%%% Initialize each of the agents:
	for idx_=1:numAgents
		agent     = vecAgents{idx_};
		CoopOrDef = randomNumbers(idx_);
		X0_ = initial_positions(idx_, :);
		agent.initialization( idx_, intlEndowment, CoopOrDef, X0_, kappa);
	end

	%%% Initialize environment
	env = Environment;
	env.initialize(Length, Width);			% make GRID
	env.populateGRID(vecAgents);	% put agents on GRID


	vecCoops   = [];
	timeSeries = struct();
	timeSeries.Defectors   = {};
	timeSeries.Cooperators = {};	
	countSlides = 1;

	%%%%%%%%%%%%%%%%%%%%%
	%%%%% MAIN
	%%%%%%%%%%%%%%%%%%%%%
	for t = tspan
		rnd_order = randperm(numAgents);
		for MCstep = 1:numAgents
			%agent_x = sampleAgents(vecAgents)
			
			% gets a random agent
			rNum    = rnd_order(MCstep);%randi([1,length(vecAgents)]);
			agent_x = vecAgents(rNum);
			agent_x = agent_x{1};
			%disp(agent_x.name)
			
			% Get their Moore Neighbourhood		
			neighbourhood_x = getMooreN(agent_x, Length, Width);

			% Check what is in the Moore Neighbourhood
			neighbourhood = env.checkMooreN(neighbourhood_x); % array of agents
			players_  = neighbourhood.agents;
			freeSpots = neighbourhood.freeSpots;

			szFreeSpots = size(freeSpots);
			numSpots    = szFreeSpots(1);
			numPlayers  = length(players_); 
			num_c = 0;
			if numPlayers <= 1
				% Mandatory movement and don't play game
				r_spot = randi([1,numSpots]);
				newPos = freeSpots(r_spot,:);
				oldPos = [agent_x.Position.y,agent_x.Position.x];

				agent_x.updatePosition(newPos);
				env.updateGRID(agent_x, oldPos, newPos);
				continue
			end
			if numPlayers > 1
				% if there are peeps. other than self, play game. 
				gameResult = playCollectiveRiskGame(players_, alpha_, c, beta_);
				
				% Updates endowment and tot. payoff.
				for agent_idx = 1:numPlayers
					player_i = players_{agent_idx};
					%player_i.updateEndowment(gameResult);
					agent_x.updateEndowment(gameResult);
					if player_i.isCooperator
						num_c = num_c + 1;
					end
				end
			end

			%%% MOVEMENT
			if numSpots == 0
				% Don't move if there are no available positions.
			end

			if numSpots > 0
				T = numPlayers*alpha_;
				if num_c < T
					risk_ = ( (T-num_c)./T )^beta_;
				end
				if num_c >=T
					risk_ = 0;
				end
				% Move with some probability that is dependent on the riskiness of the 
				% current position.
				prob_ = unifrnd(0,1);
				probMove = risk_/numPlayers; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CHECK THIS.
				if prob_ < probMove
					% Move to new spot
					r_spot = randi([1,numSpots]);
					%disp('here')
					%disp(freeSpots)
					%disp(r_spot)
					newPos = freeSpots(r_spot,:);

					%disp(newPos)
					oldPos = [agent_x.Position.y,agent_x.Position.x];
					%disp(oldPos)
					agent_x.updatePosition(newPos);
					env.updateGRID(agent_x, oldPos, newPos);
				end
			end

			%%% Strategy might change
			% Use players from previous group. 
			%disp('numPlayers');
			%disp(numPlayers);
			r_num = randi([1,numPlayers]);
			persuader = players_{r_num};
			agent_x.changeStrategy(persuader);
		end
		n_c = countCooperators(vecAgents);
		vecCoops = [vecCoops, n_c];
		
		if rem(t,10) == 0
			grid_arr = grid2arr(env);
			overlayD = grid_arr.Defectors;
			overlayC = grid_arr.Cooperators;
			timeSeries.Defectors{countSlides}   = overlayD;
			timeSeries.Cooperators{countSlides} = overlayC;		

			totU = getTotEndow(vecAgents);
			timeSeries.U{countSlides} = totU;

			%incTotEndowment(vecAgents, 1);

			countSlides = countSlides + 1;
		end
		%disp(strcat('num. of cooperators = ',num2str(n_c)) )
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	vCoops = vecCoops;

	resultsStruct.('vecCoops')    = vecCoops;
	resultsStruct.('environment') = env;
	resultsStruct.('Agents')      = vecAgents; 
	resultsStruct.('TimeSeries')  = timeSeries;

end

%{

Couple of ideas:

Combine RL with agent-based modelling of the collective-risk social dilemma, similar to Joel Z. Leibo of DeepMind's papers; he has one doing this but for the collective pool social dilemma, not for collective-risk
Right now, agent's play the collective-risk game with 1 ROUND. But in "The collective-risk social dilemma and the preventionof simulated dangerous climate change", the same group plays 10 rounds. 

%}