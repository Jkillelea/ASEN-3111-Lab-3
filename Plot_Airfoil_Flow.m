function [x, y, P] = Plot_Airfoil_Flow(c, alpha, V_inf, p_inf, rho_inf, N, render_plots, save_plots)
  % c            -> chord length, meters
  % alpha        -> angle of attack, degrees (converted to radians)
  % V_inf        -> freestream, m/s
  % p_inf        -> freestream pressure, Pa (I guess)
  % rho_inf      -> freestream density, kg/m^3
  % N            -> number of vortcies
  % render_plots -> optional boolean (default true)
  % save_plots   -> optional boolean (default false, does nothing if render_plots is false)

  % NOTE: alpha MUST be in radians for dimensional consistency
  alpha = deg2rad(alpha);
  dx    = c/N;

  % define the x-y plane we're working in
  res     = 100;
  range_x = linspace(-3, 3, res);
  range_y = linspace(-3, 3, res);
  [x, y]  = meshgrid(range_x, range_y);

  % if we haven't been told whether or not to show plots
  if ~exist('render_plots', 'var')
    render_plots = true;
  end

  % if we haven't been told whether or not to save plots
  if ~exist('save_plots', 'var')
    save_plots = false;
  end

  if(save_plots && ~render_plots)
    warning('Asked to save plots, but plots are note being rendered. Plots will not be saved.');
  end

  %%%%%%%%%%%%%%%%%%%%%% STREAMLINE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % vortex params for a streamline
  gamma = @(x1) 2*alpha*V_inf.*sqrt((1-(x1./c)) ./ (x1./c));
  Gamma = @(x1) gamma(x1).*dx;

  % distance between two points
  radius = @(x, y, x1, y1) sqrt((x-x1).^2+(y-y1).^2);

  % streamline definition for a vortex at (x, y)
  vortex_stream = @(xpos, ypos) Gamma(xpos)./(2*pi)*log(radius(x, y, xpos, ypos));

  % freestream stream function
  stream = V_inf*cos(alpha).*y - V_inf*sin(alpha).*x;

  % superimpose all the vortcies
  % We skip positions x = 0 and x = c because they create singularities
  for i = 1:(N-1)
    x_i = i*dx;
    y_i = 0;
    stream = stream + vortex_stream(x_i, y_i);
  end

  if render_plots
    f = figure;
    hold on;
    % plot the streamlines from the stream function
    nlevels = 50;
    levmin  = min(min(stream));
    levmax  = max(max(stream));
    levels  = linspace(levmin, levmax, nlevels)';
    contour(x, y, stream, levels);

    % plot the thin airfoil
    airfoil_x = linspace(0, c, 50);
    airfoil_y = linspace(0, 0, 50);
    plot(airfoil_x, airfoil_y, 'k');
    title(sprintf('Streamlines, AoA = %.0f degrees, c = %d m, V = %.0f m/s', rad2deg(alpha), c, V_inf));
    xlabel('Distance from leading edge (meters)');
    ylabel('Vertical distance from chord (meters)');
    if save_plots
      filename = sprintf('streamlines_c%d_alpha%.0f_v%d', c, rad2deg(alpha), V_inf);
      print(f, filename, '-dpng');
    end
  end

  %%%%%%%%%%%%%%%%%%%%%% POTENTIAL FLOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  phi        = V_inf.*(cos(alpha).*x + sin(alpha).*y); % freestream potental
  vortex_phi = @(vx, vy, x_i, y_i) -Gamma(vx)./(2*pi).*atan2((vy - y_i), (vx - x_i)); % atan2 does a quadrant check

  for i = 1:N-1
    x_i = i*dx;
    y_i = 0;
    phi = phi + vortex_phi(x_i, y_i, x, y);
  end

  if render_plots
    f = figure;
    hold on;
    % plot potental function
    contour(x, y, phi, levels);
    plot(airfoil_x, airfoil_y, 'k');
    title(sprintf('Potential, AoA = %.0f degrees, c = %d m, V = %.0f m/s', rad2deg(alpha), c, V_inf));
    xlabel('Distance from leading edge (meters)');
    ylabel('Vertical distance from chord (meters)');
    if save_plots
      print(f, sprintf('potential_c%d_alpha%.0f_v%d', c, rad2deg(alpha), V_inf), '-dpng');
    end
  end

  %%%%%%%%%%%%%%%%%%%%%% PRESSURE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  [vy, vx] = gradient(stream);
  vy = -vy;

  % Bernoulli's Law
  P = p_inf + 0.5*rho_inf.*(V_inf.^2 - (vx.^2 + vy.^2));

  if render_plots
    f = figure;
    hold on;

    nlevels = 20;
    levmin  = min(min(P));
    levmax  = max(max(P));
    levels  = linspace(levmin, levmax, nlevels)';

    contourf(x, y, P, levels);
    plot(airfoil_x, airfoil_y, 'k');
    title(sprintf('Pressure, AoA = %.0f degrees, c = %d m, V = %.0f m/s', rad2deg(alpha), c, V_inf));
    xlabel('Distance from leading edge (meters)');
    ylabel('Vertical distance from chord (meters)');
    if save_plots
      print(f, sprintf('pressure_c%d_alpha%.0f_v%d', c, rad2deg(alpha), V_inf), '-dpng');
    end
  end
end
