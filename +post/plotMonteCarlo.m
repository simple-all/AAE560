function  plotMonteCarlo()
%PLOTMONTECARLO Plots the moving average for Monte Carlo runs
% Assume first half of data is separated data sets, last half if united
allData = post.loadAllData();



% Get fields to make moving averages for
allFields = fields(allData(1));
separate = struct();
for i = 1:numel(allFields)
    separate.([allFields{i}, 'Avg']) = [];
end
united = separate;


% Calculate the moving averages

% Separate data sets
for i = 1:(numel(allData) / 2)
    for j = 1:numel(allFields)
        newData = allData(i).(allFields{j});
        if isempty(separate.([allFields{j}, 'Avg']))
            separate.([allFields{j}, 'Avg']) = mean(newData);
        else
            separate.([allFields{j}, 'Avg'])(end + 1) = (separate.([allFields{j}, 'Avg'])(end) * numel(separate.([allFields{j}, 'Avg'])) + mean(newData)) / (numel(separate.([allFields{j}, 'Avg'])) + 1); 
        end
    end
end

% Plot
newFields = fields(separate);
figHandles = struct();
for i = 1:numel(newFields)
    figHandles.(newFields{i}) = figure;
    plot(separate.(newFields{i}));
    titleStr = allFields{i};
    % Split from camel case to proper capitalization with spaces
    splitIndex = find(titleStr < 97);
    if ~isempty(splitIndex)
        titleCells = {};
        for j = 1:numel(splitIndex)
            word = titleStr(1:(splitIndex(j) - 1));
            titleStr = titleStr(splitIndex(j):end);
            titleCells{end + 1} = word;
            splitIndex = splitIndex - splitIndex(j) + 1;
        end
        titleCells{end + 1} = titleStr;
        
        newTitleStr = titleCells{1};
        for j = 2:numel(titleCells)
            newTitleStr = [newTitleStr, ' ', titleCells{j}];
        end
        
    else
        newTitleStr = titleStr;
    end
    
    
    newTitleStr = regexprep(newTitleStr,'(\<[a-z])','${upper($1)}');
    newTitleStr = [newTitleStr, ' Moving Average'];
    title(newTitleStr);
    switch i
        case 1
            ylabel('Buffer Index');
        case 2
            ylabel('Average Speed (miles per second)');
        case 3
            ylabel('Average Travel Time (seconds)');
        case 4
            ylabel('Travel Time Index');
        case 5
            ylabel('Average Road Density (cars per mile)');
    end
end


% United data sets
for i = ((numel(allData) / 2) + 1):numel(allData)
    for j = 1:numel(allFields)
        newData = allData(i).(allFields{j});
        if isempty(united.([allFields{j}, 'Avg']))
            united.([allFields{j}, 'Avg']) = mean(newData);
        else
            united.([allFields{j}, 'Avg'])(end + 1) = (united.([allFields{j}, 'Avg'])(end) * numel(united.([allFields{j}, 'Avg'])) + mean(newData)) / (numel(united.([allFields{j}, 'Avg'])) + 1); 
        end
    end
end

% Plot
newFields = fields(united);
for i = 1:numel(newFields)
    figure(figHandles.(newFields{i}));
    hold on;
    plot(united.(newFields{i}));
    legend('Separate', 'United');
    xlabel('Number of Replicate Runs');
end


end

