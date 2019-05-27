function y = custom_RK4(odefun, tspan, y0, h, params_given, temp_history, x0)
% ODEFUN contains the ode functions of the system
% TSPAN  is a 1D vector of equally spaced t values
% Y0     contains the intial conditions for the system variables

    % Initialise step-size variables
    t = tspan(:); % ensure column vector = (0:h:1)';
    h = t(2)-t(1);% define h from t
    N = length(t);

    % Initialise y vector, with a column for each equation in odefun
    y = zeros(N, numel(y0));
    % Starting conditions
    y(1, :) = y0(:)';  % Set intial conditions using row vector of y0

    k = zeros(4, numel(y0));              % Initialise K vectors
    b = repmat([1 2 2 1]', 1, numel(y0)); % RK4 coefficients
    
    t_p=10./h;
    
    % Iterate, computing each K value in turn, then the i+1 step values
    for i = 1:(N-1)
        T_prev=0;
        if i <= -1
            T_prev = interp1(temp_history(:,1), temp_history(:,end), t(i)); 
        end
        if t(i)>2014 && t(i)<2024%i>t_p
            disp(1000-i)
            T_prev = temp_history(end - (1000 - i),end);
            %T_prev = y(i-1000,end);
        end
        if t(i)>2024
            T_prev = y(i-1000,end);
        end
        k(1, :) = odefun(t(i), y(i,:), params_given, T_prev, x0);        
        k(2, :) = odefun(t(i) + (h/2), y(i,:) + (h/2)*k(1,:), params_given, T_prev, x0);        
        k(3, :) = odefun(t(i) + (h/2), y(i,:) + (h/2)*k(2,:), params_given, T_prev, x0);
        %{
        if t(i)>2014%i>t_p
            disp(i+1-1000)
            T_prev = y(i+1-1000,end);
        end
        %}
        k(4, :) = odefun(t(i) + h, y(i,:) + h*k(3,:), params_given, T_prev, x0);

        y(i+1, :) = y(i, :) + (h/6)*sum(b.*k);    
    end    
end