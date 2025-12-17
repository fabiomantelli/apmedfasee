classdef FrequencyPlotter < src.visualization.Plotter
    %FREQUENCYPLOTTER Plots frequency data from PMUs
    %   Handles both calculated frequency and PMU frequency
    
    methods
        function plot(obj, selectedPMUs, frequencyType)
            %PLOT Plot frequency data
            %   selectedPMUs - Array of PMU indices to plot
            %   frequencyType - 'calculated' or 'pmu'
            
            if nargin < 3
                frequencyType = 'calculated';
            end
            
            if isempty(obj.dataModel)
                error('FrequencyPlotter:NoDataModel', 'DataModel not set');
            end
            
            if isempty(selectedPMUs)
                error('FrequencyPlotter:NoSelection', 'No PMUs selected');
            end
            
            % Get frequency data
            if strcmpi(frequencyType, 'pmu')
                if isempty(obj.dataModel.frequencyData)
                    error('FrequencyPlotter:NoPMUFrequency', 'PMU frequency data not available');
                end
                freqData = obj.dataModel.frequencyData;
            else
                if isempty(obj.dataModel.terminalDataSp)
                    error('FrequencyPlotter:NoCalculatedFrequency', 'Calculated frequency data not available');
                end
                freqData = obj.dataModel.terminalDataSp(:, :, 5); % Column 5 is frequency
            end
            
            % Create figure
            figure;
            hold on;
            
            % Get time vector and colors
            timeVec = obj.getTimeVector();
            colors = obj.getTerminalColors(selectedPMUs);
            names = obj.getTerminalNames(selectedPMUs);
            
            % Plot each selected PMU
            legendEntries = {};
            for i = 1:length(selectedPMUs)
                pmuIdx = selectedPMUs(i);
                signal = freqData(pmuIdx, :);
                
                h = plot(timeVec, signal);
                set(h, 'Color', colors{i}, 'LineWidth', 2);
                legendEntries{end+1} = names{i};
            end
            
            % Configure axes
            samplingRate = obj.dataModel.samplingRate;
            if strcmpi(frequencyType, 'pmu')
                titleStr = sprintf('SIN Frequency (PMU) [%df/s]', samplingRate);
            else
                titleStr = sprintf('SIN Frequency (Calculated) [%df/s]', samplingRate);
            end
            
            xlim([min(timeVec) max(timeVec)]);
            
            % Configure axes (automatically formats time axis)
            obj.configureAxes(obj.dataModel.timeLabel, 'Frequency (Hz)', titleStr, true);
            
            % Add legend
            obj.addLegend(legendEntries);
            
            hold off;
        end
    end
end

