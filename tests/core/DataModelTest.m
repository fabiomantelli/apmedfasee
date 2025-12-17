classdef DataModelTest < matlab.unittest.TestCase
    %DATAMODELTEST Unit tests for DataModel class
    
    properties
        testDataModel;
        testFilePath;
    end
    
    methods (TestClassSetup)
        function setupTestClass(testCase)
            %SETUPTESTCLASS Set up test class
            testCase.testDataModel = src.core.DataModel();
            
            % Create a test .mat file path
            rootPath = src.utils.PathManager.getRootDirectory();
            queriesPath = fullfile(rootPath, 'consultas');
            testFiles = dir(fullfile(queriesPath, '*.mat'));
            
            if ~isempty(testFiles)
                testCase.testFilePath = fullfile(queriesPath, testFiles(1).name);
            end
        end
    end
    
    methods (Test)
        function testConstructor(testCase)
            %TESTCONSTRUCTOR Test DataModel constructor
            dm = src.core.DataModel();
            testCase.verifyNotEmpty(dm);
            testCase.verifyEqual(dm.timeLabel, 'Time (s)');
        end
        
        function testLoadFromFile(testCase)
            %TESTLOADFROMFILE Test loading data from .mat file
            if isempty(testCase.testFilePath)
                testCase.assumeFail('No test .mat file available');
            end
            
            dm = src.core.DataModel();
            dm.loadFromFile(testCase.testFilePath);
            
            testCase.verifyGreaterThan(dm.terminalCount, 0);
            testCase.verifyNotEmpty(dm.terminalNames);
        end
        
        function testGetSelectedPMUs(testCase)
            %TESTGETSELECTEDPMUS Test getting selected PMU indices
            dm = src.core.DataModel();
            dm.terminalCount = 5;
            dm.selection = [1 0 1 0 1];
            
            selected = dm.getSelectedPMUs();
            testCase.verifyEqual(selected, [1 3 5]);
        end
        
        function testValidate(testCase)
            %TESTVALIDATE Test data validation
            dm = src.core.DataModel();
            dm.terminalCount = 3;
            dm.terminalNames = {'PMU1', 'PMU2', 'PMU3'};
            dm.terminalData = rand(3, 100, 14);
            
            isValid = dm.validate();
            testCase.verifyTrue(isValid);
        end
        
        function testValidateInvalid(testCase)
            %TESTVALIDATEINVALID Test validation with invalid data
            dm = src.core.DataModel();
            dm.terminalCount = 3;
            dm.terminalNames = {}; % Empty names
            
            isValid = dm.validate();
            testCase.verifyFalse(isValid);
        end
    end
end



