global data1751to2014
data1751to2014 = csvread('./Sociodynamics/BestCase_BaselineParams.csv');

tspan = 2014:1:2200;
lags_ = [10];
sol_  = dde23(@syst_odeswSocCoupling, lags_, @history, tspan);

function h_t = history(t)
    global data1751to2014
    h_t = interp1(data1751to2014(:,1), data1751to2014(:,end), t);
end