function allData = loadAllData()
%LOADALLDATA Loads and compiles results for each test in the "rundata"
%folder

if ~exist('MonteCarloRuns.mat')
    dirs = dir('rundata');
    invalidNames = {'.', '..'};
    for i = 1:numel(dirs)
        if ~any(strmatch(dirs(i).name, invalidNames))
            fName = sprintf('rundata\\%s\\job1\\%s_job1.mat', dirs(i).name, dirs(i).name);
            if exist(fName)
                fprintf('Reading from %s\n', fName);
                results = load(fName);
                data = post.compileResults(results.output);
                if ~exist('allData')
                    allData = data;
                else
                    allData(end + 1) = data;
                end
            else
                error('Could not find file %s\n', fName);
            end
        end
    end
else
    allData = load('MonteCarloRuns.mat');
    allData = allData.allData;
end

end

