classdef SymmetricalComponentServiceTest < matlab.unittest.TestCase
    %SYMMETRICALCOMPONENTSERVICETEST Unit tests for SymmetricalComponentService
    
    properties
        service;
        testPMU;
    end
    
    methods (TestClassSetup)
        function setupTestClass(testCase)
            testCase.service = src.services.SymmetricalComponentService();
            
            % Create test PMU with balanced three-phase data
            testCase.testPMU = src.domain.PMU(1, 'TestPMU', 138);
            
            % Create balanced voltage data
            numSamples = 100;
            voltageData = zeros(numSamples, 14);
            timeVec = (0:numSamples-1)' / 60; % 60 Hz sampling
            
            for i = 1:numSamples
                angle = 2*pi*60*timeVec(i) * 180/pi; % 60 Hz
                voltageData(i, 2) = 138; % VA_MOD
                voltageData(i, 5) = angle; % VA_ANG
                voltageData(i, 3) = 138; % VB_MOD
                voltageData(i, 6) = angle - 120; % VB_ANG
                voltageData(i, 4) = 138; % VC_MOD
                voltageData(i, 7) = angle + 120; % VC_ANG
                voltageData(i, 1) = timeVec(i); % Time
            end
            
            testCase.testPMU.setVoltageData(voltageData);
            testCase.testPMU.setTimeVector(timeVec);
        end
    end
    
    methods (Test)
        function testCalculate(testCase)
            %TESTCALCULATE Test symmetrical component calculation
            [posSeq, negSeq, zeroSeq] = testCase.service.calculate(testCase.testPMU);
            
            testCase.verifyNotEmpty(posSeq);
            testCase.verifyNotEmpty(negSeq);
            testCase.verifyNotEmpty(zeroSeq);
            
            % For balanced system, negative and zero sequence should be small
            testCase.verifyLessThan(max(abs(negSeq(:, 1))), 1e-10);
            testCase.verifyLessThan(max(abs(zeroSeq(:, 1))), 1e-10);
        end
        
        function testPositiveSequence(testCase)
            %TESTPOSITIVESEQUENCE Test positive sequence calculation
            [posSeq, ~, ~] = testCase.service.calculate(testCase.testPMU);
            
            % Positive sequence magnitude should be close to phase voltage
            testCase.verifyLessThan(abs(mean(posSeq(:, 1)) - 138), 1);
        end
    end
end



