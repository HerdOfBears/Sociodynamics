function dC_sodt = C_so_dot(t, R_so, L)
    % Time rate of change for C_so, carbon in SOil
    %{
     Variables:
        t    = time
        R_so = Resp. from soil
        L    = turnover
    Params:
    %}
    dC_sodt = L - R_so;
end