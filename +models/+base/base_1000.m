function expNum = base_1000(logPath, expNum)

% Set the random seed
rng(expNum);

% Load the traffic grid
trafficGrid = load('+models/+resources/baseTrafficGrid.mat');
trafficGrid = trafficGrid.myTrafficGrid;

% Retreive the simulation instance
simInst = trafficGrid.instance;

% Define start and end time
endTime = 60 * 60; % 1 hour of sim time

% Add vehicles just to start

allVehicles = {};
for i = 1:1000
    fprintf('Adding vehicle %0.0f\n', i);
	maxSpeed = 80;
	startTime = randi(60 * 20); % Allow vehicles to spawn in between 0 and 20 minutes into the simulation
	% Make a bunch of vehicles and start them up
	startPoint = randi(numel(trafficGrid.garages));
	endPoint = startPoint;
	
	while (endPoint == startPoint)
		endPoint = randi(numel(trafficGrid.garages));
	end
	
	[path, cost] = trafficGrid.findPath(trafficGrid.garages{startPoint}, trafficGrid.garages{endPoint}, 0);
	vehicle = agents.vehicles.Vehicle(maxSpeed, startTime);
	simInst.addCallee(vehicle);
	vehicle.setPath(path, cost);
	allVehicles{end + 1} = vehicle;
end


simInst.runSim(endTime); % Simulate

% Save workspace
path = mfilename('fullpath');
path = path(1:(numel(path) - numel(mfilename)));
save([path, 'results-', num2str(expNum)]);

% Animate the scenario, save to movie
mov = trafficGrid.animate(0, endTime, 1);
clearvars -except mov expNum path startTime endTime trafficGrid
vid = VideoWriter([path, 'results-', num2str(expNum), '.mp4'], 'MPEG-4');
vid.Quality = 100;
vid.FrameRate = 30;
open(vid);
writeVideo(vid, mov);
close(vid);

% Animate the scenario density, save to movie
clearvars -except expNum path startTime endTime trafficGrid
mov = trafficGrid.animateDensity(0, endTime, 1);
vid = VideoWriter([path, 'results-density-', num2str(expNum), '.mp4'], 'MPEG-4');
vid.Quality = 100;
vid.FrameRate = 30;
open(vid);
writeVideo(vid, mov);
close(vid);
end
