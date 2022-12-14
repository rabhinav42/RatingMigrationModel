clear all;
clc;

rng(5);

ratings = {'AAA', 'AA', 'A', 'BBB', 'BB', 'B', 'CCC', 'D', 'NR'};

theta = 1 - 2.8*1e-2;
phi = 1 - 24.1*1e-2;

N = 100; % simulate ratings for N time points; we use 104 because reference uses 26 years.
n = 500; % (uniform) no of companies in each rating at start (excluding D and incl. NR) 

%%% ME and MC estimated from actual data (as in reference paper) %%%

ME = [ 86.809 6.340 1.071 0.226 0.124 0.023 0.002 0.046 5.359;  0.611 83.679 8.647 1.037 0.135 0.101 0.015 0.108 5.668; ...
    0.077 1.684 84.858 6.259 0.613 0.217 0.014 0.145 6.133; 0.018 0.254 3.854 82.264 4.872 0.730 0.078 0.282 7.649; ...
     0.030 0.092 0.497 4.995 74.129 7.782 0.614 1.185 10.676; 0.003 0.055 0.232 0.563 4.504 72.223 4.661 5.217 12.541; ...
      0.002 0.014 0.337 0.523 0.943 7.276 35.661 42.581 12.661; 0.000 0.000 0.000 0.000 0.000 0.000 0.000 100.000 0.000;...
       0.026 0.095 0.228 0.383 0.405 0.469 0.030 0.973 97.390];
ME = ME/100;

MC = [  70.961 10.697 3.716 1.156 0.203 0.067 0.007 0.297 12.896;  0.711 65.902 14.057 2.997 0.577 0.163 0.019 0.775 14.798; ...
    0.120 2.548 70.218 9.425 1.313 0.435 0.048 1.013 14.880;  0.019 0.677 5.499 70.022 6.051 1.082 0.095 1.404 15.152; ...
    0.019 0.157 1.285 5.652 59.671 7.397 0.743 5.018 20.058;  0.005 0.096 0.448 1.221 3.795 58.059 4.461 11.770 20.144; ...
    0.003 0.023 0.193 0.531 0.872 4.410 24.946 54.988 14.032; 0.000 0.000 0.000 0.000 0.000 0.000 0.000 100.000 0.000; ...
    0.030 0.181 0.387 0.705 0.549 0.524 0.049 2.627 94.948 ];
MC = MC/100;

%%% get simulation results %%%
mc_pavg = zeros(9,9);
me_pavg = zeros(9,9);
for i=1:20
    phase = sim_phase(theta, phi, N);
    mc_ravg = zeros(9,9);
    me_ravg = zeros(9,9);
    for j = 1:50
        [cmps, timeE, timeC, tnoE, tnoC] = sim_rating(ME, MC, N, n, phase);
        E_est = diag(1./timeE)*tnoE;
        E_est = E_est - diag(diag(E_est));
        rsumsE = sum(E_est, 2);
        QE_est = E_est - diag(rsumsE);
            
        C_est = diag(1./timeC)*tnoC;
        C_est = C_est - diag(diag(C_est));
        rsumsC = sum(C_est, 2);
        QC_est = C_est - diag(rsumsC);
        ME_est = expm(4*QE_est);
        MC_est = expm(4*QC_est);
        me_ravg = me_ravg*(j-1)/j+ ME_est/j;
        mc_ravg = mc_ravg*(j-1)/j + MC_est/j;
    end
    me_pavg = me_pavg*(i-1)/i+ me_ravg/i;
    mc_pavg = mc_pavg*(i-1)/i + mc_ravg/i;
    
end

%%% print ME,MC and plot PDC,PDE %%%

erE = norm(me_pavg - ME)
erC = norm(mc_pavg - MC)

ME_est = array2table(me_pavg, "RowNames", ratings, "VariableNames", ratings)
MC_est = array2table(mc_pavg, "RowNames", ratings, "VariableNames", ratings)
 
% get term structure of PD for CCC rating for both expansion and
% contraction
years = [1:30];
for y = years
    MEy = me_pavg^y;
    pdE(y) = MEy(7,8);
    MCy = mc_pavg^y;
    pdC(y) = MCy(7,8);
end

figure(1)
plot(years, pdE, "Marker", '_');
hold on
plot(years, pdC, 'Marker', ".");
hold off;
xlabel('Years')
ylabel('PD')
legend('Expansion', 'Contraction', 'Location', 'southeast')
saveas(figure(1), 'pd.jpg');

