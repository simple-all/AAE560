classdef Garage < agents.roads.Element
	%GARAGE Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		location
		connector;
	end
	
	methods
		
		function obj = Garage(location, connector)
			obj.location = location;
			obj.connector = connector;
		end
		
		function plot(obj, varargin)
			if ~isempty(varargin)
				color = varargin{1};
			else
				color = 'k';
			end
			
			spec = ['*', color];
			plot(obj.location.x, obj.location.y, spec); 
		end
		
	end
	
end

