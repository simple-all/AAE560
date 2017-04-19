classdef Intersection < agents.roads.Connector & agents.base.Periodic;
	%INTERSECTION Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		intersectionMap;
		lightMap;
		freq;
		allGreen = 0;
		lastTime;
		
		lightHistory = [];
		timeHistory = [];
	end
	
	methods
		
		function obj = Intersection(location, freq, lastTime)
			% Super init
			obj = obj@agents.roads.Connector(location);
			obj.freq = freq;
			obj.lastTime = lastTime;
			obj.setLastRunTime(lastTime);
		end
		
		function init(obj)
			obj.setTimeStep(obj.freq)
			obj.instance.scheduleAtTime(obj, obj.lastTime + obj.freq);
		end
		
		function setup(obj)
			
			possibleKeys = obj.connectionMap.keys;
			allKeys = {};
			for i = 1:numel(possibleKeys)
				agent = obj.instance.getCallee(possibleKeys{i});
				if (agent.to.id == obj.id)
					allKeys{end + 1} = agent.id;
				end
			end
			
			switch numel(allKeys);
				case 3
					% Find which roads are the most aligned
					%allKeys = obj.connectionMap.keys;
					% First, get all road agents
					for i = 1:numel(allKeys)
						roads(i) = struct('angleDiffs', [], 'angle', []);
						agent = obj.instance.getCallee(allKeys{i});
						roads(i).angle = agent.overallAngle;
						while(roads(i).angle < 0)
							roads(i).angle = roads(i).angle + 2 * pi;
						end
					end
					
					% Find relative angles to other roads
					for i = 1:numel(allKeys)
						for j = 1:numel(allKeys)
							if (j ~= i)
								roads(i).angleDiff(j) = abs(abs(diff([roads(j).angle, roads(i).angle])) - pi);
							else
								roads(i).angleDiff(j) = inf;
							end
						end
					end
					
					% Create the intersection map
					obj.intersectionMap = zeros(2, 2);
					obj.lightMap = [0 0; 1 1];
					
					% Find the most minimum angle difference
					minDiff = inf;
					minIndex = [];
					for i = 1:numel(allKeys)
						tempDiff = min(roads(i).angleDiff);
						if (tempDiff < minDiff)
							minIndex = i;
							minDiff = tempDiff;
						end
					end
					from = allKeys{minIndex};
					[~, index] = min(roads(minIndex).angleDiff);
					to = allKeys{index};
					
					obj.intersectionMap(1, :) = [from, to];
					obj.intersectionMap(2, 1) = setdiff([allKeys{:}], [from, to]);
				case 4
					% Find which roads are the most aligned
					%allKeys = obj.connectionMap.keys;
					% First, get all road agents
					for i = 1:numel(allKeys)
						roads(i) = struct('angleDiffs', [], 'angle', []);
						agent = obj.instance.getCallee(allKeys{i});
						roads(i).angle = agent.overallAngle;
						while(roads(i).angle < 0)
							roads(i).angle = roads(i).angle + 2 * pi;
						end
					end
					
					% Find relative angles to other roads
					for i = 1:numel(allKeys)
						for j = 1:numel(allKeys)
							if (j ~= i)
								roads(i).angleDiff(j) = abs(abs(diff([roads(j).angle, roads(i).angle])) - pi);
							else
								roads(i).angleDiff(j) = inf;
							end
						end
					end
					
					% Create the intersection map
					obj.intersectionMap = zeros(2, 2);
					obj.lightMap = [0 0; 1 1];
					
					from = allKeys{1};
					[~, index] = min(roads(1).angleDiff);
					to = allKeys{index};
					
					obj.intersectionMap(1, :) = [from, to];
					obj.intersectionMap(2, :) = setdiff([allKeys{:}], [from, to]);
				otherwise
					obj.allGreen = 1;
            end
            
            if (numel(obj.connectionMap.keys) == 0)
                obj.setTimeStep(inf);
            end
            
			obj.record(0);
		end
		
		function runAtTime(obj, time)
			if obj.isRunTime(time);
				obj.lightMap = ~obj.lightMap;
				obj.record(time);
			end
		end
		
		function record(obj, time)
			obj.timeHistory(end + 1) = time;
			col = size(obj.lightHistory, 2) + 1;
			for i = 1:numel(obj.intersectionMap)
				obj.lightHistory(i, col) = obj.lightMap(i);
			end
		end
		
		function lightState = getLight(obj, from)
			if (obj.allGreen)
				lightState = 1;
				return;
			end
			index = find(obj.intersectionMap == from.id);
			if isempty(index)
				keyboard;
			end
			lightState = obj.lightMap(index);%#ok
		end
		
		% At an intersection, any added connection can go to any other
		% connection at the intersection
		function addConnection(obj, varargin)
			for i = 1:numel(varargin)
				toAdd = varargin{i};
				allConnections = obj.connectionMap.keys;
				if (numel(allConnections) == 0)
					obj.connectionMap(toAdd.id) = {};
				else
					if obj.connectionMap.isKey(toAdd.id)
						return; % Already in the map, shouldn't have added again
					end
					for j = 1:numel(allConnections)
						% Add new incoming connection with all existing
						% connections as outputs
						if (toAdd.id ~= allConnections{j})
							toAgent = obj.instance.getCallee(allConnections{j});
							addConnection@agents.roads.Connector(obj, toAdd, toAgent);
						end
						
						% Add new connection as outputs to all existing
						% connections
						addConnection@agents.roads.Connector(obj, toAgent, toAdd);
					end
				end
			end
		end
		
		function to = getConnections(obj, varargin)
			to = getConnections@agents.roads.Connector(obj);
		end
		
		function handle = plot(obj, varargin)
            if (numel(obj.connectionMap.keys) == 0)
                handle = [];
                return;
            end
			if ~isempty(varargin)
				color = varargin{1};
			else
				color = 'k';
			end
			spec = [color, 'o'];
			handle = plot(obj.location.x, obj.location.y, spec);
		end
		
		function handles = plotAtTime(obj, time)
			colIndex = find(obj.timeHistory <= time, 1, 'last');
			handles = {};
			for i = 1:numel(obj.intersectionMap)
				agent = obj.instance.getCallee(obj.intersectionMap(i));
				if ~isempty(agent)
					isLit = obj.lightHistory(i, colIndex);
					angle = agent.overallAngle;
					length = 0.02;
					to.x = obj.location.x;
					to.y = obj.location.y;
					from.x = to.x - cos(angle) * length;
					from.y = to.y - sin(angle) * length;
					if isLit
						handles{end + 1} = plot([from.x, to.x], [from.y, to.y], 'Color', [0 1 0 0.4], 'LineWidth', 2);
					else
						handles{end + 1} = plot([from.x, to.x], [from.y, to.y], 'Color', [1 0 0 0.4], 'LineWidth', 2);
					end
				end
			end
		end
	end
	
end

