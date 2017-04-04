classdef Vehicle < agents.base.SimpleAgent & agents.base.Periodic
	%VEHICLE Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		maxSpeed;
		
		runPeriod = 0.1;
		
		% Pathing
		path;  % List of agent ids in travel path
		currIndex; % Current index in path
		progress; % Decimal of progress on current road element (if on a road element)
		location; % Only used for logging purposes
		trueSpeed = 0;
		movementLastUpdateTime;
		traffic = 0;
		startTime;
		
		% Logging
		locationHistory = [];
		speedHistory = [];
		trafficHistory = []; % Travel speed divided by speed limit
		timeHistory = [];
	end
	
	properties (Access = private)
		lastRoad;
		cMap;
	end
	
	methods
		function obj = Vehicle(maxSpeed, startTime)
			obj.maxSpeed = maxSpeed / 60 / 60; % Miles per second
			obj.setTimeStep(obj.runPeriod);
			obj.startTime = startTime;
			obj.movementLastUpdateTime = startTime;
			
			cVals = [1 0 0; 1 1 0; 0 1 0];
			c_HSV = rgb2hsv(cVals);
			nColors = 50;
			c_HSV_interp = interp1([0, nColors / 2, nColors], c_HSV(:, 1), 1:nColors);
			c_HSV = [c_HSV_interp', repmat(c_HSV(1, 2:3), nColors, 1)];
			obj.cMap = hsv2rgb(c_HSV);
		end
		
		function init(obj)
			obj.instance.scheduleAtTime(obj, obj.startTime);
		end
		
		function setPath(obj, path)
			obj.path = path;
			obj.currIndex = 1;
			obj.progress = 0;
			startingAgent = obj.instance.getCallee(obj.path(1));
			obj.location = startingAgent.location;
		end
		
		function runAtTime(obj, time)
			if obj.isRunTime(time)
				tDiff = time - obj.movementLastUpdateTime;
				tMoved = 0;
				obj.movementLastUpdateTime = time;
				
				
				% Get the current agent that we're driving on
				while (tMoved < tDiff)
					% Propogate through that path until moved
					% sufficiently
					% If at the end of the path, don't move
					if (obj.currIndex == numel(obj.path))
						obj.setTimeStep(inf);
						fprintf('Vehicle %d finished at time %0.1f, Commute Time = %0.1f \n', obj.id, time, time - obj.startTime);
						break;
					end
					currAgent = obj.instance.getCallee(obj.path(obj.currIndex));
					
					switch class(currAgent)
						case 'agents.roads.RoadElement'
							% Check if an intersection is up ahead
							flag = 0;
							if isa(currAgent.to, 'agents.roads.Intersection')
								if ~currAgent.to.getLight(currAgent);
									% Get distance to light
									dx = currAgent.to.location.x - obj.location.x;
									dy = currAgent.to.location.y - obj.location.y;
									dist = norm([dx, dy]);
									intSpeed = min(dist / 3, currAgent.speedLimit);
									flag = 1;
								end
							end
							
							% Check for traffic ahead on road
							nextVehicle = currAgent.getVehicleAhead(obj, 1);
							if isempty(nextVehicle)
								% Check next road just in case
								nextRoad = obj.instance.getCallee(obj.path(obj.currIndex + 1));
								if isa(nextRoad, 'agents.roads.RoadElement')
									nextVehicle = nextRoad.getVehicleAhead(obj, 0);
								end
							end
							
							if ~isempty(nextVehicle)
								% Max sure to stay 3 seconds behind the
								% next vehicle or 15 ft behind (if slow
								% moving and b/c all vehicles are just
								% points)
								
								% Get distance to next vehicle
								dx = nextVehicle.location.x - obj.location.x;
								dy = nextVehicle.location.y - obj.location.y;
								dist = norm([dx, dy]);
								
								if (dist > (15 / 5280))
									% Get possible max speed
									speed = min(obj.maxSpeed, currAgent.speedLimit);
									
									% Get time to next vehicle's location
									timeToNext = dist / speed;
									if (timeToNext < 5)
										% Adjust speed to make it 5 seconds
										% to next vehicle's position
										speed = dist / 5;
									end
								else
									% Stop for now...may have to change
									% later
									speed = 0;
									tMoved = tDiff;
								end
								
							else
								% Move along the road at normal pace
								speed = min(obj.maxSpeed, currAgent.speedLimit);
							end
							
							if  (flag)
								speed = min(intSpeed, speed);
							end
							
							obj.trueSpeed = speed;
							obj.traffic = speed / currAgent.speedLimit;
							
							if (speed ~= 0)
								tLeft = (currAgent.getLength() * (1 - obj.progress)) / speed;
								
								if (tLeft < (tDiff - tMoved))
									tMoved = tMoved + tLeft;
									obj.progress = 0;
									obj.currIndex = obj.currIndex + 1;
								else
									tTotal = currAgent.getLength() / speed;
									obj.progress = obj.progress + (tDiff - tMoved) / tTotal;
									tMoved = tMoved + tDiff;
								end
							else
								% Stopped
								tMoved = tDiff;
							end
						case 'agents.roads.Garage'
							% At Exit the garage (assume it takes no time
							% for now)
							obj.currIndex = obj.currIndex + 1;
					end
					
					
				end
				
				currAgent = obj.instance.getCallee(obj.path(obj.currIndex));
				switch class(currAgent)
					case 'agents.roads.RoadElement'
						xStart = currAgent.from.location.x;
						yStart = currAgent.from.location.y;
						xEnd = currAgent.to.location.x;
						yEnd = currAgent.to.location.y;
						obj.location.x = interp1([0, 1], [xStart, xEnd], obj.progress);
						obj.location.y = interp1([0, 1], [yStart, yEnd], obj.progress);
						
						currAgent.addVehicle(obj);
						if ~isempty(obj.lastRoad) && (obj.lastRoad.id ~= currAgent.id)
							obj.lastRoad.removeVehicle(obj);
						end
						obj.lastRoad = currAgent;
					case 'agents.roads.Garage'
						% At Exit the garage (assume it takes no time
						% for now)
						obj.location = currAgent.location;
						if ~isempty(obj.lastRoad)
							obj.lastRoad.removeVehicle(obj);
						end
				end
				
				obj.log(time);
			end
		end
		
		function log(obj, time)
			obj.timeHistory(end + 1) = time;
			obj.locationHistory(end + 1, :) = [obj.location.x, obj.location.y];
			obj.speedHistory(end + 1) = obj.trueSpeed;
			obj.trafficHistory(end + 1) = obj.traffic;
		end
		
		function plot(obj, color)
			if nargin == 1
				color = 'b';
			end
			spec = [color];
			
			colormap(obj.cMap);
			plot(obj.locationHistory(:, 1), obj.locationHistory(:, 2), spec, 'LineWidth', 1);
			scatter(obj.locationHistory(:, 1), obj.locationHistory(:, 2), 3, obj.trafficHistory);
			
		end
		
		function handle = plotAtTime(obj, time)
			
			
			index = find(obj.timeHistory >= time, 1, 'first');
			if ~isempty(index)
				color = interp1(linspace(0, 1, size(obj.cMap, 1)), obj.cMap, obj.trafficHistory(index), 'nearest');
				spec = ['o'];
				handle = plot(obj.locationHistory(index, 1), obj.locationHistory(index, 2), spec, 'Color', color, 'MarkerSize', 2, 'MarkerFaceColor', color);
			else
				handle = [];
			end
		end
		
		
	end
	
end

