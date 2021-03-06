function parameters_ = get_parameters_YJM(random_yes_no)
	%{
	Yellow Jacket Model version
	Returns array of parameters.
	
	Variables:
		random_yes_no : integer
			Switches between returning parameters sampled from triangular
			distributions, or to return baseline params with upper and lower bounds. 
	%}
	% rng(101)
	parameters_given = struct();
	
	if ~random_yes_no
		% Initial proportion of the tot. population that is 
		% rich compared to poor.
		parameters_given.prop_R0 = 0.25;
		% parameters_given.prop_R0 = 0.75;		
	end
	if random_yes_no
		% pdpropR = makedist('Triangular', 'a', 0.10, 'b', 0.25, 'c', 0.40);
		pdpropR = makedist('Triangular', 'a', 0.25.*0.9, 'b', 0.25, 'c', 0.25.*1.1);		
		parameters_given.prop_R0 = random(pdpropR, 1,1);
		% parameters_given.prop_R0 = 0.25;
	end

	% Gets the proportion of the subpops' respective initial amounts
	parameters_given.xP0   = 0.05 .* (1 - parameters_given.prop_R0);
	parameters_given.xR0   = 0.05 .* parameters_given.prop_R0;
	
	parameters_given.homophily = 0.5;

	parameters_given.kappa = 0.05;
	parameters_given.delta = 1.0; % Controls how strong the restoring force is for a strategy proportional to the number of people (social) with that strategy
	parameters_given.beta  = 0.5;
	parameters_given.k_MM  = 1.478;
	parameters_given.s_    = 50;
	parameters_given.k_A   = 8.7039.*10^(9);
	parameters_given.k_B   = 157.072;
	parameters_given.f_gtm = 8.3259 .* 10^(13); % conversion factor GtC -> C; pg. 1 of Thomas' SI    

	%%%% Parameters used in computing payoffs:
	parameters_given.alpha_P0 = 1.0; % 
	parameters_given.alpha_P1 = 4.0; % Controls the cost of mitigative behaviour when there is no dissatisfaction
	parameters_given.alpha_R0 = 0.5; % Cost of mitigative behaviour for rich subpop.

	% Baseline per-capita income for rich and poor
	parameters_given.omega_R = 5; 
	parameters_given.omega_P = 3.5;

	% how quickly income decreases with large temperature deviations
	parameters_given.k_R = 1; 
	parameters_given.c_R = 2.0;
	parameters_given.k_P = 2.0;
	parameters_given.c_P = 3.0;
	parameters_given.Omega = 3;
	% parameters_given.Td_c = 1.8;
	parameters_given.Td_c = 1.5; 

	if ~random_yes_no
		%%%%%%%%%%%%%%
		%%%% Parameter values
		%%%%%%%%%%%%%%
	
		%%% Initial conditions and distributions (non-deviation initials):
		parameters_given.C_at0   = 596;% (590, 596, 602) 

		parameters_given.C_oc0   = 1.5e5;% (1.4, 1.5, 1.6)e5 % this can't be zero, otherwise we are dividing by zero

		parameters_given.C_veg0  = 550;% (540, 550, 560)

		parameters_given.C_so0   = 1500;% (1480, 1500, 1520)

		parameters_given.T_0     = 288.15;% (288, 288.15, 288.3)

		%%% Photosynthesis params.
		parameters_given.k_p   = 0.184;%(0.175, 0.184, 0.193)

		%k_MM = 1.478; 
		parameters_given.k_c   = 29e-6;%(26, 29, 32)e-6
		parameters_given.k_M   = 120e-6;% (108, 120, 132) e-6

		parameters_given.k_a  = 1.773.*10^(20); % mole vol. of atmos 

		%%% Plant resp. params:
		parameters_given.k_r   = 0.092;%(0.0828, 0.092, 0.1012)
		%k_A   = 8.7039.*10^(9);
		%E_a = 54.83;
		parameters_given.E_a   = 54.83e3;% (54.63, 54.83, 55.03)e3 % In Bury's mathematica nb this is whereas in SI it isn't cubed

		%%% Soil resp. params:
		parameters_given.k_sr = 0.0337;% soil resp. rate const.(0.0303, 0.034, 0.037)
		%k_B  = 157.072; %

		%%%% Turnover params:
		parameters_given.k_t = 0.092;%(0.0828, 0.092, 0.1012)

		%%%% Heat cap. of Earth's surface:
		parameters_given.c = 4.69e23;% (4.22, 4.69, 5.16)e23


		%%%% Constants:
		parameters_given.a_E   = 5.101*10^(14); % Earth's surface area 
		parameters_given.sigma = 5.67*10^(-8); % Stefan-Boltzmann const. 
		parameters_given.latent_heat = 43655; 
		parameters_given.R = 8.314; % molar gas const.
		%H = 0.5915; % relative humidity; calibrated

		parameters_given.A = 0.225;% surface albedo (0.203, 0.225, 0.248)
		parameters_given.S = 1368;% solar flux (1231, 1368, 1504)

		parameters_given.tao_CH4 = 0.0231;%random(pdtao_CH4,1,1); % (0.0208, 0.0231, 0.0254) see: atmos_down_flux to resolve potential probs.
		parameters_given.P_0     = 1.4e11;% random(pdP_0, 1,1); % (1.26, 1.4, 1.54)e11 water vapor sat. const.
		parameters_given.F_0     = 2.5e-2;% (2.25, 2.5, 2.75)e-2 ocean flux rate const.
		parameters_given.chi     = 0.3;% (0.2, 0.3, 0.4) characteristic CO2 solubility
		parameters_given.zeta    = 50;% (40, 50, 60) "evasion factor"

		C_at0 = parameters_given.C_at0;
		f_gtm = parameters_given.f_gtm;
		k_a   = parameters_given.k_a;
		P_0   = parameters_given.P_0;
		latent_heat = parameters_given.latent_heat;
		A = parameters_given.A;
		S = parameters_given.S;
		tao_CH4 = parameters_given.tao_CH4;

		parameters_given.tao_co2 = 1.73.*(mixingCO2a(0, C_at0, f_gtm, k_a)).^0.263;
		tao_co2 = parameters_given.tao_co2; 
		parameters_given.H = calibrate_humidity(P_0, latent_heat, A, S, tao_CH4, tao_co2);

		parameters_given.f_max = 5; % (4,5,6) max of warming cost function f(T)
		parameters_given.omega = 3; % (1,3,5) nonlinearity of warming cost function
		parameters_given.T_c   = 2.5;% (2.4, 2.5, 2.6) critical temperature of f(T)
		parameters_given.t_p   = 10; % num. prev. yrs used for temp pred.
		parameters_given.t_f   = 15; % (0, 25, 50) num yrs ahead for temp. proj.
		%s_    = 50;% (30, 50, 70) half-sat. time for epsilon(t) from 2014
		parameters_given.eps_max   = 7;% (4.2, 7, 9.8) max change in epsilon(t) from 2014

		parameters_given.f_gtm = 8.3259 .* 10^(13); % conversion factor GtC -> C; pg. 1 of Thomas' SI


		%kappa = 0.2;    % (0.02, 0.05, 0.2) social learning rate
		%beta  = 0.5;    % (0.5, 1, 1.5) net cost of being a mitigator
		%delta = 0.5;    % (0.5, 1, 1.5) strength of social norms

	else
		%%%%%%%%%%%%%%
		%%%% Parameter values
		%%%%%%%%%%%%%%
		%parameters_given = [];

		pdx_0 = makedist('Triangular', 'a', 0.01, 'b', 0.05, 'c', 0.1);
		%x_0 = 0.05;%;%random(pdx_0, 1,1);
		
		% 1
		%%% Initial conditions and distributions (non-deviation initials):
		pdC_at0 = makedist('Triangular', 'a', 590, 'b', 596, 'c', 602);
		parameters_given.C_at0   = random(pdC_at0, 1,1); % (590, 596, 602) 


		% 2 
		pdC_oc0 = makedist('Triangular', 'a', 1.4e5, 'b', 1.5e5, 'c', 1.6e5);
		parameters_given.C_oc0   = random(pdC_oc0, 1,1);%1.5e5;%random(pdC_oc0, 1,1);% (1.4, 1.5, 1.6)e5 % this can't be zero, otherwise we are dividing by zero


		% 3
		pdC_veg0= makedist('Triangular', 'a', 540, 'b', 550, 'c', 560);
		parameters_given.C_veg0  = random(pdC_veg0, 1,1); % (540, 550, 560)

		% 4
		pdC_so0 = makedist('Triangular', 'a', 1480, 'b', 1500, 'c', 1520);
		parameters_given.C_so0   = random(pdC_so0, 1,1);% (1480, 1500, 1520)

		% 5
		pdT_0   = makedist('Triangular', 'a', 288, 'b', 288.15, 'c', 288.3);
		parameters_given.T_0 = 288.15;

		% 6
		%%% Photosynthesis params.
		pdk_p = makedist('Triangular', 'a', 0.9*0.184, 'b', 0.184, 'c', 1.1*0.184);
		parameters_given.k_p   = random(pdk_p, 1,1); % (0.175, 0.184, 0.193)
		
		%pdk_MM = makedist('Triangular', 'a', 0.9*1.478, 'b', 1.478, 'c', 1.1*1.478);
		%k_MM = 1.478;%;%random(pdk_MM, 1,1); 

		% 7
		pdk_c = makedist('Triangular', 'a', 0.9*29e-6, 'b', 29e-6, 'c', 1.1*29e-6);
		%k_c = 29e-6;
		parameters_given.k_c   = random(pdk_c, 1,1); % (26, 29, 32)e-6

		% 8
		pdk_M = makedist('Triangular', 'a', 0.9*120e-6, 'b', 120e-6, 'c', 1.1*120e-6);
		%k_M = 120e-6;
		parameters_given.k_M   = random(pdk_M, 1,1); % (108, 120, 132) e-6

		% 9
		parameters_given.k_a  = 1.773.*10^(20); % mole vol. of atmos 

		% 10
		%%% Plant resp. params:
		pdk_r = makedist('Triangular', 'a', 0.0828, 'b', 0.092, 'c', 0.1012);
		% parameters_given.k_r = 0.092;
		parameters_given.k_r   = random(pdk_r, 1,1); % (0.0828, 0.092, 0.1012)
		
		%pdk_A = makedist('Triangular', 'a', 0.9*8.7039e9, 'b',8.7039e9, 'c', 1.1*8.7039e9);
		%k_A   = 8.7039e9;%;%random(pdk_A, 1,1);
		
		% 11
		%E_a = 54.83;
		pdE_a = makedist('Triangular', 'a', 54.63e3, 'b', 54.83e3, 'c', 55.03e3);
		%E_a =54.83e3;
		parameters_given.E_a   = random(pdE_a, 1,1); % (54.63, 54.83, 55.03)e3 % In Bury's mathematica nb this is whereas in SI it isn't cubed


		% 12
		%%% Soil resp. params:
		baseline = 0.0337;
		pdk_sr = makedist('Triangular', 'a', 0.9*0.034, 'b', baseline, 'c', 1.1*0.034);
		%k_sr = 0.034;
		parameters_given.k_sr = random(pdk_sr,1,1); % soil resp. rate const.(0.0303, 0.034, 0.037)
		% parameters_given.k_sr = baseline;

		%pdk_B = makedist('Triangular', 'a', 0.9*157.072, 'b', 157.072, 'c', 1.1*157.072);
		%k_B  = 157.072;%;%random(pdk_B, 1, 1); %
		

		% 13
		%%%% Turnover params:
		pdk_t = makedist('Triangular', 'a', 0.9*0.092, 'b', 0.092, 'c', 1.1*0.092);
		%k_t = 0.092;
		parameters_given.k_t = random(pdk_t,1,1); % (0.0828, 0.092, 0.1012)

		% 14
		%%%% Heat cap. of Earth's surface:
		pdc = makedist('Triangular', 'a', 0.9*4.69e23, 'b', 4.69e23, 'c', 1.1*4.69e23);
		%c = 4.69e23;
		parameters_given.c = random(pdc,1,1); % (4.22, 4.69, 5.16)e23


		% 15, 16, 17, 18, 19, 20
		%%%% Constants:
		parameters_given.a_E   = 5.101*10^(14); % Earth's surface area 
		parameters_given.sigma = 5.67*10^(-8); % Stefan-Boltzmann const. 
		parameters_given.latent_heat = 43655; 
		parameters_given.R = 8.314; % molar gas const.
		%H = 0.5915; % relative humidity; calibrated

		% 21
		pdA = makedist('Triangular', 'a', 0.9*0.225, 'b', 0.225, 'c', 1.1*0.225);
		parameters_given.A = random(pdA,1,1); % surface albedo (0.203, 0.225, 0.248)

		% 22 Solar flux
		baseline = 1368;
		lower_b  = 1231;
		upper_b  = 1504;
		% lower_b  = 0.9*baseline;
		% upper_b  = 1.1*baseline;
		pdS = makedist('Triangular', 'a', lower_b, 'b', baseline, 'c', upper_b);
		parameters_given.S = random(pdS,1,1); % solar flux (1231, 1368, 1504)
		% parameters_given.S = baseline;

		pdtao_CH4 = makedist('Triangular', 'a', 0.9*0.0231, 'b', 0.0231, 'c', 1.1*0.0231);
		%tao_CH4 = 0.0231;
		parameters_given.tao_CH4 = random(pdtao_CH4,1,1); % (0.0208, 0.0231, 0.0254) see: atmos_down_flux to resolve potential probs.

		pdP_0 = makedist('Triangular', 'a', 0.95*1.4e11, 'b', 1.4e11, 'c', 1.05*1.4e11);
		%P_0 = 1.4e11;
		parameters_given.P_0   = random(pdP_0, 1,1); % (1.26, 1.4, 1.54)e11 water vapor sat. const.

		pdF_0 = makedist('Triangular', 'a', 2.25e-2, 'b', 2.5e-2, 'c', 2.75e-2);
		%F_0 = 2.5e-2;
		parameters_given.F_0   = random(pdF_0,1,1); % (2.25, 2.5, 2.75)e-2 ocean flux rate const.

		pdChi = makedist('Triangular', 'a', 0.2, 'b', 0.3, 'c', 0.4);
		%chi = 0.3;
		parameters_given.chi   = random(pdChi,1,1); % (0.2, 0.3, 0.4) characteristic CO2 solubility

		pdZeta = makedist('Triangular', 'a', 40, 'b', 50, 'c', 60);
		%zeta = 50;
		parameters_given.zeta   = random(pdZeta,1,1); % (40, 50, 60) "evasion factor"


		%%% Compute humidity given the randomly sampled parameter values
		C_at0 = parameters_given.C_at0;
		f_gtm = parameters_given.f_gtm;
		k_a   = parameters_given.k_a;
		P_0   = parameters_given.P_0;
		latent_heat = parameters_given.latent_heat;
		A = parameters_given.A;
		S = parameters_given.S;
		tao_CH4 = parameters_given.tao_CH4;

		parameters_given.tao_co2 = 1.73.*(mixingCO2a(0, C_at0, f_gtm, k_a)).^0.263;
		tao_co2 = parameters_given.tao_co2; 
		parameters_given.H = calibrate_humidity(P_0, latent_heat, A, S, tao_CH4, tao_co2);

		pdf_max = makedist('Triangular', 'a', 4, 'b', 5, 'c', 6);
		% parameters_given.f_max = 6;
		parameters_given.f_max = random(pdf_max, 1, 1); % (4,5,6) max of warming cost function f(T)

		pdOmega = makedist('Triangular', 'a', 1, 'b', 3, 'c', 5);
		%omega = 3;
		parameters_given.omega   = random(pdOmega,1,1); % (1,3,5) nonlinearity of warming cost function

		baseline = 2.5;
		lower_b  = 0.9*baseline;
		upper_b  = 1.1*baseline;
		pdT_c = makedist('Triangular', 'a', lower_b, 'b', baseline, 'c', upper_b);
		parameters_given.T_c = random(pdT_c,1,1); % (2.4, 2.5, 2.6) critical temperature of f(T)
		% parameters_given.T_c = baseline;


		parameters_given.t_p   = 10; % num. prev. yrs used for temp pred.
		

		baseline = 15;
		% lower_b  = 0;
		% upper_b  = 50;
		lower_b  = 0.9*baseline;
		upper_b  = 1.1*baseline;
		pdt_f = makedist('Triangular', 'a', lower_b, 'b', baseline, 'c', upper_b);
		parameters_given.t_f   = random(pdt_f, 1,1); % (0, 25, 50) num yrs ahead for temp. proj.
		% parameters_given.t_f = baseline;

		%pds_  = makedist('Triangular', 'a', 30, 'b', 50, 'c', 70);
		%s_    = 50;%;%random(pds_,1,1); % (30, 50, 70) half-sat. time for epsilon(t) from 2014

		baseline = 7;
		% lower_b  = 0.9*baseline;% 4.2 % normally, check table 1
		% upper_b  = 1.1*baseline;% 9.8 % normally, check table 1
		lower_b  = 4.2;
		upper_b  = 9.8;
		pdeps_max = makedist('Triangular', 'a', lower_b, 'b', baseline, 'c', upper_b);
		parameters_given.eps_max = random(pdeps_max,1,1); % (4.2, 7, 9.8) max change in epsilon(t) from 2014
		% parameters_given.eps_max = baseline;

		baseline = 0.05;
		lower_b  = 0.02;
		upper_b  = 0.2;
		% lower_b  = 0.9*baseline;
		% upper_b  = 1.1*baseline;	
		pdkappa = makedist('Triangular', 'a', lower_b, 'b', baseline, 'c', upper_b);
		parameters_given.kappa = random(pdkappa, 1,1);    % (0.02, 0.05, 0.2) social learning rate
		% parameters_given.kappa = baseline;

		%pdbeta = makedist('Triangular', 'a', 0.5, 'b', 1, 'c', 1.5);
		%beta  = 1.0;%;%random(pdbeta,1,1);    % (0.5, 1, 1.5) net cost of being a mitigator
		

		baseline = 1.0;
		lower_b  = 0.5;
		upper_b  = 1.5;
		pddelta = makedist('Triangular', 'a', lower_b, 'b', baseline, 'c', upper_b);
		parameters_given.delta = random(pddelta, 1,1);    % (0.5, 1, 1.5) strength of social norms
		% parameters_given.delta = baseline;
		
		%%%% Parameters used in computing payoffs:
		baseline = 3; % should be 1.0
		% baseline = 1;
		lower_b  = 0.9*baseline;
		upper_b  = 1.1*baseline;		
		pd_Omega = makedist('Triangular', 'a', lower_b, 'b', baseline, 'c', upper_b);
		parameters_given.Omega = random(pd_Omega, 1,1);

		baseline = 1.5; % 
		lower_b  = 0.9*baseline;
		upper_b  = 1.1*baseline;
		pd_Td_c = makedist('Triangular', 'a',lower_b, 'b', baseline, 'c', upper_b);
		parameters_given.Td_c = random(pd_Td_c, 1,1);
		% parameters_given.Td_c = baseline;

		baseline = 1.0; % should be 1.0
		lower_b  = 0.9*baseline;
		upper_b  = 1.1*baseline;		
		pd_alphaP0 = makedist('Triangular', 'a', lower_b, 'b', baseline, 'c', upper_b);
		parameters_given.alpha_P0 = random(pd_alphaP0, 1,1);
		% parameters_given.alpha_P0 = baseline;

		% baseline = 4.5;
		baseline = 5;
		lower_b  = 0.9*baseline;
		upper_b  = 1.1*baseline;
		% lower_b  = 0.0*baseline;
		% upper_b  = 2*baseline;
		pd_alphaP1 = makedist('Triangular', 'a',lower_b, 'b', baseline, 'c', upper_b);		
		parameters_given.alpha_P1 = random(pd_alphaP1, 1,1);
		% parameters_given.alpha_P1 = baseline;

		baseline = 0.5;
		lower_b  = 0.9*baseline;
		upper_b  = 1.1*baseline;
		pd_alphaR0 = makedist('Triangular', 'a', lower_b, 'b', baseline, 'c', upper_b);
		parameters_given.alpha_R0 = random(pd_alphaR0, 1,1);

		% Baseline per-capita income for rich and poor
		baseline = 5.0;
		lower_b  = 0.9*baseline;
		upper_b  = 1.1*baseline;
		pd_omega_R = makedist('Triangular', 'a', lower_b, 'b', baseline, 'c', upper_b);
		parameters_given.omega_R = random(pd_omega_R, 1,1);
		% parameters_given.omega_R = baseline;

		baseline = 3.5;
		% baseline = 4;
		lower_b  = 0.9*baseline;
		upper_b  = 1.1*baseline;
		pd_omega_P = makedist('Triangular', 'a', lower_b, 'b', baseline, 'c', upper_b);
		parameters_given.omega_P = random(pd_omega_P, 1,1);		
		% parameters_given.omega_P = baseline;

		% how quickly income decreases with large temperature deviations
		% baseline = 3.5; % what is usually used
		baseline = 1.0;
		lower_b  = 0.9*baseline;
		upper_b  = 1.1*baseline;
		pd_k_R = makedist('Triangular', 'a', lower_b, 'b', baseline, 'c', upper_b);
		parameters_given.k_R = random(pd_k_R, 1,1);
		% parameters_given.k_R = baseline;

		% baseline = 2.0; % what I usually use
		baseline = 1.5;
		lower_b  = 0.9*baseline;
		upper_b  = 1.1*baseline;
		pd_k_P = makedist('Triangular', 'a', lower_b, 'b', baseline, 'c', upper_b);
		parameters_given.k_P = random(pd_k_P, 1,1);
		% parameters_given.k_P = baseline;

		% baseline = 0.85;	
		% baseline = 0.1;
		baseline = 0.4;
		lower_b  = 0.9*baseline;
		upper_b  = 1.1*baseline;
		pd_c_R = makedist('Triangular', 'a', lower_b, 'b', baseline, 'c', upper_b);
		parameters_given.c_R = random(pd_c_R, 1,1);
		% parameters_given.c_R = baseline;

		% baseline = 2.0; 
		% baseline = 1.5;
		% baseline = 0.6; % for exponential functions
		baseline = 0.85;
		lower_b  = 0.9*baseline;
		upper_b  = 1.1*baseline;
		pd_c_P = makedist('Triangular', 'a', lower_b, 'b', baseline, 'c', upper_b);
		parameters_given.c_P = random(pd_c_P, 1,1);
		% parameters_given.c_P = baseline;

	end
	parameters_ = parameters_given;
end