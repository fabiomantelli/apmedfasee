classdef PMUTest < matlab.unittest.TestCase
    %PMUTEST Unit tests for PMU domain entity
    
    methods (Test)
        function testConstructor(testCase)
            %TESTCONSTRUCTOR Test PMU constructor
            pmu = src.domain.PMU(1, 'PMU1', 138);
            testCase.verifyEqual(pmu.id, 1);
            testCase.verifyEqual(pmu.name, 'PMU1');
            testCase.verifyEqual(pmu.baseVoltage, 138);
        end
        
        function testSetGetVoltageData(testCase)
            %TESTSETGETVOLTAGEDATA Test voltage data setter/getter
            pmu = src.domain.PMU(1, 'PMU1', 138);
            voltageData = rand(100, 14);
            pmu.setVoltageData(voltageData);
            
            retrieved = pmu.getVoltageData();
            testCase.verifyEqual(retrieved, voltageData);
        end
        
        function testSetGetFrequencyData(testCase)
            %TESTSETGETFREQUENCYDATA Test frequency data setter/getter
            pmu = src.domain.PMU(1, 'PMU1', 138);
            freqData = 60 + 0.1*randn(100, 1);
            pmu.setFrequencyData(freqData);
            
            retrieved = pmu.getFrequencyData();
            testCase.verifyEqual(retrieved, freqData);
            testCase.verifyTrue(pmu.hasFrequency);
        end
        
        function testValidate(testCase)
            %TESTVALIDATE Test PMU validation
            pmu = src.domain.PMU(1, 'PMU1', 138);
            voltageData = rand(100, 14);
            timeVec = (0:99)';
            pmu.setVoltageData(voltageData);
            pmu.setTimeVector(timeVec);
            
            isValid = pmu.validate();
            testCase.verifyTrue(isValid);
        end
        
        function testValidateInvalid(testCase)
            %TESTVALIDATEINVALID Test validation with invalid data
            pmu = src.domain.PMU(1, '', 138);
            isValid = pmu.validate();
            testCase.verifyFalse(isValid);
        end
    end
end



