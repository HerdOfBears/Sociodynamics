function T_f = temp_proj(t, T, T_prev, t_p, t_f)
    % Temperature prediction from an "individual's" p.o.v.
    %{
    Variables:
        t      = The current time in years
        T      = The temperature at time t
        T_prev = The temperature at time t_p
    Parameters:
        t_f = num yrs to forecast to
        t_p = num yrs to remember ('memory' of historical extreme events)
    %}
    T_f = T + (t_f./t_p).*(T - T_prev);
end