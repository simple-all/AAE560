% Creates a simple model

simInst = sim.Instance();

close all;
angle = 10;
x = 0:4;
y = 0:4;

[X, Y] = meshgrid(x, y);
X = cosd(angle) * X + sind(angle) * Y;
Y = -sind(angle) * X + cosd(angle) * Y;

trafficGrid = agents.roads.Network(0.25);
simInst.addCallee(trafficGrid);

for i = 1:numel(X)
	location.x = X(i);
	location.y = Y(i);
	trafficGrid.addIntersection(location);
end

for i = 1:(numel(X) - numel(x))
	trafficGrid.addRoad(trafficGrid.intersections{i}, trafficGrid.intersections{i + numel(x)});
end

for i = 1:numel(Y)
	if (mod(i, numel(y)) == 0)
		continue;
	end
	trafficGrid.addRoad(trafficGrid.intersections{i}, trafficGrid.intersections{i + 1})
end

% Add garages
x = linspace(0, 4, 10);
y = linspace(0.5, 3.5, 9);

dx = 0.1;
for i = 1:numel(x)
	for j =1:numel(y)
		for k = -1:2:1
			gx = x(i) + (k * dx);
			location.x = cosd(angle) * gx + sind(angle) * y(j);
			location.y = -sind(angle) * gx + cosd(angle) * y(j);
			trafficGrid.addGarage(location, 1);
		end
	end
end

x = linspace(0.5, 3.5, 9);
y = linspace(0, 4, 10);

dy = 0.1;
for i = 1:numel(x)
	for j =1:numel(y)
		for k = -1:2:1
			gy = y(j) + (k * dy);
			location.x = cosd(angle) * x(i) + sind(angle) * gy;
			location.y = -sind(angle) * x(i) + cosd(angle) * gy;
			trafficGrid.addGarage(location, 1);
		end
	end
end

simInst.runSim();

[path, cost] = trafficGrid.findPath(trafficGrid.garages{1}, trafficGrid.garages{end - 3}, 1);
disp('Plotting');
fig = trafficGrid.plot();
hold on;
trafficGrid.plotPath(path, fig);


