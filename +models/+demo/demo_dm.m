% --- Creating the simulation environment:
% A simulation environment (sim.Instance) must exist for creation of a network

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
    myTrafficGrid.addIntersection(location, lightFreq, lightStartTime)
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

% This bit continues making a four-way intersection for demonstration purposes

for i =1:1:length(NodeIdConnect)
    pt1 = NIdCon(i,1);
    pt2 = NIdCon(i,2);
    myTrafficGrid.addRoad(myTrafficGrid.intersections{pt1}, myTrafficGrid.intersections{pt2}, speedLimit);
end
% 3: Garage definition
% Garages are start and end points for vehicles. On construction, they will
% find the nearest road element junction and connect to it. Construction is
% as follows:
location.x = 0.1; % Miles
location.y = 0.1; % Miles
maxVehicles = 10;
myTrafficGrid.addGarage(location, maxVehicles);

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
% 
% % This ends construction. A view of the network can be generated:
 myTrafficGrid.plot();
% Intersections are blue circles, garages are blue asterisks, and roads are
% the black directional arrows. 


% To view the traffic lights in action, the simulation can be run and
% animated as follows:
startTime = 0; % seconds. Simulation always starts at 0, but animation can start at any time
endTime = 2; % seconds
simInst.runSim(endTime);
% 
tStep = 1; % Animate a frame every second
myTrafficGrid.animate(startTime, endTime, tStep);
