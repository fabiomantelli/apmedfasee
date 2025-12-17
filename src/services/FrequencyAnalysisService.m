classdef FrequencyAnalysisService < src.services.IFrequencyAnalysisService
    %FREQUENCYANALYSISSERVICE Service for frequency analysis operations
    
    methods
        function frequency = calculateFrequency(obj, pmu, method)
            %CALCULATEFREQUENCY Calculate frequency from PMU data
            if nargin < 3
                method = 'calculated';
            end
            
            if strcmpi(method, 'pmu')
                % Use direct PMU frequency measurement
                frequency = pmu.getFrequencyData();
                if isempty(frequency)
                    error('FrequencyAnalysisService:NoPMUFrequency', ...
                        'PMU does not have frequency measurements');
                end
            else
                % Calculate from positive sequence angle
                % This would require symmetrical components to be calculated first
                % For now, return PMU frequency if available, otherwise error
                frequency = pmu.getFrequencyData();
                if isempty(frequency)
                    error('FrequencyAnalysisService:NoFrequencyData', ...
                        'No frequency data available for calculation');
                end
            end
        end
        
        function rocof = calculateROCOF(obj, frequency, samplingRate)
            %CALCULATEROCOF Calculate Rate of Change of Frequency
            if isempty(frequency)
                error('FrequencyAnalysisService:EmptyFrequency', ...
                    'Frequency vector is empty');
            end
            
            rocof = zeros(size(frequency));
            rocof(1) = 0;
            
            for i = 2:length(frequency)
                rocof(i) = (frequency(i) - frequency(i-1)) * samplingRate;
            end
        end
    end
end



