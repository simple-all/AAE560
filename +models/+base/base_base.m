function data = base_separate_density(logPath, numCars, expNum)

% Set the random seed
rng(expNum);

% Load the traffic grid
trafficGrid = load('+models/+resources/baseTrafficGrid.mat');
trafficGrid = trafficGrid.myTrafficGrid;

% Retreive the simulation instance
simInst = trafficGrid.instance;

% Define start and end time
endTime = 60 * 60; % 1 hour of sim time

% Add vehicles in 3 different networks(2 on density, 1 on shortest route),
% split cars equally
func1 = @(a, b, c, d) trafficGrid.findPath(a, b, c, d);
net1 = agents.vehicles.VehicleGenerator(0, 20 * 60, numCars, func1, 1, trafficGrid); % shortest route
simInst.addCallee(net1);

simInst.runSim(endTime); % Simulate

data.trafficGrid = trafficGrid;
data.name = [num2str(numCars), '-', num2str(expNum)];
end
