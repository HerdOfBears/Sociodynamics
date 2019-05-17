function living = turnover(C_veg, k_t, C_veg0)
    %  Assume const. fraction of plants dying in a given unit of time
    %{
    Variables:
        C_veg = deviation in CO2 in vegetation
    Parameters:
        k_t = turnover rate const. 
    %}
    living = k_t.*(C_veg+C_veg0);
end