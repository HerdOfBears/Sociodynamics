function finResults = xPxRanalysis(numSim, tspan)
    % want to make plots of xR vs. xP, and curves based on different levels of homophily, alpha_P1/fmax, etc. 
    temp_struct = struct();
    xPout = [];
    xRout = [];
    xPout_dis = [];
    xRout_dis = [];

    % Vary homophily. 
    for h_=(0.0:0.25:1.0)
        % run sim to grab xPvals, and xRvals. 
        allResults = simESM_w_soc_YJM(numSim, tspan, h_);

        % need to grab xPvals, xRvals, and normalize each sim by the max group size.
        % xPvals = allResults.xPvals./(1-allResults.prop_R0);
        % xRvals = allResults.xRvals./(allResults.prop_R0);

        xPvals = allResults.xPvals;
        xRvals = allResults.xRvals;

        % only want up to time 2100. Since tspan = 2014:0.1:tfinal>2100, it occurs @ index 861
        xPvals = xPvals(1:861,:);
        xRvals = xRvals(1:861,:);

        xPvalsMed = median(xPvals');
        xRvalsMed = median(xRvals');

        xPout = [xPout;xPvalsMed];
        xRout = [xRout;xRvalsMed];        
    end
    
    % Vary alpha_P1, with f_max = 5. Want to see how increasing dissatisfaction occurs. 
    for alpha_P1=(0.0:2.5:10.0)
        % run sim to grab xPvals, and xRvals. 
        h_=0.5; % 'baseline'
        allResults = simESM_w_soc_YJM(numSim, tspan, h_, alpha_P1);

        % need to grab xPvals, xRvals, and normalize each sim by the max group size.
        % xPvals = allResults.xPvals./(1-allResults.prop_R0);
        % xRvals = allResults.xRvals./(allResults.prop_R0);
        xPvals = allResults.xPvals;
        xRvals = allResults.xRvals;
        
        % only want up to time 2100. Since tspan = 2014:0.1:tfinal>2100, it occurs @ index 861
        xPvals = xPvals(1:861,:);
        xRvals = xRvals(1:861,:);        

        xPvalsMed = median(xPvals');
        xRvalsMed = median(xRvals');

        xPout_dis = [xPout_dis; xPvalsMed];
        xRout_dis = [xRout_dis; xRvalsMed];
    end


    temp_struct.xPout = xPout;
    temp_struct.xRout = xRout;    
    temp_struct.xPout_dis = xPout_dis;
    temp_struct.xRout_dis = xRout_dis;    

    finResults = temp_struct;
end
