classdef SimpleAgent < handle
	%SIMPLEAGENT Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		instance;
		id;
	end
	
	methods
		
		function setInstance(obj, inst)
			obj.instance = inst;
		end
		
		function setId(obj, id)
			obj.id = id;
		end
		
		function init(obj)
			fprintf('Initialization not overloaded for %s\n', class(obj));
		end
		
	end
	
end

