classdef RoadElement < agents.base.Periodic & agents.roads.Element
	%ROADELEMENT Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		from;
		to;
		
		% Speed
		speedLimit = 45; 
	end
	
	methods
		
		function obj = RoadElement(from, to)
			obj.from = from;
			obj.to = to;
		end
		
		function length = getLength(obj)
			dx = obj.to.location.x - obj.from.location.x;
			dy = obj.to.location.y - obj.from.location.y;
			length = norm([dx, dy]);
		end
		
		function handle = plot(obj, varargin)
			if ~isempty(varargin)
				color = varargin{1};
			else
				color = 'k';
			end
			plotSpacing = 0.01;
			angle = atan2(obj.to.location.y - obj.from.location.y, obj.to.location.x - obj.from.location.x);
			from.x = obj.from.location.x + sin(angle) * plotSpacing;
			from.y = obj.from.location.y + cos(angle) * plotSpacing;
			to.x = obj.to.location.x + sin(angle) * plotSpacing;
			to.y = obj.to.location.y + cos(angle) * plotSpacing;
			handle = quiver(from.x, from.y, to.x - from.x, to.y - from.y, 0, color, 'MaxHeadSize', 0.4);
		end
	end
	
end

