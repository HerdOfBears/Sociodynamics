function finResults = paramPlanesLoop()
	clear all
	addpath('./Sociodynamics/EarthSystemsModel');
	addpath('./Sociodynamics/SocialDynamicsModel');
	addpath('./Sociodynamics/data');



	sim_num = 1;
	for t_proj = [10, 25, 50]
		for delta_ = [0.5, 1.0, 1.5]
			disp(strcat('Sim = ', num2str(sim_num)));
			disp(strcat("t_proj = ", num2str(t_proj), "; delta = ", num2str(delta_)) );
			%% Vary omega
			simResults1 = buildParamPlane('omega_R', 1.5, 7, 'omega_P', 1.0, 6.5, 0.1, t_proj, delta_, 0);
			field_name = strcat('sim_num_', num2str(sim_num),'_omega')

			finResults.(field_name) = simResults1;

			%% Vary k_r k_P
			paramRVary = 'k_R'
			paramPVary = 'k_P'

			simResults2 = buildParamPlane(paramRVary, 0.1, 5, paramPVary, 0.1, 5, 0.1, t_proj, delta_, 0);
			field_name = strcat('sim_num_', num2str(sim_num), '_ki')

			finResults.(field_name) = simResults2;

			%% Vary c_P and c_R
			paramRVary = 'c_R'
			paramPVary = 'c_P'

			simResults3 = buildParamPlane(paramRVary, 0.1, 7, paramPVary, 0.1, 7, 0.1, t_proj, delta_, 0);
			field_name = strcat('sim_num_', num2str(sim_num), '_ci' )

			finResults.(field_name) = simResults3;

			% %% Vary 
			% paramRVary = 'prop_R0'
			% paramPVary = 'homophily'

			% simResults4 = buildParamPlane(paramRVary, 0, 1, paramPVary, 0, 1, 0.025, t_proj, kappa_);

			% field_name = strcat('sim_num_', num2str(sim_num), '_propRhomophily')

			% finResults.(field_name) = simResults4;

			%iterate
			sim_num = sim_num + 1;

		end
	end
	save("Sociodynamics/fig_data/finResults.mat", "finResults")
	disp('varying homophily now');
	for t_proj = [25]
		for delta_ = [1.0]
			for homophily_ = [0, 0.25, 0.5, 0.75, 0.95, 1.0 ]
				disp(strcat('Sim = ', num2str(sim_num)));
		
				%% Vary omega
				simResults1 = buildParamPlane('omega_R', 1.5, 7, 'omega_P', 1.0, 6.5, 0.1, t_proj, delta_, homophily_);
				field_name = strcat('sim_num_', num2str(sim_num),'_omega')

				finResults.(field_name) = simResults1;

				%% Vary k_r k_P
				paramRVary = 'k_R'
				paramPVary = 'k_P'

				simResults2 = buildParamPlane(paramRVary, 0.1, 5, paramPVary, 0.1, 5, 0.1, t_proj, delta_, homophily_);
				field_name = strcat('sim_num_', num2str(sim_num), '_ki')

				finResults.(field_name) = simResults2;

				%% Vary c_P and c_R
				paramRVary = 'c_R'
				paramPVary = 'c_P'

				simResults3 = buildParamPlane(paramRVary, 0.1, 7, paramPVary, 0.1, 7, 0.1, t_proj, delta_, homophily_);
				field_name = strcat('sim_num_', num2str(sim_num), '_ci' )

				finResults.(field_name) = simResults3;

				% %% Vary 
				% paramRVary = 'prop_R0'
				% paramPVary = 'homophily'

				% simResults4 = buildParamPlane(paramRVary, 0, 1, paramPVary, 0, 1, 0.025, t_proj, kappa_);

				% field_name = strcat('sim_num_', num2str(sim_num), '_propRhomophily')

				% finResults.(field_name) = simResults4;

				%iterate
				sim_num = sim_num + 1;
			end
		end
	end
	save("Sociodynamics/fig_data/finResultsHomophily.mat", "finResults")

end
