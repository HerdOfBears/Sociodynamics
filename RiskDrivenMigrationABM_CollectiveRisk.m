%{
Implementation of the model from paper:
"Risk-driven migration and the collective-risk social dilemma" by Xiaojia Chen, Attila Szolnoki, and Matjaz Perc
(DOI: 10.1.103/PhysRevE.86.036101)
%}

%{

Collective-risk social dilemma:
All players have an initial endowment.
Goal: reach a collective target using individual investments taken from the initial endowment.
Cooperation == contributing a fraction of it to the collective pool
Defecting   == No contribution
Risk level is determined by the collective target that individual investments must together meet. 
Failure to reach the target results in all members of the group losing the remainder of their endowment.
Successfully reaching the target allows members to retain the remainder of their endowment. 
	
%}

%{
Risk-driven migration. 
This type of mobility assumes that agents are \textit{forced} to migrate by the immediate and possibly unfavourable environment, rather than the agent having an explicit desire to migrate. 
Risk is a function of the difference between the actual contributions and the declared target in each group. 
(A Fick's law-esque assumption is made that agents will move away from high-risk regions.)
Here, migration is the self-organizing principle that depends only on the risk each individual is exposed to. 
%}

%{
The model.
Collective-risk social dilemma on a square lattice.
Lattice is LxL w/ periodic BCs. RATHER THAN USING A BRAVAIS LATTICE, WOULD IT BE INTERESTING TO USE A RANOOM TESSELATION OF SOME SPACE?
Two agent types: Defectors (D) and Cooperators (C).
Each site can be either: free, or occupied by a D or a C. 
Population density, rho = fraction of occupied sites to total number of sites, which is CONSTANT.
Total number of agents == rho*L*L. 
Initial endowment == b -- applied to each agent. 

ASYNCHORONOUS UPDATING. 
randomly selected player x plays the collective-risk social dilemma with its 8 NNs (if present, vacant sites result in differently-numbered games), collecting total payoff P_x. 
Cooperators contribute c<b to the public good game, while defectors contribute ZERO. 	

COLLECTIVE TARGET
Since the number of players in each collective-risk game depends on the number of vacant sites surrounding a randomly selected agent,
the collective target is chosen as T= n * alpha; n == num. active players, alpha == weighting factor determining collective threshold (0 <= alpha <= 1).
If the tot. contributions from a group G_i reaches the target of its game, then the players keep their remainder. 
If ~target_reached: 
	group_members lose remaining endowment with prob. r_i. 
endif


n_c  = number of cooperators in the group. 
beta = tunable param. determing the nonlinearity of the risk.  
if n_c < T:
	r_i = ((T-n_c)/T)^beta
else:
	r_i = 0
endif

AFTER PAYOFF
After getting its payoff, an agent moves to a randomly chosen position in its Moore Neighbourhood (if there exists a free position). 
The probability of moving to a position is determined by: 
r_m = \sum_i r_i/n, quantifying the average risk experienced by its current location. 
If no_spots:
	don't move.
endif

if no_neighbours:
	must move
endif


STRATEGY CHANGE
Agent x adopts the strategy of a randomly selected neighbour y with probability:
f(P_y - P_x) = 1/(1 + exp(-(P_y - P_x)/kappa))

where kappa denotes a "amplitude of noise"
Set kappa = 0.5 


%}

tspan   = 1:1:50;
MCsteps = 1:1:30;

%%% Initial conditions
intlEndowment = 10; % "b" in paper; the initial endowment. If the agents are given small rewards for winning collective-risk games, does that constitute a slowly-driven system?
numAgents = 30;
randomNumbers = int32(randi([0, 1], [1, numAgents])); % randomly select whether an agent is a cooperator or defector
vecAgents = cell(numAgents,1);

kappa  = 0.5; 
alpha_ = 0.8;
c      = 1;
beta_  = 1;
Length = 50;
Width  = 50;
parameters = [kappa, alpha_, c, beta_, Length, Width];
%%% Define initial positions of each agent.
idx_x0 = 20;
idx_y0 = 20;

tot_idx = 0; 
for idx_y = idx_y0:1:(idx_y0 + 4)
	for idx_x = idx_x0:1:(idx_x0 + 5)
		tot_idx = tot_idx + 1;		
		initial_positions(tot_idx, 1) = idx_x;
		initial_positions(tot_idx, 2) = idx_y;
	end
end
disp(tot_idx)


riskDrivenMigration(tspan, MCsteps, intlEndowment, randomNumbers, vecAgents, parameters, initial_positions)
%{
function rAgent = sampleAgents(vecAgents)
	% gets a random agent
	rNum   = randi([0,length(vecAgents)]);
	rAgent = vecAgents(rNum);
end
%}