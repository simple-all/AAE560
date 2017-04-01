classdef Connector < agents.roads.Element
	%CONNECTOR Connects roads agents to other road agents
	
	properties
		location;
	end
	
	properties
		connectionMap;
	end
	
	methods
		
		function obj = Connector(location)
			obj.connectionMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');
			obj.location = location;
		end
		
		% Add connection to
		function addConnection(obj, from, to)
			if obj.connectionMap.isKey(from.id)
				temp = obj.connectionMap(from.id);
				if isa(to, 'cell')
					obj.connectionMap(from.id) = {temp{:}, to{:}};
				else
					obj.connectionMap(from.id) = {temp{:}, to};
				end
			else
				if isa(to, 'cell')
					obj.connectionMap(from.id) = {to{:}};
				else
					obj.connectionMap(from.id) = {to};
				end
			end
		end
		
		% Get all connections from 
		function to = getConnections(obj, varargin)
			if isempty(varargin)
				% if no inputs, return all out connections
				allKeys = obj.connectionMap.keys;
				to = {};
				for i = 1:numel(allKeys)
					outputs = obj.connectionMap(allKeys{i});
					for j = 1:numel(outputs)
						if ~isempty(to)
							isInList = 0;
							for k = 1:numel(to)
								if (to{k}.id == outputs{j}.id)
									isInList = 1;
									break;
								end
							end
							
							if ~isInList
								to{end + 1} = outputs{j};
							end
						else
							to{end + 1} = outputs{j};
						end
					end
				end
			else
				from = varargin{1};
				if obj.connectionMap.isKey(from.id)
					to = obj.connectionMap(from.id);
				else
					to = {};
				end
			end
		end
		
	end
	
end

