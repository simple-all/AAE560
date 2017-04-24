classdef VehicleGenerator < agents.base.SimpleAgent
    %VEHICLEGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        startTimes = [];
        pathFunc;
        allVehicles = []; % ID list of vehicles added
        networkId;
        trafficGrid;
    end
    
    methods
        function obj = VehicleGenerator(startTime, endTime, numVehicles, pathFunc, networkId, trafficGrid)
            obj.startTimes = randi((endTime - startTime), 1, numVehicles) + startTime; % List of start times for the vehicles to generate
            obj.pathFunc = pathFunc;
            % Find all unique start tines
            
            obj.networkId = networkId;
            obj.trafficGrid = trafficGrid;
        end
        
        function init(obj)
            times = unique(obj.startTimes);
            for i = 1:numel(times);
                obj.instance.scheduleAtTime(obj, times(i));
            end
        end
        
        function runAtTime(obj, time)
            % Add vehicles scheduled at current time
            numToAdd = sum(obj.startTimes == time);
            for i = 1:numToAdd
                fprintf('Adding vehicle at time %0.0f...\n', time);
                maxSpeed = 80;
                startTime = time; % Allow vehicles to spawn in between 0 and 20 minutes into the simulation
                % Make a bunch of vehicles and start them up
                startPoint = randi(numel(obj.trafficGrid.garages));
                endPoint = startPoint;
                
                while (endPoint == startPoint)
                    endPoint = randi(numel(obj.trafficGrid.garages));
                end
                
                [path, cost] = obj.pathFunc(obj.trafficGrid.garages{startPoint}, obj.trafficGrid.garages{endPoint}, 0, obj.networkId);
                vehicle = agents.vehicles.Vehicle(maxSpeed, startTime, obj.networkId);
                obj.instance.addCallee(vehicle);
                vehicle.setPath(path, cost);
                obj.allVehicles(end + 1) = vehicle.id;
            end
        end
    end
    
end

