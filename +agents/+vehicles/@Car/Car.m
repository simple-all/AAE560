classdef Car < agents.base.SimpleAgent & agents.base.Periodic
	%CAR Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		maxSpeed;
	end
	
	methods
		
		function obj = Car(maxSpeed)
			obj.maxSpeed = maxSpeed;
		end
		
		function runAtTime(obj, time)
			
		end
		
	end
	
end

