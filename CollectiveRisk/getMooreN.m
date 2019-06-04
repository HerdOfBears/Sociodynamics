function cellMoore = getMooreN(agent, Length, Width)
	% makes a cell array of the Moore Neighbourhood of an agent.
	% d1 --> down 1
	% u1 --> up 1
	% r1 --> right 1
	% l1 --> left 1

	temp_cell = cell(3);
	agent_xpos = agent.Position.x;
	agent_ypos = agent.Position.y; 

	u1 = agent_ypos - 1;
	u2 = agent_ypos - 2;
	d1 = agent_ypos + 1;
	d2 = agent_ypos + 2;

	r1 = agent_xpos + 1;
	r2 = agent_xpos + 2;
	l1 = agent_xpos - 1;
	l2 = agent_xpos - 2;

	%%% Periodic Boundary Conditions
	% Top
	if agent_ypos == 2
		u1 = 1;
		u2 = Length;
	end
	if agent_ypos == 1
		u1 = Length;
		u2 = Length-1;
	end
	% Bottom
	if agent_ypos == (Length-1)
		d1 = Length;
		d2 = 1;
	end
	if agent_ypos == (Length)
		d1 = 1;
		d2 = 2;
	end
	% Far left
	if agent_xpos == 2
		l1 = 1;
		l2 = Width;
	end
	if agent_xpos == 1
		l1 = Width;
		l2 = Width-1;
	end
	% Far right
	if agent_xpos == (Width-1)
		r1 = Width;
		r2 = 1;
	end
	if agent_xpos == (Width)
		r1 = 1;
		r2 = 2;
	end


	temp_cell{1,1} = [u1, l1];
	temp_cell{1,2} = [u1, agent_xpos];
	temp_cell{1,3} = [u1, r1];

	temp_cell{2,1} = [agent_ypos, l1];
	temp_cell{2,2} = [agent_ypos, agent_xpos];
	temp_cell{2,3} = [agent_ypos, r1];

	temp_cell{3,1} = [d1, l1];
	temp_cell{3,2} = [d1, agent_xpos];
	temp_cell{3,3} = [d1, r1];

	cellMoore = temp_cell;
end