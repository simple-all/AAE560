classdef Network < agents.base.SimpleAgent;
	%NETWORK Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		roads = {};
		garages = {};
		intersections = {};
		connectors = {};
		maxElementLength;
        
        connectionList;
	end
	
	methods
		
		function obj = Network(maxElementLength)
			obj.maxElementLength = maxElementLength;
            obj.connectionList = struct();
		end
		
		function addGarage(obj, location, numSpaces)
			
			% Get the nearest connector
			connector = obj.findClosestConnector(location);
			allKeys = connector.connectionMap.keys;
            for i = 1:numel(allKeys)
                tos = connector.connectionMap(allKeys{i});
                for j = 1:numel(tos)
                    if isa(tos{j}, 'agents.roads.Garage')
                        return;
                    end
                end
            end
			% Create the garage
			garage = agents.roads.Garage(location, connector, numSpaces);
			obj.garages{end + 1} = garage;
			obj.instance.addCallee(garage);
			garage.connect();
		end
		
		function addIntersection(obj, location, freq, lastTime)
			intersection = agents.roads.Intersection(location, freq, lastTime);
			obj.instance.addCallee(intersection);
			obj.intersections{end + 1} = intersection;
		end
		
		function addRoad(obj, from, to, speedLimit)
            % Make sure we're not doubling up on roads
            fromName = ['n', num2str(from.id)];
            toName = ['n', num2str(to.id)];
            if ~isfield(obj.connectionList, fromName)
                obj.connectionList.(fromName) = {};
            end
            
            if ~isfield(obj.connectionList, toName)
                obj.connectionList.(toName) = {};
            end
            
            if any(strmatch(toName, obj.connectionList.(fromName)))
                disp('Road already exists')
                return;
            end
            
            % Otherwise, road does not exist, make it
			obj.addRoadOneWay(from, to, speedLimit);
			obj.addRoadOneWay(to, from, speedLimit);
            obj.connectionList.(fromName){end + 1} = toName;
            obj.connectionList.(toName){end + 1} = fromName;
		end
		
		function addRoadOneWay(obj, from, to, speedLimit)
			dx = to.location.x - from.location.x;
			dy = to.location.y - from.location.y;
			gx = 0.0025;
			angle = atan2(dy, dx);
			distance = norm([dx, dy]);
			numElements = ceil(distance / obj.maxElementLength);
			
			% Create connectors 
			connectors{1} = from;
			for i = 1:(numElements + 1)
				if (i == 1)
					location.x = from.location.x + (dx * 0.01);
					location.y = from.location.y + (dy * 0.01);
				elseif (i == (numElements + 1))
					location.x = from.location.x + (dx * 0.99);
					location.y = from.location.y + (dy * 0.99);
				else
					location.x = from.location.x + (dx * (i - 1) / numElements);
					location.y = from.location.y + (dy * (i - 1) / numElements);
				end
				location.x = location.x + sin(angle) * gx;% + sin(angle) * gx;
				location.y = location.y - cos(angle) * gx;% + cos(angle) * gx;
				
				connectors{i + 1} = agents.roads.Connector(location);
				obj.connectors{end + 1} = connectors{end};
			end

			connectors{end + 1} = to;
			
			lastRoad1 = [];
			
			for i = 1:(numElements + 2)
				connector1 = connectors{i};
				connector2 = connectors{i + 1};
				
				% Connect roads
				road1 = agents.roads.RoadElement(connector1, connector2, speedLimit, angle);
				obj.instance.addCallee(road1);
				
				% Make sure connectors are linked
				
				% Handle intersections
				switch class(connector1)
					case 'agents.roads.Intersection'
						connector1.addConnection(road1);
					case 'agents.roads.Connector'
						if ~isempty(lastRoad1)
							connectors{i}.addConnection(lastRoad1, road1);
						end
				end
				
				if isa(connector2, 'agents.roads.Intersection')
					connector2.addConnection(road1);
				end


				lastRoad1 = road1;
				
				% Add roads
				obj.roads{end + 1} = road1;
			end
			
		end
		
		function [pathIdList, cost] = findPath(obj, from, to, showPlot, varargin)
			if (nargin < 4)
				showPlot = 0;
			end
			% Djikstra algorithm for finding the shortest path between two
			% connectors
			if showPlot
				figure;
				hold on;
				from.plot('g');
				to.plot('r');
				axis equal;
			end
			q = util.PQ2(1);
			path = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
			visitedList = [];
			
			% Reset all costs
			for i = 1:numel(obj.roads)
				obj.roads{i}.cost = inf;
			end
			
			for i = 1:numel(obj.intersections);
				obj.intersections{i}.cost = inf;
			end
			
			currAgent = from; % Starting point
			currAgent.cost = 0;
			while (currAgent.id ~= to.id)
				visitedList(end + 1) = currAgent.id;
				if showPlot && (from.id ~= currAgent.id)
					currAgent.plot();
					drawnow();
				end
				% Push connections to the stack with their cost
				switch class(currAgent)
					case 'agents.roads.RoadElement'
						nextList = currAgent.to.getConnections(currAgent);
					case 'agents.roads.Intersection'
						nextList = currAgent.getConnections();
					case 'agents.roads.Garage'
						nextList = currAgent.connector.getConnections(currAgent);
				end
				
				for i = 1:numel(nextList)
					next = nextList{i};

					
					% Allow next destinations be either roads or
					% destination
					switch class(next)
						case 'agents.roads.RoadElement'
							costMod = 0;
							if isa(currAgent, 'agents.roads.RoadElement')
								dx = currAgent.to.location.x - currAgent.from.location.x;
								dy = currAgent.to.location.y - currAgent.from.location.y;
								currVect = [dx, dy];
								
								dx = next.to.location.x - next.from.location.x;
								dy = next.to.location.y - next.from.location.y;
								nextVect = [dx, dy];
								if all(currVect == -nextVect)
									costMod = 1;
								end
							end
							
							possibleCost = currAgent.cost + (next.getLength() / next.speedLimit) + costMod; % Time to traverse, need to integrate traffic level
							if (possibleCost < next.cost)
								next.cost = possibleCost; % Only set new cost if it is lower
								path(next.id) = currAgent.id;
							end
							
							% Only add if not visited
							if ~any(visitedList == next.id);
								q.push(next, next.cost);
							end
						otherwise
							path(next.id) = currAgent.id;
							next.cost = currAgent.cost;
							if ~any(visitedList == next.id);
								q.push(next, next.cost);
							end
					end
					
				end
				cost = currAgent.cost;
				% Select the next element and push the current agent to the
				% path stack
				flag = true;
				while flag
					currAgent = q.pop();
					flag = any(visitedList == currAgent.id);
				end
			end
			
			% Return the id list of the path
			pathIdList = to.id;
			pathIdList(end + 1) = path(to.id);
			while (pathIdList(end) ~= from.id)
				pathIdList(end + 1) = path(pathIdList(end));
			end
			pathIdList = flip(pathIdList);
        end
        
        function [pathIdList, cost] = findPathDensity(obj, from, to, showPlot, networkId)
			if (nargin < 4)
				showPlot = 0;
			end
			% Djikstra algorithm for finding the shortest path between two
			% connectors
			if showPlot
				figure;
				hold on;
				from.plot('g');
				to.plot('r');
				axis equal;
			end
			q = util.PQ2(1);
			path = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
			visitedList = [];
			
			% Reset all costs
			for i = 1:numel(obj.roads)
				obj.roads{i}.cost = inf;
			end
			
			for i = 1:numel(obj.intersections);
				obj.intersections{i}.cost = inf;
			end
			
			currAgent = from; % Starting point
			currAgent.cost = 0;
			while (currAgent.id ~= to.id)
				visitedList(end + 1) = currAgent.id;
				if showPlot && (from.id ~= currAgent.id)
					currAgent.plot();
					drawnow();
				end
				% Push connections to the stack with their cost
				switch class(currAgent)
					case 'agents.roads.RoadElement'
						nextList = currAgent.to.getConnections(currAgent);
					case 'agents.roads.Intersection'
						nextList = currAgent.getConnections();
					case 'agents.roads.Garage'
						nextList = currAgent.connector.getConnections(currAgent);
				end
				
				for i = 1:numel(nextList)
					next = nextList{i};

					
					% Allow next destinations be either roads or
					% destination
					switch class(next)
						case 'agents.roads.RoadElement'
							costMod = 0;
							if isa(currAgent, 'agents.roads.RoadElement')
                                dx = currAgent.to.location.x - currAgent.from.location.x;
                                dy = currAgent.to.location.y - currAgent.from.location.y;
                                currVect = [dx, dy];
                                
                                dx = next.to.location.x - next.from.location.x;
                                dy = next.to.location.y - next.from.location.y;
                                nextVect = [dx, dy];
                                if all(currVect == -nextVect)
                                    costMod = 1; % Making u-turn, 1 second debit
                                end
                                
                                % Look at all cars sharing the same network ID
                                % to get this network's road density
                                numCars = 0;
                                for j = 1:numel(currAgent.vehicles)
                                    vehicle = obj.instance.getCallee(currAgent.vehicles(j));
                                    if (vehicle.networkId == networkId)
                                        numCars = numCars + 1;
                                    end
                                end
                                % Artificially limit the number of counted cars to 10
                                numCars = min(10, numCars);
                                costMod = costMod + (numCars * 5); % Assume each car is 5 seconds extra travel time
                            end
                            
                            
							possibleCost = currAgent.cost + (next.getLength() / next.speedLimit) + costMod; % Time to traverse, in seconds
							if (possibleCost < next.cost)
								next.cost = possibleCost; % Only set new cost if it is lower
								path(next.id) = currAgent.id;
							end
							
							% Only add if not visited
							if ~any(visitedList == next.id);
								q.push(next, next.cost);
							end
						otherwise
							path(next.id) = currAgent.id;
							next.cost = currAgent.cost;
							if ~any(visitedList == next.id);
								q.push(next, next.cost);
							end
					end
					
				end
				cost = currAgent.cost;
				% Select the next element and push the current agent to the
				% path stack
				flag = true;
				while flag
					currAgent = q.pop();
					flag = any(visitedList == currAgent.id);
				end
			end
			
			% Return the id list of the path
			pathIdList = to.id;
			%pathIdList(end + 1) = path(to.id);
			while (pathIdList(end) ~= from.id) && (numel(pathIdList) <= (numel(obj.roads) * 2))
				pathIdList(end + 1) = path(pathIdList(end));
			end
			pathIdList = flip(pathIdList);
		end
		
		function plotPath(obj, pathIdList, figHandle)
			figure(figHandle);
			for i = 1:numel(pathIdList)
				agent = obj.instance.getCallee(pathIdList(i));
				handle = agent.plot('r');
				set(handle, 'LineWidth', 2);
			end
		end
		
		function connector = findClosestConnector(obj, location)
			minDist = inf;
			connector = [];
			
			for i = 1:numel(obj.connectors)
				dx = obj.connectors{i}.location.x - location.x;
				dy = obj.connectors{i}.location.y - location.y;
				dist = norm([dx, dy]);
				if (dist < minDist)
					connector = obj.connectors{i};
					minDist = dist;
				end
			end
		end
		
		function figHandle = plot(obj)
			
			figHandle = figure;
			axis equal;
			hold on;
			for i = 1:numel(obj.roads)
				obj.roads{i}.plot();
			end
			
			for i = 1:numel(obj.intersections)
				handle = obj.intersections{i}.plot('b');
				set(handle, 'MarkerSize', 5);
			end
			
			for i = 1:numel(obj.garages)
				obj.garages{i}.plot('b');
			end
			
			set(gca, 'Color', [0.7 0.7 0.7])
		end
		
		function [mov] = animate(obj, startTime, endTime, dt)
			% Animate the traffic over the grid
			figHandle = obj.plot; 
            pos = figHandle.Position .* [0 0 2 2];
            set(figHandle, 'Position', pos);
			%figure;
			hold on;
			
			mov = struct('cdata',[],'colormap',[]);
			iter = 0;
			
			time = startTime;
			% Get all vehicle instances
			vehicles = obj.instance.getAllCalleesOfType('agents.vehicles.Vehicle');
			while (time <= endTime)
				iter = iter + 1;
				disp(time);
				% Plot all vehicles at current time
				handles = {};
				for i = 1:numel(vehicles)
					if (vehicles{i}.startTime <= time)
						tempH = vehicles{i}.plotAtTime(time);
						if ~isempty(tempH)
							handles{end + 1} = tempH; %#ok
						end
					end
				end
				
				% Plot all intersection at current time
				intHandles = {};
				for i = 1:numel(obj.intersections)
					newHandles = obj.intersections{i}.plotAtTime(time);
					intHandles = {intHandles{:} newHandles{:}};
				end
				
				mov(iter) = getframe;
				
				for i = 1:numel(handles)
					delete(handles{i});
				end
				
				for i = 1:numel(intHandles)
					delete(intHandles{i});
				end
				
				time = time + dt;
			end
			
        end
        
        function [mov] = animateDensity(obj, startTime, endTime, dt)
			% Animate the traffic over the grid
			figHandle = figure(); %obj.plot; 
            figHandle.Position = [0 0 1120 840];
            set(gca, 'Color', [0.7 0.7 0.7])
            axis equal;
			%figure;
			hold on;
			
			mov = struct('cdata',[],'colormap',[]);
			iter = 0;
			
			time = startTime;
			% Find the maximum density of all road instances
            maxDensity = 0;
            for i = 1:numel(obj.roads)
                obj.roads{i}.myHandle = [];
                if (obj.roads{i}.getLength > 0.0105)
                    maxDensity = max(maxDensity, max(obj.roads{i}.densityHistory));
                end
            end
			while (time <= endTime)
				iter = iter + 1;
				disp(time);
				% Plot all roads at current time
				handles = {};
				for i = 1:numel(obj.roads)
					handles{end + 1} = obj.roads{i}.plotAtTime(time, maxDensity);
                end
				
				mov(iter) = getframe;
				
				time = time + dt;
			end
			
		end
		
	end
	
end

