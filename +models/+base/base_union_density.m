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

% Add vehicles in 2 different networks(1 on density, 1 on shortest route),
% split cars equally
numEach = floor(numCars / 3);
func1 = @(a, b, c, d) trafficGrid.findPath(a, b, c, d);
net1 = agents.vehicles.VehicleGenerator(0, 20 * 60, numEach, func1, 1, trafficGrid); % shortest route
simInst.addCallee(net1);

numLeft = numCars - (1 * numEach);
func2 = @(a, b, c, d) trafficGrid.findPathDensity(a, b, c, d);
net2 = agents.vehicles.VehicleGenerator(0, 20 * 60, numLeft, func2, 2, trafficGrid); % Density 1
simInst.addCallee(net2);

simInst.runSim(endTime); % Simulate

% Save workspace
% path = mfilename('fullpath');
% path = path(1:(numel(path) - numel(mfilename)));
% disp(path);
% save([path, 'results-', num2str(expNum)]);

% Animate the scenario, save to movie
% data.mov1 = trafficGrid.animate(0, endTime, 1);
% clearvars -except mov expNum path startTime endTime trafficGrid
% vid = VideoWriter([path, 'results-', num2str(expNum), '.mp4'], 'MPEG-4');
% vid.Quality = 100;
% vid.FrameRate = 30;
% open(vid);
% writeVideo(vid, mov);
% close(vid);

% Animate the scenario density, save to movie
%clearvars -except expNum path startTime endTime trafficGrid
% data.mov2 = trafficGrid.animateDensity(0, endTime, 1);
% vid = VideoWriter([path, 'results-density-', num2str(expNum), '.mp4'], 'MPEG-4');
% vid.Quality = 100;
% vid.FrameRate = 30;
% open(vid);
% writeVideo(vid, mov);
% close(vid);

data.trafficGrid = trafficGrid;
data.name = [num2str(numCars), '-', num2str(expNum)];
end
