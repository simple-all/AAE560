classdef Connector < handle
	%CONNECTOR Connects roads to other roads or garages
	
	properties
		location;
		connectionMap;
	end
	
	methods
		
		function obj = Connector(location)
			obj.connectionMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');
			obj.location = location;
		end
		
		function addConnection(obj, from, to)
			obj.connectionMap(from.id) = to;
		end
		
	end
	
end

