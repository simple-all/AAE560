% Creates a simple model

simInst = sim.Instance();

close all;

x = 1:5;
y = 1:5;

[X, Y] = meshgrid(x, y);

trafficGrid = agents.roads.Network(0.1);
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

trafficGrid.plot();


