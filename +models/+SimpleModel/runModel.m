% Creates a simple model

clear;
close all;

%usage_example;
%GetAdjacency_final;

simInst = sim.Instance();
endTime = 30 * 60; % 5 minutes


angle = 10;
x = 0:0.25:1;
y = 0:0.25:1;

[X, Y] = meshgrid(x, y);
X = cosd(angle) * X + sind(angle) * Y;
Y = -sind(angle) * X + cosd(angle) * Y;
%X = xycartENU(:,1);
%Y = xycartENU(:,2);
trafficGrid = agents.roads.Network(0.2);
simInst.addCallee(trafficGrid);

rng(0); % Set random seed

for i = 1:numel(X)
	
	location.x = X(i);
	location.y = Y(i);
	%if any(i == randi(numel(X), 1, numel(X)))
		%location.x = location.x + (rand() - 0.5) * 0.1;
		%location.y = location.y + (rand() - 0.5) * 0.1;
	%end
	trafficGrid.addIntersection(location, randi(30) + 105, -randi(110));
end

for i = 1:(numel(X) - numel(x))
	trafficGrid.addRoad(trafficGrid.intersections{i}, trafficGrid.intersections{i + numel(x)}, randi(10) + 30);
end

for i = 1:numel(Y)
	if (mod(i, numel(y)) == 0)
		continue;
	end
	trafficGrid.addRoad(trafficGrid.intersections{i}, trafficGrid.intersections{i + 1}, randi(10) + 60)
end

% Add garages
x = linspace(0, 1, 9);
y = linspace(-0.1, 1.1, 9);

dx = 0.01;
for i = 1:numel(x)
	for j =1:numel(y)
		%for k = -1:2:1
		k = 1;
			gx = x(i) + (k * dx);
			location.x = cosd(angle) * gx + sind(angle) * y(j);
			location.y = -sind(angle) * gx + cosd(angle) * y(j);
			trafficGrid.addGarage(location, 1);
		%end
	end
end

x = linspace(-0.1, 1.1, 9);
y = linspace(0, 1, 9);

dy = 0.01;
for i = 1:numel(x)
	for j =1:numel(y)
		%for k = -1:2:1
		k = 1;
			gy = y(j) + (k * dy);
			location.x = cosd(angle) * x(i) + sind(angle) * gy;
			location.y = -sind(angle) * x(i) + cosd(angle) * gy;
			trafficGrid.addGarage(location, 1);
		%end
	end
end


for i = 1:numel(trafficGrid.intersections)
	trafficGrid.intersections{i}.setup;
end


% Add a whole bunch of cars
allVehicles = {};
for i = 1:10
	maxSpeed = 80;
	startTime = randi(60 * 1);
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

simInst.runSim(endTime);

%mov = trafficGrid.animate(0, endTime, 1);


averageSpeeds = [];
travelTimes = [];
for i = 1:numel(allVehicles)
	averageSpeeds(end + 1) = mean(allVehicles{i}.speedHistory);
	travelTimes(end + 1) = allVehicles{i}.travelTime;
end

bufferIndex = [];
for i = 1:numel(allVehicles)
	bufferIndex(end + 1) = (0.95 * allVehicles{i}.travelTime - mean(travelTimes)) / mean(travelTimes);
end

