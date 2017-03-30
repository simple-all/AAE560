classdef RoadElement < agents.base.Periodic
	%ROADELEMENT Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		from;
		to;
	end
	
	methods
		
		function obj = RoadElement(from, to)
			obj.from = from;
			obj.to = to;
		end
		
	end
	
end

