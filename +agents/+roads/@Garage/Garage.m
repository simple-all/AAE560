classdef Garage < agents.roads.Element
	%GARAGE Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		location
		connector;
		
		numSpaces; % Default as single-car parking space
	end
	
	methods
		
		function obj = Garage(location, connector, numSpaces)
			obj.location = location;
			obj.connector = connector;
			obj.numSpaces = numSpaces;
		end
		
		function connect(obj)
			% Update the connector to include the garage
			% By default, only allow right-hand turns into the garage if
			% the location is not the same as the connector
			dx = obj.location.x - obj.connector.location.x;
			dy = obj.location.y - obj.connector.location.y;
			
			
			
			possibleFrom = obj.connector.connectionMap.keys;
			flag = 1;
			if (norm([dx, dy]) == 0)
				% Connect both ways //TODO
				flag = 1;
			end
			for i = 1:numel(possibleFrom)
				temp = obj.instance.getCallee(possibleFrom{i});
				if isa(temp, 'agents.roads.RoadElement')
					fdx = temp.to.location.x - temp.from.location.x;
					fdy = temp.to.location.y - temp.from.location.y;
					
					% Get if the garage is on the right or left hand side
					side = sign(-fdx * (obj.location.y - temp.from.location.y) - -fdy * (obj.location.x - temp.from.location.x));
					
					% Get angle
					angle = atan2d(dy - fdy, dx - fdx);
					if (side > 0) || flag
						% Right hand turn, connect
						obj.connector.addConnection(temp, obj);
						obj.connector.addConnection(obj, obj.connector.getConnections(temp));
					end
				end
			end
		end
		
		function [garageHandle, connectionHandle] = plot(obj, varargin)
			if ~isempty(varargin)
				color = varargin{1};
			else
				color = 'k';
			end
			
			% Plot the garge
			spec = ['*', color];
			garageHandle = plot(obj.location.x, obj.location.y, spec); 
			
			% Plot the connection from the garage to the connector
			x = [obj.location.x, obj.connector.location.x];
			y = [obj.location.y, obj.connector.location.y];
			connectionHandle = plot(x, y, color);
		end
		
	end
	
end

