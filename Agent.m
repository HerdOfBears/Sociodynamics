classdef Agent < handle
	properties ( Access = private )
		TotalEndowment;
	end

	properties
		% Publically accessible. 
		TotalPayoff = 0;
		isCooperator; 
		Position;

		Kappa;
	end

	methods 

		function initialization(obj, intlEndow, CoopOrDef, X0, Kappa)
			% Used to initialize an agent. 
			%{
			intlEndow = How much to start with.
			CoopOrDef = (0 == defector, 1 == cooperator)
			X0        = initial position on the grid.
			%}

			obj.TotalEndowment = intlEndow;
			if (CoopOrDef > 1) | (CoopOrDef < 0)
				disp('Must be zero or one');
				return
			end
			obj.isCooperator = CoopOrDef;
			obj.Position     = X0; 
			obj.Kappa        = Kappa;
		end
		
		function showProp(obj)
			% To see the private properties
			disp(['TotalEndowment = ', num2str(obj.TotalEndowment)]);
			disp(['isCooperator   = ', num2str(obj.isCooperator  )]);
			disp(['TotalPayoff    = ', num2str(obj.TotalPayoff   )]);			
		end

		function given = make_action(obj, giveAmount)
			% amount the agent gives during a round of the collective-risk game. 
			if obj.isCooperator 

				% If the amount to give is larger than the amount the agent has, give the amount the agent has.
				if giveAmount > obj.TotalEndowment
					given = obj.TotalEndowment;
				end

				if giveAmount <= obj.TotalEndowment
					given = giveAmount;
				end
			end

			% Defectors don't contribute anything in this model. 
			if ~obj.isCooperator
				given = 0;
			end

			% temporary update of TotEndow; this update assumes the group wins
			% a second update comes after checking if the group won. 
			obj.TotalEndowment = obj.TotalEndowment - given;
		end

		function changeStrategy(obj, other)
			% Other = object type. Another Agent.
			% We want to check the other agent's payoff, to see if we should
			% consider changing strategies. 
			P_other = other.TotalPayoff;
			P_self  = obj.TotalPayoff;
			kappa   = obj.Kappa; 
			switchThresh = 1./(1+ exp(-(P_other - P_self)./kappa) );
			temp_ = unifrnd(0,1);
			if temp_<switchThresh
				obj.isCooperator = other.isCooperator;
			end

		function updateEndowment(obj, lostAll)
			% lostAll = (0 == group didn't win and lost all endowment; 1 == group lost but didn't lose endowment by luck)
			if lostAll
				obj.TotalEndowment = 0;
			end
		end

		function updatePayoff(obj)
			% After a game, the agent accumulates Payoff, which is the (sum_i TotEndow) where i = number of games played.  
			obj.TotalPayoff = obj.TotalPayoff + obj.TotalEndowment;
		end

		function updatePosition(obj, newPos)
			obj.Position = newPos; 
		end

	end
end


%{ 

TODO:
	set up lattice
	set up movement function
	set up strategy change function
	set up Moore Neighbourhood
	set up risk calculator
	
	set up main
%}