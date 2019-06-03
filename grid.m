%{
Grid object for agent-based model of collective-risk social dilemma.	
%}

classdef Environment < handle
	properties
		Length;
		Width;
		GRID;
		OccupiedPositions   = py.list();
		UnoccupiedPositions = py.list();

	end

	methods

		function initialize(obj, Length, Width)
			obj.Length = Length;
			obj.Width  = Width;
			GRID = zeros(Length, Width);
		end

		function updateGRID(obj, vecAgents)
			numAgents = length(vecAgents);
			for idx = 1:1:numAgents
				agent = vecAgents(idx); % grab an agent
				agent_xpos = agent.Position(1);
				agent_ypos = agent.Position(2);
				obj.GRID(agent_ypos, agent_xpos) = idx; % this will make it easy to determine which agent is at which position. the idx in vecAgents is like the name of the agent.  
			end


	end
end