function make_param_plane_YJM(sim_, yticklabels_, xticklabels_, num_ticks, slash_yes_no, save_yes_no)
	
	if nargin < 6
		save_yes_no = 0;
	end

	fld_names = fieldnames(sim_);
	[n,m] = size(sim_.maxT);
	le_ = sqrt(m);

	clf
	imagesc(reshape(sim_.maxT, le_, le_) )
	yticks(num_ticks)
	yticklabels(yticklabels_)
	%yticklabels(1:(3.5/6):4.5)
	xticks(num_ticks)
	xticklabels(xticklabels_)
	colorbar
	set(gca,'YDir','normal')
	
	if slash_yes_no
		xlabel( strcat("\", fld_names(4) ) )
		ylabel( strcat("\", fld_names(5) ) )
	else
		xlabel(fld_names(4))
		ylabel(fld_names(5))
	end		

	cbar_ = colorbar;
	ylabel(cbar_, "Peak-T")
	title_ = strcat("t_f = ",     num2str(sim_.temp_f), ...
	    			"; \delta = ",num2str(sim_.deltaVal), ...
	    			"; h = ",     num2str(sim_.homophily) )
	title(title_)

	if save_yes_no
		temp_filename = strcat("omega_maxT_tf", num2str(sim_.temp_f), ...
						"_delta", num2str(sim_.deltaVal), ...
						 "_homop", num2str(sim_.homophily) );
		imwrite( reshape(sim_.maxT, le_, le_), "./Sociodynamics/fig_data/omega_planes/", "png" );
	end
end