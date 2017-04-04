classdef Intersection < agents.roads.Connector
	%INTERSECTION Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
	end
	
	methods
		
		function obj = Intersection(location)
			% Super init
			obj = obj@agents.roads.Connector(location);
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
			if ~isempty(varargin)
				color = varargin{1};
			else
				color = 'k';
			end
			spec = [color, 'o'];
			handle = plot(obj.location.x, obj.location.y, spec);
		end
		
	end
	
end

