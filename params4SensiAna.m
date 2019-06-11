function parameters =  performSensiAna()


		%%%%%%%%%%%%%%
		%%%% Parameter values
		%%%%%%%%%%%%%%
		parameters_given = [];


		temp_ = struct();

		temp_.kappa = [0.02, 0.05, 0.2];
		temp_.delta = [0.5, 1, 1.5];
		temp_.beta  = [0.5, 1, 1.5];
		temp_.k_MM  = 1.478;
		temp_.s_    = [30, 50, 70];
		temp_.k_A   = 8.7039.*10^(9);
		temp_.k_B   = 157.072;
		temp_.f_gtm = 8.3259 .* 10^(13); % conversion factor GtC -> C; pg. 1 of Thomas' SI

		temp_.x0 = [0.01, 0.05, 0.1];
		
		% 1
		%%% Initial conditions and distributions (non-deviation initials):
		temp_.C_at0   = [590, 596, 602];

		% 2 
		temp_.C_oc0   = [1.4e5, 1.5e5, 1.6e5];

		% 3
		temp_.C_veg0  = [ 540, 550, 560];
		
		% 4
		%C_so0 = 1500;
		temp_.C_so0   = [1480, 1500, 1520];

		% 5
		% T_0 =  [288, 288.15, 288.3];
		temp_.T_0 = 288.15;

		%% parameters_given = [x0, C_at0, C_oc0, C_veg0, C_so0, T_0];

		% 6
		%%% Photosynthesis params.
		% temp_.k_p   = [0.9*0.184, 0.184, 1.1*0.184];
		temp_.k_p   = [0.1748, 0.184, 0.1932];

		%pdk_MM = makedist('Triangular', 'a', 0.9*1.478, 'b', 1.478, 'c', 1.1*1.478);
		%k_MM = 1.478;%;%random(pdk_MM, 1,1); 

		% 7
		%k_c = 29e-6;
		temp_.k_c   = [0.0000261, 29e-6, 0.0000319];

		% 8
		%k_M = 120e-6;
		temp_.k_M   = [0.000108, 120e-6, 0.000132];

		% 9
		temp_.k_a  = 1.773.*10^(20); % mole vol. of atmos 

		%% parameters_given = [parameters_given, k_p, k_MM, k_c, k_M, k_a];

		% 10
		%%% Plant resp. params:
		%k_r = 0.092;
		temp_.k_r   = [0.0828, 0.092, 0.1012];
		
		%pdk_A = makedist('Triangular', 'a', 0.9*8.7039e9, 'b',8.7039e9, 'c', 1.1*8.7039e9);
		%k_A   = 8.7039e9;%;%random(pdk_A, 1,1);
		
		% 11
		%E_a =54.83e3;
		temp_.E_a   = [54.63e3, 54.83e3, 55.03e3];

		% 12
		%%% Soil resp. params:
		%k_sr = 0.034;
		temp_.k_sr = [0.03033, 0.0337, 0.03707];

		%pdk_B = makedist('Triangular', 'a', 0.9*157.072, 'b', 157.072, 'c', 1.1*157.072);
		%k_B  = 157.072;%;%random(pdk_B, 1, 1); %
		

		%% parameters_given = [parameters_given, k_r, k_A, E_a, k_sr, k_B];
		% 13
		%%%% Turnover params:
		%k_t = 0.092;
		temp_.k_t = [0.9*0.092, 0.092, 1.1*0.092];

		% 14
		%%%% Heat cap. of Earth's surface:
		%c = 4.69e23;
		temp_.c = [0.9*4.69e23, 4.69e23, 1.1*4.69e23];

		%% parameters_given = [parameters_given, k_t, c];

		% 15, 16, 17, 18, 19, 20
		%%%% Constants:
		temp_.a_E   = 5.101*10^(14); % Earth's surface area 
		temp_.sigma = 5.67*10^(-8); % Stefan-Boltzmann const. 
		temp_.latent_heat = 43655; 
		temp_.R = 8.314; % molar gas const.
		%H = 0.5915; % relative humidity; calibrated

		% 21
		%A = 0.225;
		temp_.A = [0.2025, 0.225, 0.2475];

		% 22 Solar flux
		%S = 1368;
		temp_.S = [1231.2, 1368, 1504.8];

		%tao_CH4 = 0.0231;
		temp_.tao_CH4 = [0.02079, 0.0231, 0.02541];

		%P_0 = 1.4e11;
		temp_.P_0   = [1.26e11, 1.4e11, 1.54e11];

		%F_0 = 2.5e-2;
		temp_.F_0   = [2.25e-2, 2.5e-2, 2.75e-2];

		%chi = 0.3;
		temp_.chi   = [0.2, 0.3, 0.4];

		%zeta = 50;
		temp_.zeta   = [40, 50, 60];


		tao_co2 = 1.73.*(mixingCO2a(0, temp_.C_at0, temp_.f_gtm, temp_.k_a)).^0.263;
		H = calibrate_humidity(temp_.P_0, temp_.latent_heat, temp_.A, temp_.S, temp_.tao_CH4, tao_co2);
		%disp(H)

		temp_.H = H;

		%% parameters_given = [parameters_given, a_E, sigma, latent_heat, R, H, A, S];
		%% parameters_given = [parameters_given, tao_CH4, P_0, F_0, chi, zeta];

		temp_.f_max = [4, 5, 6];
		% f_max = random(pdf_max, 1, 1); % (4,5,6) max of warming cost function f(T)

		%omega = 3;
		temp_.omega   = [1, 3, 5];

		%T_c = 2.5;
		temp_.T_c   = [2.4, 2.5, 2.6];
		
		temp_.t_p   = 10; % num. prev. yrs used for temp pred.
		
		% t_f   = random(pdt_f, 1,1); % (0, 25, 50) num yrs ahead for temp. proj.
		temp_.t_f   = [0, 25, 50];

		%pds_  = makedist('Triangular', 'a', 30, 'b', 50, 'c', 70);
		%s_    = 50;%;%random(pds_,1,1); % (30, 50, 70) half-sat. time for epsilon(t) from 2014

		temp_.eps_max   = 7;% (4.2, 7, 9.8) max change in epsilon(t) from 2014

		%% parameters_given = [parameters_given, f_max, omega, T_c, t_p, t_f, s_, eps_max, f_gtm];
		
		%pdkappa = makedist('Triangular', 'a', 0.02, 'b', 0.05, 'c', 0.2);
		%kappa = 0.05;%;%random(pdkappa, 1,1);    % (0.02, 0.05, 0.2) social learning rate
		
		%pdbeta = makedist('Triangular', 'a', 0.5, 'b', 1, 'c', 1.5);
		%beta  = 1.0;%;%random(pdbeta,1,1);    % (0.5, 1, 1.5) net cost of being a mitigator
		
		%pddelta = makedist('Triangular', 'a', 0.5, 'b', 1, 'c', 1.5);
		%delta = 1.0;%;%random(pddelta, 1,1);    % (0.5, 1, 1.5) strength of social norms

		%% parameters_given = [parameters_given, kappa, beta, delta];

		parameters = temp_;
end