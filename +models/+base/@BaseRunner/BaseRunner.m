classdef BaseRunner < util.QsubModel
    %BASERUNNER Runs models on cluster
    
    properties
    end
    
    methods (Static)
        function createRuns(rndSeedStart, rndSeedEnd)
            for i = rndSeedStart:rndSeedEnd
                models.base.BaseRunner.create_run(i + 129486238, 'models.base.base_1000', i);
            end
        end
    end
    
end
