% Creates a simple model

clear;
close all;

simInst = sim.Instance();
endTime = 20 * 60; % 30 minutes


angle = 10;
x = 0:4;
y = 0:4;

[X, Y] = meshgrid(x, y);
X = cosd(angle) * X + sind(angle) * Y;
Y = -sind(angle) * X + cosd(angle) * Y;

trafficGrid = agents.roads.Network(0.25);
simInst.addCallee(trafficGrid);

rng(0); % Set random seed

for i = 1:numel(X)
	
	location.x = X(i);
	location.y = Y(i);
	if any(i == randi(numel(X), 1, numel(X)))
		location.x = location.x + (rand() - 0.5) * 0.8;
		location.y = location.y + (rand() - 0.5) * 0.8;
	end
	trafficGrid.addIntersection(location);
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
x = linspace(0, 4, 9);
y = linspace(0.5, 3.5, 9);

dx = 0.1;
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

x = linspace(0.5, 3.5, 9);
y = linspace(0, 4, 9);

dy = 0.1;
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


% Make a bunch of vehicles and start them up
for i = 1:500
	maxSpeed = randi(40) + 10;
	startTime = randi(2 * 60);
	startPoint = randi(numel(trafficGrid.garages));
	endPoint = startPoint;
	while (endPoint == startPoint)
		endPoint = randi(numel(trafficGrid.garages));
	end
	[path, ~] = trafficGrid.findPath(trafficGrid.garages{startPoint}, trafficGrid.garages{endPoint}, 0);
	vehicle = agents.vehicles.Vehicle(maxSpeed, startTime);
	simInst.addCallee(vehicle);
	vehicle.setPath(path);
end

% % Make a normal test vehicle
% vehicle = agents.vehicles.Vehicle(80, 0);
% simInst.addCallee(vehicle);
% vehicle.setPath(path);
% 
% % Make a slow test vehicle
% vehicle1 = agents.vehicles.Vehicle(20, 5);
% simInst.addCallee(vehicle1);
% vehicle1.setPath(path);
% 
% % Make a follower vehicle that can go faster, starts 5 seconds later
% vehicle2 = agents.vehicles.Vehicle(80, 120);
% simInst.addCallee(vehicle2);
% vehicle2.setPath(path);
% 
% vehicle3 = agents.vehicles.Vehicle(80, 125);
% simInst.addCallee(vehicle3);
% vehicle3.setPath(path);


simInst.runSim(endTime);

mov = trafficGrid.animate(0, endTime, 1);

% fig = trafficGrid.plot();
% vehicle.plot();
% title('Normal Vehicle (Ahead of traffic)');
% 
% fig = trafficGrid.plot();
% vehicle1.plot();
% title('Slow Vehicle');
% 
% fig = trafficGrid.plot();
% vehicle2.plot();
% title('Normal Vehicle 1');
% 
% fig = trafficGrid.plot();
% vehicle2.plot();
% title('Normal Vehicle 2');
% 
% % Plot vehicle speeds
% xLims = [0 800];
% yLims = [0 100];
% figure;
% hold on;
% subplot(4, 1, 1);
% plot(vehicle.timeHistory, vehicle.speedHistory * 60 * 60)
% xlim(xLims);
% ylim(yLims);
% title('Normal Vehicle (Ahead of traffic)');
% xlabel('Time (s)');
% ylabel('Speed (mph)');
% subplot(4, 1, 2);
% plot(vehicle1.timeHistory, vehicle1.speedHistory * 60 * 60)
% xlim(xLims);
% ylim(yLims);
% title('Slow Vehicle');
% xlabel('Time (s)');
% ylabel('Speed (mph)');
% subplot(4, 1, 3);
% plot(vehicle2.timeHistory, vehicle2.speedHistory * 60 * 60)
% xlim(xLims);
% ylim(yLims);
% title('Normal Vehicle 1');
% xlabel('Time (s)');
% ylabel('Speed (mph)');
% subplot(4, 1, 4);
% plot(vehicle3.timeHistory, vehicle3.speedHistory * 60 * 60)
% xlim(xLims);
% ylim(yLims);
% title('Normal Vehicle 2');
% xlabel('Time (s)');
% ylabel('Speed (mph)');

%[path, cost] = trafficGrid.findPath(trafficGrid.garages{1}, trafficGrid.garages{end - 2}, 0);
% disp('Plotting');
% fig = trafficGrid.plot();
% hold on;
% trafficGrid.plotPath(path, fig);


