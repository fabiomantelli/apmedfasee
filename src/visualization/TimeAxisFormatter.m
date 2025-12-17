classdef TimeAxisFormatter < handle
    %TIMEAXISFORMATTER Utility class for formatting time axis in plots
    %   Modern architecture version of formatar_eixo_tempo.m
    %   Converts SOC (Unix timestamp) to relative time and formats as HH:MM:SS.MMM
    %   Also configures tooltip to show formatted time instead of raw values
    
    methods (Static)
        function format(timeVector, timeLabel)
            %FORMAT Format time axis with HH:MM:SS.MMM format
            %   timeVector - Time vector in seconds (relative or Unix timestamp)
            %   timeLabel - Label string with start date/time
            %   Also configures tooltip to show formatted time
            
            % Validate input
            if isempty(timeVector)
                if nargin >= 2 && ~isempty(timeLabel)
                    xlabel(timeLabel);
                else
                    xlabel('Time (s)');
                end
                return;
            end
            
            % Remove NaN and Inf
            validMask = ~isnan(timeVector) & ~isinf(timeVector);
            if ~any(validMask)
                if nargin >= 2 && ~isempty(timeLabel)
                    xlabel(timeLabel);
                else
                    xlabel('Time (s)');
                end
                return;
            end
            timeVector = timeVector(validMask);
            
            % Convert SOC (Unix timestamp) to relative time in seconds
            if max(timeVector) > 1e9  % Unix timestamp
                timeInitial = min(timeVector);
                timeRelative = timeVector - timeInitial;
            else
                % Already relative, ensure it starts at zero
                timeMin = min(timeVector);
                if abs(timeMin) > 1e-6
                    timeRelative = timeVector - timeMin;
                else
                    timeRelative = timeVector;
                end
            end
            
            % Ensure unique and increasing values
            [timeRelative, uniqueIdx] = unique(timeRelative, 'stable');
            if length(timeRelative) < 2
                if nargin >= 2 && ~isempty(timeLabel)
                    xlabel(timeLabel);
                else
                    xlabel('Time (s)');
                end
                return;
            end
            
            % Calculate optimal number of ticks based on data size
            numData = length(timeRelative);
            numTicks = src.visualization.TimeAxisFormatter.calculateOptimalTicks(numData);
            
            % Select uniformly distributed indices
            tickIndices = round(linspace(1, numData, numTicks));
            tickIndices = unique(tickIndices);
            tickIndices = sort(tickIndices);
            
            if length(tickIndices) < 2
                tickIndices = [1, numData];
            end
            
            % Get corresponding time values
            tickValues = timeRelative(tickIndices);
            
            % Ensure unique and increasing values
            [tickValues, idxUnique] = unique(tickValues, 'stable');
            tickIndices = tickIndices(idxUnique);
            
            % Convert to HH:MM:SS:MS
            tickLabels = cell(length(tickIndices), 1);
            
            for idx = 1:length(tickIndices)
                ti = tickIndices(idx);
                if ti < 1 || ti > numData
                    continue;
                end
                
                timeSec = timeRelative(ti);
                
                % Convert seconds to hours, minutes, seconds, and milliseconds
                hours = floor(timeSec / 3600);
                minutes = floor((timeSec - hours*3600) / 60);
                seconds = timeSec - hours*3600 - minutes*60;
                secondsInt = floor(seconds);
                milliseconds = round((seconds - secondsInt) * 1000);
                
                % Ensure milliseconds is in range [0, 999]
                if milliseconds >= 1000
                    secondsInt = secondsInt + 1;
                    milliseconds = 0;
                end
                if milliseconds < 0
                    milliseconds = 0;
                end
                
                % Format as HH:MM:SS.MMM (with dot between seconds and milliseconds)
                tickLabels{idx} = sprintf('%02d:%02d:%02d.%03d', hours, minutes, secondsInt, milliseconds);
            end
            
            % Apply labels to X axis
            try
                ax = gca;
                
                % Validate tick values
                if any(isnan(tickValues)) || any(isinf(tickValues))
                    error('Invalid tick values');
                end
                
                % Apply ticks
                ax.XTick = tickValues;
                ax.XTickLabel = tickLabels;
                
                % Create X axis label with start date
                if nargin >= 2 && ~isempty(timeLabel)
                    if contains(timeLabel, 'Início:')
                        % Extract start date/time
                        idxInicio = strfind(timeLabel, 'Início:');
                        if ~isempty(idxInicio)
                            dataInicio = strtrim(timeLabel(idxInicio+7:end));
                            xlabel(sprintf('Time (UTC) - %s (HH:MM:SS.MMM)', dataInicio));
                        else
                            xlabel(sprintf('%s (HH:MM:SS.MMM)', timeLabel));
                        end
                    else
                        xlabel(sprintf('%s (HH:MM:SS.MMM)', timeLabel));
                    end
                else
                    xlabel('Time (HH:MM:SS.MMM)');
                end
                
            catch ME
                % Fallback to simple label on error
                fprintf('Warning: Error formatting time axis: %s\n', ME.message);
                if nargin >= 2 && ~isempty(timeLabel)
                    xlabel(timeLabel);
                else
                    xlabel('Time (s)');
                end
            end
            
            % Setup tooltip formatting
            try
                src.visualization.TimeAxisFormatter.setupTooltip(timeRelative, timeLabel);
            catch
                % Silently fail if tooltip setup is not available
            end
        end
        
        function setupTooltip(timeVector, timeLabel)
            %SETUPTOOLTIP Configure datacursor tooltip to show formatted time
            %   timeVector - Time vector (relative time in seconds)
            %   timeLabel - Time label string
            
            if nargin < 1 || isempty(timeVector)
                return;
            end
            
            if nargin < 2
                timeLabel = 'Time';
            end
            
            try
                fig = gcf;
                if isempty(fig)
                    return;
                end
                
                dcm = datacursormode(fig);
                if isempty(dcm)
                    return;
                end
                
                % Store time data in figure's UserData
                fig.UserData.timeVector = timeVector;
                fig.UserData.timeLabel = timeLabel;
                
                % Set update function
                set(dcm, 'UpdateFcn', @src.visualization.TimeAxisFormatter.formatTooltipCallback);
                
            catch ME
                fprintf('Warning: Could not setup time tooltip: %s\n', ME.message);
            end
        end
        
        function outputTxt = formatTooltipCallback(~, eventObj, ~, ~)
            %FORMATTOOLTIPCALLBACK Callback to format datacursor tooltip with HH:MM:SS.MMM
            
            try
                fig = ancestor(eventObj.Target, 'figure');
                if isempty(fig) || ~isfield(fig.UserData, 'timeVector')
                    pos = get(eventObj, 'Position');
                    outputTxt = {sprintf('X: %.6f', pos(1)), sprintf('Y: %.6f', pos(2))};
                    return;
                end
                
                tempoPlot = fig.UserData.timeVector;
                pos = get(eventObj, 'Position');
                xVal = pos(1);
                
                % Find closest time value
                [~, idx] = min(abs(tempoPlot - xVal));
                if idx > length(tempoPlot)
                    idx = length(tempoPlot);
                elseif idx < 1
                    idx = 1;
                end
                
                timeSec = tempoPlot(idx);
                
                % Convert to HH:MM:SS.MMM
                hours = floor(timeSec / 3600);
                minutes = floor((timeSec - hours*3600) / 60);
                seconds = timeSec - hours*3600 - minutes*60;
                secondsInt = floor(seconds);
                milliseconds = round((seconds - secondsInt) * 1000);
                
                if milliseconds >= 1000
                    secondsInt = secondsInt + 1;
                    milliseconds = 0;
                end
                if milliseconds < 0
                    milliseconds = 0;
                end
                
                timeFormatted = sprintf('%02d:%02d:%02d.%03d', hours, minutes, secondsInt, milliseconds);
                outputTxt = {sprintf('Tempo: %s', timeFormatted), sprintf('Y: %.6f', pos(2))};
                
            catch ME
                pos = get(eventObj, 'Position');
                outputTxt = {sprintf('X: %.6f', pos(1)), sprintf('Y: %.6f', pos(2))};
                fprintf('Warning: Error formatting tooltip: %s\n', ME.message);
            end
        end
        
        function numTicks = calculateOptimalTicks(numData)
            %CALCULATEOPTIMALTICKS Calculate optimal number of ticks based on data size
            if numData < 100
                numTicks = min(10, max(2, numData));
            elseif numData < 1000
                numTicks = 10 + round((numData - 100) / 100);
                numTicks = min(15, max(10, numTicks));
            elseif numData < 10000
                numTicks = 15 + round((numData - 1000) / 500);
                numTicks = min(20, max(15, numTicks));
            else
                numTicks = 20 + round((numData - 10000) / 2000);
                numTicks = min(25, max(20, numTicks));
            end
            numTicks = max(2, min(numTicks, numData)); % Between 2 and numData
        end
    end
end

