classdef Periodic < agents.base.SimpleAgent
	%PERIODIC Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (Access = private)
		tStep;
		lastRunTime = -inf;
	end
	
	methods
		
		function setTimeStep(obj, tStep)
			obj.tStep = tStep;
		end
		
		function setLastRunTime(obj, time)
			obj.lastRunTime = time;
		end
		
		function bool = isRunTime(obj, time)
			if (time >= (obj.lastRunTime + obj.tStep));
				bool = 1;
				obj.lastRunTime = time;
				obj.instance.scheduleAtTime(obj, time + obj.tStep);
			else
				bool = 0;
			end
		end
		
	end
	
end

