function data = compileResults(input, varargin)
trafficGrid = input.trafficGrid;
allVehicles = trafficGrid.instance.getAllCalleesOfType('agents.vehicles.Vehicle');
allRoads = trafficGrid.instance.getAllCalleesOfType('agents.roads.RoadElement');

averageDensities = [];
for i = 1:numel(allRoads)
    averageDensities(end + 1) = mean(allRoads{i}.densityHistory);
end

averageSpeeds = [];
travelTimes = [];
travelTimeIndecies = [];
for i = 1:numel(allVehicles)
	averageSpeeds(end + 1) = mean(allVehicles{i}.speedHistory);
	travelTimes(end + 1) = allVehicles{i}.travelTime;
    travelTimeIndecies(end + 1) = allVehicles{i}.travelTimeIndex;
end

bufferIndex = [];
meanMinutesPerMile = 1 / (mean(averageSpeeds) * 60);
percentileMinutesPerMile = prctile( 1 ./ (averageSpeeds * 60), 95); % 95th percentile of travel speed
bufferIndex = (percentileMinutesPerMile - meanMinutesPerMile) / meanMinutesPerMile;

% Display results if asked
if ~isempty(varargin)
    fprintf('Mean Buffer Index: %0.3f\n', mean(bufferIndex));
    fprintf('Mean Travel Speed: %0.3f mph\n', mean(averageSpeeds) * 60 * 60);
    fprintf('Mean Travel Time: %0.3f minutes\n', mean(travelTimes) / 60);
    fprintf('Mean Travel Time Index: %0.3f\n', mean(travelTimeIndecies));
    fprintf('Mean road density: %0.3f (cars/mile)\n', mean(averageDensities));
end

data.bufferIndex = bufferIndex;
data.averageSpeeds = averageSpeeds;
data.travelTimes = travelTimes;
data.travelTimeIndecies = travelTimeIndecies;
data.averageDensities = averageDensities;

end