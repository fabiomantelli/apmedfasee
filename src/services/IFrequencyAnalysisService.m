classdef IFrequencyAnalysisService < handle
    %IFREQUENCYANALYSISSERVICE Interface for frequency analysis operations
    %   Defines contract for frequency-related calculations
    
    methods (Abstract)
        frequency = calculateFrequency(obj, pmu, method)
        %CALCULATEFREQUENCY Calculate frequency from PMU data
        %   pmu - PMU domain object
        %   method - 'pmu' (direct measurement) or 'calculated' (from angle)
        %   Returns: Frequency vector [samples x 1]
        
        rocof = calculateROCOF(obj, frequency, samplingRate)
        %CALCULATEROCOF Calculate Rate of Change of Frequency
        %   frequency - Frequency vector
        %   samplingRate - Sampling rate (samples/second)
        %   Returns: ROCOF vector [samples x 1]
    end
end



