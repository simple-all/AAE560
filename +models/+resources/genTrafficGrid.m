% --- Creating the simulation environment:
% A simulation environment (sim.Instance) must exist for creation of a network

addpath(genpath('old'));
GetAdjacency_final;

simInst = sim.Instance();

% --- Creating a traffic grid:
% Traffic grid construction is orchestrated by the agents.roads.Network
% class

maxRoadElementLength = 0.1; % Miles
myTrafficGrid = agents.roads.Network(maxRoadElementLength);

% Inputs
% ARG1: Maximum length of road element (miles). When roads are constructed
% between intersections, they are divided into road elements of a maximum
% length. This is so that traffic can be discretized to certain sections of
% a road and exits/entrances can occur at places other than intersections.

% --- Constructing the network:
% Network construction is handled in four phases:
% 1: Intersection definition
% 2: Road definition
% 3: Garage definition
% 4: Intersection setup

% After construction, the traffic grid must be added to the simulation
% instance to allow for further network construction
simInst.addCallee(myTrafficGrid);

% 1: Intersection definition
% Intersections are created by the traffic grid as follows:

lightFreq = 120; % Seconds
lightStartTime = -10; % Seconds (should be <= 0)

for i=1:1:length(AdjScrubed)
    location.x = XYENU(i,1); % Miles
    location.y = XYENU(i,2); % Miles
    myTrafficGrid.addIntersection(location, lightFreq - randi(20), lightStartTime - randi(89))
end

% Inputs
% ARG1: Struct with fields "x" and "y" designating the cartesian location,
% in miles, of the intersection
% ARG2: Frequency that the lights will change, in seconds
% ARG3: Starting time of the light counter, in seconds. Should be less
% than or equal to zero to prevent stale lights at the beginning of the
% simulation


% This bit just makes a four-way intersection for demonstration purposes

% location.x = 0.3;
% location.y = 0.5;
% myTrafficGrid.addIntersection(location, lightFreq, lightStartTime);
% 
% location.x = 0.7;
% location.y = 0.1;
% myTrafficGrid.addIntersection(location, lightFreq, lightStartTime);
% 
% location.x = -0.1;
% location.y = 0.9;
% myTrafficGrid.addIntersection(location, lightFreq, lightStartTime);
% 
% location.x = 0.7;
% location.y = 1.1;
% myTrafficGrid.addIntersection(location, lightFreq, lightStartTime);

% 2: Road definition
% Roads are created by the traffic grid between any two intersections.
% Roads are always single-lane and two-way (such that one lane travels the
% opposite direction of the other), so there is no need to define a road
% between intersections A and B, and then B and A. Construction is handled
% as follows:

speedLimit = 25; % mph
% myTrafficGrid.addRoad(myTrafficGrid.intersections{1}, myTrafficGrid.intersections{2}, speedLimit);

% Inputs
% ARG1: First intersection object. It should be referenced directly from
% the agents.roads.Network object in order to ensure sucessful
% construction. The intersections are added to the intersection list in
% order of construction, such that the 3rd intersection to be added can be
% referenced at "myTrafficGrid.interesction{3}".
% ARG2: Second intersection object
% ARG3: Speed limit of the road (mph)

% Calculate the in and out degree of each intersection from the
% NodeIdConnect list
nodeList = struct();
for i = 1:length(NodeIdConnect)
	from = ['n', num2str(NodeIdConnect(i, 1))];
	to = ['n', num2str(NodeIdConnect(i, 2))];
	if ~any(strcmp(from, fields(nodeList)))
		nodeList.(from) = struct();
		nodeList.(from).in = [];
		nodeList.(from).out = [];
        nodeList.(from).index = NIdCon(i, 1);
	end
	
	if ~any(strcmp(to, fields(nodeList)))
		nodeList.(to) = struct();
		nodeList.(to).in = {};
		nodeList.(to).out = {};
        nodeList.(to).index = NIdCon(i, 2);
	end
	
	nodeList.(from).out{end + 1} = to;
	nodeList.(to).in{end + 1} = from;
end

% Get all nodes that have an in-degree of 1
nodeNames = fields(nodeList);
singleList = {};
for i = 1:numel(nodeNames)
	name = nodeNames{i};
	if (numel(nodeList.(name).in) == 1) && (numel(nodeList.(name).out) == 1)
		singleList{end + 1} = name;
	end
end


% Go through the node list and replace all instances of single in-degree
% nodes with where they go to or come from (depending on direction...

flag = 1;
iter = 1;
while flag
	sprintf('Loop %d\n', iter);
	iter = iter + 1;
	flag = 0;
	for i = 1:numel(nodeNames)
		name = nodeNames{i};
		froms = nodeList.(name).in;
		tos = nodeList.(name).out;
        for j = 1:numel(tos)
            if any(strcmp(tos{j}, singleList))
                nodeList.(name).out{j} = nodeList.(tos{j}).out{:};
                flag = 1;
            end
        end
	end
end

% This bit continues making a four-way intersection for demonstration purposes

for i = 1:numel(nodeNames)
    if ~any(strmatch(nodeNames{i}, singleList));
        % Connect
        name = nodeNames{i};
        from = nodeList.(name).index;
        for j = 1:numel(nodeList.(name).out)
            nameTo = nodeList.(name).out{j};
            to = nodeList.(nameTo).index;
            myTrafficGrid.addRoad(myTrafficGrid.intersections{from}, myTrafficGrid.intersections{to}, speedLimit);
        end
    end
end

% for i =1:1:length(NodeIdConnect)
%     pt1 = NIdCon(i,1);
%     pt2 = NIdCon(i,2);
%     myTrafficGrid.addRoad(myTrafficGrid.intersections{pt1}, myTrafficGrid.intersections{pt2}, speedLimit);
% end
% 3: Garage definition
% Garages are start and end points for vehicles. On construction, they will
% find the nearest road element junction and connect to it. Construction is
% as follows:
% Add garages
x = linspace(-0.07, 0.82, 9);
y = linspace(-0.9, -0.27, 19);

dx = 0.01;
angle = -15;
for i = 1:numel(x)
    for j =1:numel(y)
        k = 1;
        gx = x(i) + (k * dx);
        location.x = cosd(angle) * gx + sind(angle) * y(j);
        location.y = -sind(angle) * gx + cosd(angle) * y(j);
        myTrafficGrid.addGarage(location, 1);
    end
end

x = linspace(-0.07, 0.82, 9);
y = linspace(-0.92, -0.29, 19);

dx = 0.01;
angle = -15;
for i = 1:numel(x)
    for j =1:numel(y)
        k = 1;
        gx = x(i) + (k * dx);
        location.x = cosd(angle) * gx + sind(angle) * y(j);
        location.y = -sind(angle) * gx + cosd(angle) * y(j);
        myTrafficGrid.addGarage(location, 1);
    end
end

% Add garages to exterior roads
x = linspace(-0.35, -0.2, 2);
y = linspace(-0.92, 0, 21);
dx = 0.01;
angle = -15;
for i = 1:numel(x)
    for j =1:numel(y)
        k = 1;
        gx = x(i) + (k * dx);
        location.x = cosd(angle) * gx + sind(angle) * y(j);
        location.y = -sind(angle) * gx + cosd(angle) * y(j);
        myTrafficGrid.addGarage(location, 1);
    end
end
    

locations = [0.2, -1.2;
    0.4, -1.2;
    0.5, -1.1;
    0.6, -1.2;
    0.7, -1.0;
    1.2, -0.8;
    1.2, -0.6;
    1.2, -0.35;
    0.4, -0.1;
    0.3, 0];

for i = 1:size(locations, 1)
    location.x = locations(i, 1);
    location.y = locations(i, 2);
    myTrafficGrid.addGarage(location, 1); 
end

% Inputs
% ARG1: Struct with fields "x" and "y" designating the cartesian location,
% in miles, of the intersection
% ARG2: Maximum number of vehicles the garage can house (non-functioning as
% of now, working on it)


% 4: Intersection initialization
% Intersections are initialized after they have roads connected to them.
% This will start the light timers and determine which roads receive
% signals at the same time based on how similarly the roads are angled in
% the network (such that roads that are nearest straight to each other will
% be pairs).

 for i = 1:numel(myTrafficGrid.intersections)
 	myTrafficGrid.intersections{i}.setup();
 end
myTrafficGrid.plot();
 % End of traffic grid generation. 
 path = mfilename('fullpath');
 path = path(1:(numel(path) - numel(mfilename)));
 save([path, 'baseTrafficGrid'], 'myTrafficGrid');