c       = 2;           % chord
alpha   = 10;          % AoA
V_inf   = 50;          % freestream speed
p_inf   = 2.65*(10^4); % pressure
rho_inf = 0.4135;      % density
N       = 1000;        % number of vortcies for simulating an airfoil

Plot_Airfoil_Flow(c, alpha, V_inf, p_inf, rho_inf, N);
