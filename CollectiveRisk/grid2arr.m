function finalArr = grid2arr(env)
	GRID = env.GRID;
	sz = size(GRID);
	L = sz(1);
	W = sz(2);
	newArr = [];zeros(L, W);
	for idxY = 1:L
		for idxX = 1:W
			if isa(GRID{idxY, idxX}, "Agent")
				%newArr(idxY, idxX) = 1;
				newArr = [newArr; [idxX, idxY]];
			end
		end
	end
	finalArr = newArr;
end