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
<<<<<<< HEAD
         density;
         traveltimeindex;
         bufferindex
=======
        density;
        
        timeHistory = [];
        densityHistory = [];
        
        % Plotting
        cMap;
        myHandle;
>>>>>>> origin/master
	end
	
	methods
		
		function obj = RoadElement(from, to, speedLimit, overallAngle)
			obj.from = from;
			obj.to = to;
			obj.speedLimit = speedLimit / 60 / 60; % Miles per second
			obj.overallAngle = overallAngle;
            obj.setTimeStep(1);
            
            cVals = [1 0 0; 1 1 0; 0 1 0];
			c_HSV = rgb2hsv(cVals);
			nColors = 50;
			c_HSV_interp = interp1([0, nColors / 2, nColors], c_HSV(:, 1), 1:nColors);
			c_HSV = [c_HSV_interp', repmat(c_HSV(1, 2:3), nColors, 1)];
			obj.cMap = hsv2rgb(c_HSV);
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
			handle = quiver(from.x, from.y, to.x - from.x, to.y - from.y, 0, 'Color', color, 'MaxHeadSize', 0.4);
        end
        
        function runAtTime(obj, time)
            if obj.isRunTime(time)
                obj.density = numel(obj.vehicles)/ obj.getLength();
                obj.log(time);
            end
        end
<<<<<<< HEAD
 
=======
        
        function log(obj, time)
            obj.timeHistory(end + 1) = time;
            obj.densityHistory(end + 1) = obj.density;
        end
        
        function handle = plotAtTime(obj, time, maxDensity)
			colIndex = find(obj.timeHistory <= time, 1, 'last');
            if (maxDensity == 0)
                densityScale = 1;
            else
                densityScale = 1 - (obj.densityHistory(colIndex) / maxDensity);
                densityScale = max(0, densityScale);
            end
            color = interp1(linspace(0, 1, size(obj.cMap, 1)), obj.cMap, densityScale, 'nearest');
            if isempty(obj.myHandle)
    			obj.myHandle = obj.plot(color);
            else
                set(obj.myHandle, 'Color', color);
            end
            handle = obj.myHandle;
		end
        
>>>>>>> origin/master
            
    end
    
        
	
end

