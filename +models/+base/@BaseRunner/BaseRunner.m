classdef BaseRunner < util.QsubModel
    %BASERUNNER Runs models on cluster
    
    properties
    end
    
    methods (Static)
        function createRuns(rndSeedStart, rndSeedEnd, numCars)
            for i = rndSeedStart:rndSeedEnd
                models.base.BaseRunner.create_run(i + 10000, 'models.base.base', numCars,  i);
            end
        end
        
        function createRunsSeparateDensity(rndSeedStart, rndSeedEnd, numCars)
            for i = rndSeedStart:rndSeedEnd
                models.base.BaseRunner.create_run(i + 10020, 'models.base.base_seprate_density', numCars,  i);
            end
        end
        
        function createRunsUnionDensity(rndSeedStart, rndSeedEnd, numCars)
            for i = rndSeedStart:rndSeedEnd
                models.base.BaseRunner.create_run(i + 10050, 'models.base.base_union_density', numCars,  i);
            end
        end
        
        function createRunsBase(rndSeedStart, rndSeedEnd, numCars)
            for i = rndSeedStart:rndSeedEnd
                models.base.BaseRunner.create_run(i + 10050, 'models.base.base_base', numCars,  i);
            end
        end
    end
    
end
