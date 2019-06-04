%{
Grid object for agent-based model of collective-risk social dilemma.	
%}

classdef Environment < handle
	properties
		Length;
		Width;
		GRID;	% Cell array to contain agents. 
		OccupiedPositions   = struct(); % field = agent name; value = position as row vector [ypos, xpos] 
		Positions2Agent     = struct(); % field = xNUMyNUM; value = Agent at that spot. 
		UnoccupiedPositions;

	end

	methods

		function xyVals = getStructValues(obj, structName)
			% this will get all of the values of a given struct 
			% Kind of assumes I am giving it the OccupiedPositions struct

			fields   = fieldnames(structName); % get the field names
			temp_res = []; % 2D array of x,y values; [yvalues, xvalues] 
			for i = 1:length(structName)
				temp_ = getfield(structName, fields{i}); % gets the value(s) of field_i
				temp_res = [temp_res; temp_];
			end
			xyVals = temp_res; % return the xy values; [yvals, xvals]
		end

		function initialize(obj, Length, Width)
			obj.Length = Length;
			obj.Width  = Width;
			obj.GRID = cell(Length, Width);
			
			for idx_y = 1:Length
				for idx_x = 1:Width
					obj.GRID{idx_y, idx_x} = 0;
				end
			end
		end

		function populateGRID(obj, vecAgents)
			% Puts the agents on the environment and keeps track of occupied positions.

			numAgents = length(vecAgents);
			for idx = 1:1:numAgents
				agent = vecAgents{idx}; % grab an agent
				aName = agent.name;
				agent_xpos = agent.Position.x;
				agent_ypos = agent.Position.y;
				obj.OccupiedPositions.(aName) = [agent_ypos, agent_xpos];

				%temp_fld_name = "x" + num2str(agent_xpos) + "y" + num2str(agent_xpos);		% makes x,y position the field name. 'x5y10' e.g.
				%obj.Positions2Agent.(temp_fld_name) = aName; % this will make it easy to determine which agent is at which position. the idx in vecAgents is like the name of the agent.  
				obj.GRID{agent_ypos, agent_xpos} = agent; % put agent on grid
			end
		end

		function updateGRID(obj, agent, oldPos, newPos)
			% Moves the agent on the grid
			% Makes the old position an available pos. 
			% Updates "occupied positions" as well

			oldX = oldPos(2);
			oldY = oldPos(1);
			newX = newPos(2);
			newY = newPos(1);

			% First check if the new position is empty. 
			% A zero means the position is available.
			if obj.GRID{newY, newX} ~= 0
				disp(agent.name)
				disp("Tried to move to occupied spot");
				disp(obj.GRID{newY, newX});
				disp(newY)
				disp(newX)
				return
			end
			if obj.GRID{newY, newX} == 0
				obj.GRID{newY, newX} = agent;
				obj.GRID{oldY, oldX} = 0;
				obj.OccupiedPositions.(agent.name) = [newY, newX];
			end
		end

		function resAgents = checkMooreN(obj, MooreN)
			% Given an agent's Moore Neighbourhood, return the agents in that neighbourhood.
			% MooreN = 3x3 cell array. We want to ignore the center element. 
			arrAgents = [];
			freeSpots = [];
			for idxY = 1:3
				for idxX = 1:3
					if (idxY == 2) && (idxX == 2)
						% ignore center of Moore Neighbourhood
						%continue
					end

					temp_yPos = MooreN{idxY, idxX}(1);
					temp_xPos = MooreN{idxY, idxX}(2);

					if isa(obj.GRID{temp_yPos, temp_xPos}, 'Agent')
						arrAgents = [arrAgents, obj.GRID{temp_yPos, temp_xPos}];
					else
						if (idxY ==2) && (idxX ==2)
						else
							freeSpots = [freeSpots; [temp_yPos, temp_xPos]];
						end
					end

				end
			end 
			
			resStruct = {};
			resStruct.freeSpots = freeSpots;
			resStruct.agents    = num2cell(arrAgents);
			resAgents = resStruct;%num2cell(arrAgents);
		end

	end
end