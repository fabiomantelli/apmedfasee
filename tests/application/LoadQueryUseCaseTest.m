classdef LoadQueryUseCaseTest < matlab.unittest.TestCase
    %LOADQUERYUSECASETEST Unit tests for LoadQueryUseCase
    
    properties
        repository;
        useCase;
    end
    
    methods (TestClassSetup)
        function setupTestClass(testCase)
            % Create mock repository
            queriesDir = src.infrastructure.PathManager.getQueriesDirectory();
            testCase.repository = src.repository.MatFileQueryRepository(queriesDir);
            testCase.useCase = src.application.LoadQueryUseCase(testCase.repository);
        end
    end
    
    methods (Test)
        function testExecute(testCase)
            %TESTEXECUTE Test loading a query
            % Get list of available queries
            queryNames = testCase.repository.listQueries();
            
            if isempty(queryNames)
                testCase.assumeFail('No test queries available');
            end
            
            % Try to load first query
            query = testCase.useCase.execute(queryNames{1});
            
            testCase.verifyNotEmpty(query);
            testCase.verifyTrue(query.validate());
            testCase.verifyGreaterThan(query.getPMUCount(), 0);
        end
        
        function testExecuteInvalidQuery(testCase)
            %TESTEXECUTEINVALIDQUERY Test loading invalid query
            testCase.verifyError(@() testCase.useCase.execute(''), ...
                'LoadQueryUseCase:InvalidInput');
        end
    end
end



