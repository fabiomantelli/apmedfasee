classdef QueryTest < matlab.unittest.TestCase
    %QUERYTEST Unit tests for Query domain entity
    
    methods (Test)
        function testConstructor(testCase)
            %TESTCONSTRUCTOR Test Query constructor
            query = src.domain.Query('TestQuery');
            testCase.verifyEqual(query.name, 'TestQuery');
        end
        
        function testAddPMU(testCase)
            %TESTADDPMU Test adding PMU to query
            query = src.domain.Query('TestQuery');
            pmu = src.domain.PMU(1, 'PMU1', 138);
            query.addPMU(pmu);
            
            testCase.verifyEqual(query.getPMUCount(), 1);
            retrieved = query.getPMU(1);
            testCase.verifyEqual(retrieved, pmu);
        end
        
        function testSelection(testCase)
            %TESTSELECTION Test PMU selection
            query = src.domain.Query('TestQuery');
            for i = 1:5
                pmu = src.domain.PMU(i, sprintf('PMU%d', i), 138);
                query.addPMU(pmu);
            end
            
            query.setSelection([1, 3, 5]);
            selected = query.getSelectedIndices();
            testCase.verifyEqual(selected, [1, 3, 5]);
            
            selectedPMUs = query.getSelectedPMUs();
            testCase.verifyEqual(length(selectedPMUs), 3);
        end
        
        function testReferenceIndex(testCase)
            %TESTREFERENCEINDEX Test reference PMU index
            query = src.domain.Query('TestQuery');
            for i = 1:3
                pmu = src.domain.PMU(i, sprintf('PMU%d', i), 138);
                query.addPMU(pmu);
            end
            
            query.setReferenceIndex(2);
            testCase.verifyEqual(query.getReferenceIndex(), 2);
        end
    end
end



