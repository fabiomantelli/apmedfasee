classdef PronyAnalysisService < src.services.IOscillationAnalysisService
    %PRONYANALYSISSERVICE Service for Prony method analysis
    %   Implements the Prony method for identifying oscillation modes
    
    methods
        function result = analyze(obj, signal, parameters)
            %ANALYZE Perform Prony analysis
            %   signal - Signal data [PMUs x samples] or [samples x 1]
            %   parameters - Structure with:
            %       - modelOrder: Model order (default: length(signal)/4)
            %       - samplingRate: Sampling rate (required)
            %       - timeStart: Start time index (default: 1)
            %       - timeEnd: End time index (default: length(signal))
            %   Returns: Result structure with modes, frequencies, damping, amplitudes
            
            % Validate inputs
            if isempty(signal)
                error('PronyAnalysisService:EmptySignal', 'Signal is empty');
            end
            
            % Handle 2D signal (multiple PMUs)
            if size(signal, 1) > 1 && size(signal, 2) > 1
                % Use first PMU or combine
                signal = signal(1, :);
            end
            
            % Set default parameters
            params = obj.setDefaultParameters(parameters, length(signal));
            
            % Extract signal segment
            t1 = params.timeStart;
            t2 = params.timeEnd;
            signalSegment = signal(t1:t2);
            signalSegment = signalSegment(:)'; % Ensure row vector
            
            % Remove trend
            signalSegment = detrend(signalSegment);
            
            % Model order
            L = params.modelOrder;
            N = length(signalSegment);
            
            if L >= N
                L = N - 1;
            end
            
            % Build Hankel matrix
            H = zeros(L+1, N-L);
            for i = 1:L+1
                H(i, :) = signalSegment(i:N-L+i-1);
            end
            
            % Solve for coefficients using least squares
            % H * a = -h, where h is the last row
            h = H(end, :)';
            H_sub = H(1:end-1, :)';
            
            % Solve: H_sub * a = -h
            a = -H_sub \ h;
            
            % Add leading 1 for characteristic polynomial
            a = [1; a];
            
            % Find roots of characteristic polynomial
            z = roots(flipud(a));
            
            % Convert to frequency and damping
            samplingRate = params.samplingRate;
            amos = 1/samplingRate;
            z_s = log(z) * samplingRate;
            frequencies = angle(z) / (2*pi*amos);
            dampingFactor = real(z_s);
            dampingPercent = (-real(z_s) ./ abs(z_s)) * 100;
            
            % Calculate amplitudes and phases
            Z = [];
            for i = 1:min(L, N)
                Z(i, :) = z.^(i-1);
            end
            
            if size(Z, 1) > 0 && size(Z, 2) > 0
                Hi = (Z^-1) * signalSegment(1:size(Z, 1))';
                amplitudes = abs(Hi);
                phases = angle(Hi);
            else
                amplitudes = zeros(length(z), 1);
                phases = zeros(length(z), 1);
            end
            
            % Filter valid modes (positive frequency, reasonable damping)
            validModes = frequencies > 0 & frequencies < samplingRate/2 & ...
                        dampingPercent > -100 & dampingPercent < 100;
            
            % Store result
            result = struct();
            result.modes = z(validModes);
            result.frequencies = frequencies(validModes);
            result.dampingFactor = dampingFactor(validModes);
            result.dampingPercent = dampingPercent(validModes);
            result.amplitudes = amplitudes(validModes);
            result.phases = phases(validModes);
        end
        
        function params = setDefaultParameters(obj, parameters, signalLength)
            %SETDEFAULTPARAMETERS Set default parameter values
            params = struct();
            
            if isfield(parameters, 'modelOrder')
                params.modelOrder = parameters.modelOrder;
            else
                params.modelOrder = round(signalLength / 4);
            end
            
            if isfield(parameters, 'samplingRate')
                params.samplingRate = parameters.samplingRate;
            else
                error('PronyAnalysisService:MissingSamplingRate', 'Sampling rate is required');
            end
            
            if isfield(parameters, 'timeStart')
                params.timeStart = parameters.timeStart;
            else
                params.timeStart = 1;
            end
            
            if isfield(parameters, 'timeEnd')
                params.timeEnd = parameters.timeEnd;
            else
                params.timeEnd = signalLength;
            end
        end
    end
end

