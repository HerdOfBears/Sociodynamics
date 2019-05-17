function emissions_ = baseline_CO2_emis(t, epsilon_max, s, data)
    % Computes baseline CO2 emissions in absence of mitigation
    %{
    Variables:
    Parameters:
        data = Data from CDIAC on global CO2 emissions up to 2014
                This is an array
    %}
    if t<=2014
        ftimes = data(:,1);
        f      = data(:,2);
        emissions_ = interp1(ftimes, f, t); % interpolates dataset (ftimes, f) to time t
    else
        emissions_ = data(end, 2) + ((t-2014).*epsilon_max)./(t-2014+s);
        %disp('emissions_ = ')
        %disp(emissions_)
    end
    
end