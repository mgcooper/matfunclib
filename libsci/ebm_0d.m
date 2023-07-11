% Zero-dimensional energy balance model of Earth's climate
% Demonstrating the concept of ice-albedo feedback

% Constants
sigma = 5.67e-8; % Stefan-Boltzmann constant (W/m^2/K^4)
S0 = 1361; % Solar constant (W/m^2)
alpha_ice_free = 0.3; % Planetary albedo without ice cover
alpha_ice_covered = 0.6; % Planetary albedo with ice cover
epsilon = 1; % Emissivity of Earth

% Parameters
T_init = 280; % Initial temperature (K)
T_ice_threshold = 273; % Threshold temperature for ice cover (K)
time_step = 0.1; % Time step for the model (years)
total_time = 100; % Total time for the model to run (years)

% Initialize model variables
T = T_init;
time = 0;

% Run the energy balance model
while time < total_time
    % Calculate albedo based on ice cover
    if T < T_ice_threshold
        alpha = alpha_ice_covered;
    else
        alpha = alpha_ice_free;
    end

    % Calculate net incoming solar radiation
    Qin = S0 * (1 - alpha) / 4;

    % Calculate outgoing longwave radiation
    Qout = epsilon * sigma * T^4;

    % Update temperature based on energy balance
    dT = (Qin - Qout) * time_step;
    T = T + dT;

    % Update time
    time = time + time_step;
end

% Display final temperature
disp(['Final temperature: ', num2str(T), ' K']);
