function finalArr = grid2arr(env)
	GRID = env.GRID;
	sz = size(GRID);
	L = sz(1);
	W = sz(2);

	newArrC = [];%zeros(L, W);
	newArrD = [];%
	for idxY = 1:L
		for idxX = 1:W
			if isa(GRID{idxY, idxX}, "Agent")
				%newArr(idxY, idxX) = 1;
				agent = GRID(idxY, idxX);
				agent = agent{1};
				if agent.isCooperator
					newArrC = [newArrC; [idxX, idxY]];
				else
					newArrD = [newArrD; [idxX, idxY]];
				end
			end
		end
	end
	finalArr.("Cooperators") = newArrC;
	finalArr.("Defectors")   = newArrD;	
end