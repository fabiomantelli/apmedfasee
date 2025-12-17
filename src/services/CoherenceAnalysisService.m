classdef CoherenceAnalysisService < handle
    %COHERENCEANALYSISSERVICE Service for dynamic coherence analysis
    %   Implements coherence analysis for stability assessment
    
    methods
        function result = analyze(obj, frequencyData, parameters)
            %ANALYZE Perform dynamic coherence analysis
            %   frequencyData - Frequency data [PMUs x samples]
            %   parameters - Structure with:
            %       - windowSize: Temporal window size in samples (default: 10*samplingRate)
            %       - samplingRate: Sampling rate (required)
            %       - varianceWindow: Window size for variance calculation (default: windowSize/2)
            %       - temporalEntropyBins: Number of bins for temporal entropy (default: 20)
            %   Returns: Result structure with coherence matrix, ICG, entropy, and regime signature metrics
            
            % Validate inputs
            if isempty(frequencyData)
                error('CoherenceAnalysisService:EmptyData', 'Frequency data is empty');
            end
            
            [N_pmus, N_samples] = size(frequencyData);
            
            if N_pmus < 2
                error('CoherenceAnalysisService:InsufficientPMUs', ...
                    'At least 2 PMUs required for coherence analysis');
            end
            
            % Set default parameters
            params = obj.setDefaultParameters(parameters);
            
            % Calculate window size
            windowSize = params.windowSize;
            if windowSize > N_samples
                windowSize = round(N_samples / 10);
            end
            if windowSize < 10
                windowSize = 10;
            end
            
            % Calculate number of windows
            N_windows = N_samples - windowSize + 1;
            if N_windows < 1
                N_windows = 1;
                windowSize = N_samples;
            end
            
            % Initialize result arrays
            coherenceMatrix = zeros(N_pmus, N_pmus, N_windows);
            ICG = zeros(1, N_windows);
            entropy = zeros(1, N_windows);
            
            % Calculate coherence for each window
            for t = 1:N_windows
                window = t:(t + windowSize - 1);
                windowData = frequencyData(:, window);
                
                % Calculate coherence matrix for this window
                C_window = obj.calculateCoherenceMatrix(windowData);
                coherenceMatrix(:, :, t) = C_window;
                
                % Calculate ICG (mean of upper triangle, excluding diagonal)
                upperTriIndices = triu(ones(N_pmus), 1) == 1;
                C_edges = C_window(upperTriIndices);
                ICG(t) = mean(C_edges);
                
                % Calculate spatial coherence entropy
                edgeSum = sum(C_edges);
                if edgeSum > 0
                    p_edges = C_edges / edgeSum;
                    p_edges(p_edges == 0) = eps; % Avoid log(0)
                    entropy(t) = -sum(p_edges .* log(p_edges));
                else
                    entropy(t) = 0;
                end
            end
            
            % Calculate regime signature metrics
            % Variância do ICG em janelas deslizantes
            varianceWindow = params.windowSize / 2;
            if isfield(parameters, 'varianceWindow')
                varianceWindow = parameters.varianceWindow;
            end
            varianceWindow = min(max(round(varianceWindow), 3), length(ICG));
            
            if length(ICG) > 1
                if exist('movvar', 'builtin') || exist('movvar', 'file')
                    ICGVariance = movvar(ICG, varianceWindow);
                else
                    % Manual implementation
                    ICGVariance = zeros(size(ICG));
                    for i = 1:length(ICG)
                        inicio = max(1, i - floor(varianceWindow/2));
                        fim = min(length(ICG), i + floor(varianceWindow/2));
                        ICGVariance(i) = var(ICG(inicio:fim));
                    end
                end
            else
                ICGVariance = 0;
            end
            
            % Derivada do ICG (dICG/dt)
            % Assume uniform time spacing - if time vector provided, use it
            if isfield(parameters, 'timeVector') && ~isempty(parameters.timeVector)
                timeVec = parameters.timeVector(1:min(length(parameters.timeVector), N_windows));
                if length(timeVec) > 1
                    dt = mean(diff(timeVec));
                    if dt > 0
                        ICGDerivative = [0, diff(ICG) / dt];
                    else
                        ICGDerivative = zeros(size(ICG));
                    end
                else
                    ICGDerivative = zeros(size(ICG));
                end
            else
                % Use sampling rate to estimate dt
                dt = 1 / params.samplingRate;
                if dt > 0 && length(ICG) > 1
                    ICGDerivative = [0, diff(ICG) / dt];
                else
                    ICGDerivative = zeros(size(ICG));
                end
            end
            
            % Entropia temporal do ICG
            numBins = 20;
            if isfield(parameters, 'temporalEntropyBins')
                numBins = parameters.temporalEntropyBins;
            end
            ICGTemporalEntropy = obj.calculateTemporalEntropy(ICG, numBins);
            
            % Store result
            result = struct();
            result.coherenceMatrix = coherenceMatrix;
            result.ICG = ICG;
            result.spatialEntropy = entropy;  % Renamed for clarity
            result.ICGVariance = ICGVariance;
            result.ICGDerivative = ICGDerivative;
            result.ICGTemporalEntropy = ICGTemporalEntropy;
            result.windowSize = windowSize;
            result.numWindows = N_windows;
        end
        
        function C = calculateCoherenceMatrix(obj, data)
            %CALCULATECOHERENCEMATRIX Calculate coherence matrix for data window
            %   data - [PMUs x samples] frequency data
            [N_pmus, ~] = size(data);
            C = zeros(N_pmus, N_pmus);
            
            for i = 1:N_pmus
                for j = 1:N_pmus
                    if i == j
                        C(i, j) = 1.0; % Coherence with itself = 1
                    else
                        signal_i = data(i, :);
                        signal_j = data(j, :);
                        
                        % Remove mean
                        signal_i = signal_i - mean(signal_i);
                        signal_j = signal_j - mean(signal_j);
                        
                        % Calculate normalized cross-correlation
                        if std(signal_i) > 0 && std(signal_j) > 0
                            correlation = corrcoef(signal_i, signal_j);
                            C(i, j) = abs(correlation(1, 2));
                        else
                            C(i, j) = 0;
                        end
                    end
                end
            end
        end
        
        function params = setDefaultParameters(obj, parameters)
            %SETDEFAULTPARAMETERS Set default parameter values
            params = struct();
            
            if isfield(parameters, 'windowSize')
                params.windowSize = parameters.windowSize;
            else
                params.windowSize = 10; % Will be multiplied by sampling rate
            end
            
            if isfield(parameters, 'samplingRate')
                params.samplingRate = parameters.samplingRate;
                params.windowSize = params.windowSize * params.samplingRate;
            else
                error('CoherenceAnalysisService:MissingSamplingRate', 'Sampling rate is required');
            end
        end
        
        function H_temporal = calculateTemporalEntropy(obj, ICG, num_bins)
            %CALCULATETEMPORALENTROPY Calculate temporal entropy of ICG
            %   ICG: Time series of Global Coherence Index
            %   num_bins: Number of bins for discretization (default: 20)
            %   Returns: Shannon entropy of temporal distribution
            
            if nargin < 3
                num_bins = 20;
            end
            
            if isempty(ICG) || length(ICG) < 2
                H_temporal = 0;
                return;
            end
            
            % Normalize ICG to [0, 1]
            ICG_normalized = ICG;
            ICG_min = min(ICG);
            ICG_max = max(ICG);
            if ICG_max > ICG_min
                ICG_normalized = (ICG - ICG_min) / (ICG_max - ICG_min);
            end
            
            % Discretize ICG into bins
            edges = linspace(0, 1, num_bins + 1);
            counts = histcounts(ICG_normalized, edges);
            
            % Calculate probability distribution
            total = sum(counts);
            if total > 0
                p = counts / total;
                % Remove zeros to avoid log(0)
                p(p == 0) = [];
                % Calculate Shannon entropy (base 2)
                if ~isempty(p)
                    H_temporal = -sum(p .* log2(p));
                else
                    H_temporal = 0;
                end
            else
                H_temporal = 0;
            end
        end
    end
end



