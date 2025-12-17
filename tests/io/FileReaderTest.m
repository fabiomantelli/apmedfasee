classdef FileReaderTest < matlab.unittest.TestCase
    %FILEREADERTEST Unit tests for FileReader class
    
    properties
        testDataDirectory;
    end
    
    methods (TestClassSetup)
        function setupTestClass(testCase)
            %SETUPTESTCLASS Set up test class
            % Note: This test requires actual data files
            % In a real scenario, you would use test fixtures
            rootPath = src.utils.PathManager.getRootDirectory();
            testCase.testDataDirectory = fullfile(rootPath, 'consultas');
        end
    end
    
    methods (Test)
        function testConstructor(testCase)
            %TESTCONSTRUCTOR Test FileReader constructor
            reader = src.io.FileReader();
            testCase.verifyNotEmpty(reader);
        end
        
        function testFilterValidFiles(testCase)
            %TESTFILTERVALIDFILES Test file filtering
            reader = src.io.FileReader();
            
            % Create mock file structure
            files(1).name = 'valid_file.txt';
            files(2).name = 'log.txt';
            files(3).name = 'readme.txt';
            files(4).name = 'another_valid.dat';
            
            % Use reflection to access private method (for testing)
            validFiles = reader.filterValidFiles(files);
            
            testCase.verifyEqual(length(validFiles), 2);
            testCase.verifyEqual(validFiles(1).name, 'valid_file.txt');
            testCase.verifyEqual(validFiles(2).name, 'another_valid.dat');
        end
    end
end



