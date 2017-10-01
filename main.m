clear; clc; close all;

c       = 2;           % chord (m)
alpha   = 10;          % AoA (degrees)
V_inf   = 100;         % freestream speed (m/s)
p_inf   = 2.65*(10^4); % pressure (Pa)
rho_inf = 0.4135;      % density (kg/(m^3))
N       = 10000;       % number of vortcies for simulating an airfoil

disp('Base conditions:')
fprintf('chord        = %d m\n', c);
fprintf('AoA          = %d degrees\n', alpha);
fprintf('V_infinty    = %d m/s\n', V_inf);
fprintf('P_infinity   = %f Pa\n', p_inf);
fprintf('Rho_infinity = %f kg/m^3\n', rho_inf);
fprintf('%d vorticies for "true" flow\n', N)

% create plot the 'true' flow field and save the plots
[x, y, p_true] = Plot_Airfoil_Flow(c, alpha, V_inf, p_inf, rho_inf, N, true, true);
v_true         = sqrt(2*(p_inf - p_true)/rho_inf + V_inf^2);

% calculate and plot the errors in velocity and pressure with fewer vorticies
n = 100; % number of vorticies
res = [0, 0, 0];
while n < N
  % calculate pressure with different number of vorticies and don't bother with the plots
  [~, ~, p] = Plot_Airfoil_Flow(c, alpha, V_inf, p_inf, rho_inf, n, false, false);
  v         = sqrt(2*(p_inf - p)/rho_inf + V_inf^2); % ya boi bernoulli coming in clutch
  
  % find the difference from the 'true' flow
  dp = p - p_true;
  dv = v - v_true;

  res(end + 1, :) = [n, max(max(abs(dp))), max(max(abs(dv)))]; 
  n = n + 500;
end

% plot and save pressure and velocity error graphs
figure; hold on; grid on;
title('Number of vorticies vs max pressure error')
xlabel('Number of vorticies');
ylabel('Error in pressure estimate (Pa)');
scatter(res(1:end, 1), res(1:end, 2));
print('pressure_vs_N', '-dpng')

figure; hold on; grid on;
title('Number of vorticies vs max velocity error')
xlabel('Number of vorticies');
ylabel('Velocity error (m/s)');
scatter(res(1:end, 1), res(1:end, 3));
print('velocity_vs_N', '-dpng')

% plot changes in chord
for c = 1:3
  Plot_Airfoil_Flow(c, alpha, V_inf, p_inf, rho_inf, n, true, true);
end

% plot changes in alpha
c = 2;
for alpha = [0, 15, 30]
  Plot_Airfoil_Flow(c, alpha, V_inf, p_inf, rho_inf, n, true, true);
end