classdef MatrixPencilAnalysisService < src.services.IOscillationAnalysisService
    %MATRIXPENCILANALYSISSERVICE Service for Matrix Pencil method analysis
    %   Implements the Matrix Pencil method for identifying oscillation modes
    
    methods
        function result = analyze(obj, signal, parameters)
            %ANALYZE Perform Matrix Pencil analysis
            %   signal - Signal data [PMUs x samples] or [samples x 1]
            %   parameters - Structure with:
            %       - modelOrder: Model order L (default: length(signal)/4)
            %       - samplingRate: Sampling rate (required)
            %       - timeStart: Start time index (default: 1)
            %       - timeEnd: End time index (default: length(signal))
            %       - frequencyFilter: Minimum frequency filter (default: 0.01)
            %   Returns: Result structure with modes, frequencies, damping, amplitudes
            
            % Validate inputs
            if isempty(signal)
                error('MatrixPencilAnalysisService:EmptySignal', 'Signal is empty');
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
            
            if L >= N/2
                L = floor(N/2) - 1;
            end
            
            % Build data matrix Yp
            Yp = zeros(L+1, N-L);
            for i = 1:L+1
                Yp(i, :) = signalSegment(i:N-L+i-1);
            end
            
            % SVD decomposition
            [U, S, V] = svd(Yp);
            Vmax = max(diag(S));
            
            % Determine rank (modes)
            tol = 1e-3;
            rank = 0;
            for i = 1:min(size(S))
                if S(i, i) / Vmax > tol
                    rank = rank + 1;
                end
            end
            
            if rank == 0
                rank = 1;
            end
            
            % Extract V1 and V2
            Vi = V(:, 1:rank);
            V1 = Vi(1:L, :);
            V2 = Vi(2:L+1, :);
            
            % Calculate pencil matrix
            a = pinv(conj(V1')) * conj(V2');
            
            % Calculate eigenvalues (modes)
            z = eig(a);
            
            % Convert to frequency and damping
            samplingRate = params.samplingRate;
            amos = 1/samplingRate;
            z_s = log(z) * samplingRate;
            frequencies = angle(z) / (2*pi*amos);
            dampingFactor = real(z_s);
            dampingPercent = (-real(z_s) ./ abs(z_s)) * 100;
            
            % Calculate amplitudes and phases
            Z = [];
            for i = 1:L
                Z(i, :) = z.^(i-1);
            end
            
            Hi = (Z^-1) * signalSegment(1:L)';
            amplitudes = abs(Hi);
            phases = angle(Hi);
            
            % Filter modes
            freqFilter = params.frequencyFilter;
            validModes = frequencies < freqFilter & frequencies > 0.009 & dampingPercent < 40;
            
            % Store result
            result = struct();
            result.modes = z(validModes);
            result.frequencies = frequencies(validModes);
            result.dampingFactor = dampingFactor(validModes);
            result.dampingPercent = dampingPercent(validModes);
            result.amplitudes = amplitudes(validModes);
            result.phases = phases(validModes);
            result.energy = obj.calculateEnergy(z(validModes), amplitudes(validModes), N);
        end
        
        function energy = calculateEnergy(obj, modes, amplitudes, N)
            %CALCULATEENERGY Calculate energy for each mode
            n = 0:(N-1);
            energy = zeros(length(modes), 1);
            
            for i = 1:length(modes)
                energy(i) = abs(amplitudes(i)^2) * sum(abs(modes(i).^n).^2);
            end
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
                error('MatrixPencilAnalysisService:MissingSamplingRate', 'Sampling rate is required');
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
            
            if isfield(parameters, 'frequencyFilter')
                params.frequencyFilter = parameters.frequencyFilter;
            else
                params.frequencyFilter = 0.01;
            end
        end
    end
end



