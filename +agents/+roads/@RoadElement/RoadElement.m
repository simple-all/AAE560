classdef RoadElement < agents.base.Periodic & agents.roads.Element
	%ROADELEMENT Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		from;
		to;
		
		vehicles = []; % list of vehicles on the road
		
		% Speed
		speedLimit; 
		
		overallAngle;
         density;
	end
	
	methods
		
		function obj = RoadElement(from, to, speedLimit, overallAngle)
			obj.from = from;
			obj.to = to;
			obj.speedLimit = speedLimit / 60 / 60; % Miles per second
			obj.overallAngle = overallAngle;
            obj.setTimeStep(5);
        end
        function init(obj)
            obj.instance.scheduleAtTime(obj,0);
        end
		function length = getLength(obj)
			dx = obj.to.location.x - obj.from.location.x;
			dy = obj.to.location.y - obj.from.location.y;
			length = norm([dx, dy]);
		end
		
		function addVehicle(obj, vehicle)
			if ~any(obj.vehicles == vehicle.id)
				obj.vehicles(end + 1) = vehicle.id;
			end
		end
		
		function removeVehicle(obj, vehicle)
			obj.vehicles = setdiff(obj.vehicles, vehicle.id);
		end
		
		function ahead = getVehicleAhead(obj, vehicle, isOnRoad)
			dist = inf;
			ahead = [];
			for i = 1:numel(obj.vehicles)
				nextVehicle = vehicle.instance.getCallee(obj.vehicles(i));
				if (nextVehicle.id ~= vehicle.id)
					if (nextVehicle.progress > vehicle.progress) || ~isOnRoad
						if isOnRoad
							nextDist = nextVehicle.progress - vehicle.progress;
						else
							nextDist = nextVehicle.progress;
						end
						
						if (nextDist < dist)
							dist = nextDist;
							ahead = nextVehicle;
						end
					end
					
				end
			end
			
		end
		
		function handle = plot(obj, varargin)
			if ~isempty(varargin)
				color = varargin{1};
			else
				color = 'k';
			end
			from.x = obj.from.location.x;
			from.y = obj.from.location.y;
			to.x = obj.to.location.x;
			to.y = obj.to.location.y;
			handle = quiver(from.x, from.y, to.x - from.x, to.y - from.y, 0, color, 'MaxHeadSize', 0.4);
        end
        function runAtTime(obj, time)
            if obj.isRunTime(time)
                obj.density = numel(obj.vehicles)/ obj.getLength();
              
            end
        end
            
    end
	
end

