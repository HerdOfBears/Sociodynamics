function dC_vegdt = C_veg_dot(t, P, R_veg, L)
    % Time rate of change for C_veg; carbon contained in vegetation
    %{
    Variables:
        t     = time
        P     = Carbon uptake from photosynthesis
        R_veg = Resp. from vegetation
        L     = Turnover
    %}
    dC_vegdt = P - R_veg - L;
end