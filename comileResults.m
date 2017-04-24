averageSpeeds = [];
travelTimes = [];
travelTimeIndecies = [];
for i = 1:numel(allVehicles)
	averageSpeeds(end + 1) = mean(allVehicles{i}.speedHistory);
	travelTimes(end + 1) = allVehicles{i}.travelTime;
    travelTimeIndecies(end + 1) = allVehicles{i}.travelTimeIndex;
end

bufferIndex = [];
for i = 1:numel(allVehicles)
	bufferIndex(end + 1) = (0.95 * allVehicles{i}.travelTime - mean(travelTimes)) / mean(travelTimes);
end

% Display results
fprintf('Mean Buffer Index: %0.3f\n', mean(bufferIndex));
fprintf('Mean Travel Speed: %0.3f mph\n', mean(averageSpeeds) * 60 * 60);
fprintf('Mean Travel Time: %0.3f minutes\n', mean(travelTimes) / 60);
fprintf('Mean Travel Time Index: %0.3f\n', mean(travelTimeIndecies));