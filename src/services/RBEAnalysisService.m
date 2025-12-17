classdef RBEAnalysisService < src.services.IOscillationAnalysisService
    %RBEANALYSISSERVICE Service for RBE (Realization-Based Estimation) analysis
    %   Implements the RBE method for identifying oscillation modes
    
    methods
        function result = analyze(obj, signal, parameters)
            %ANALYZE Perform RBE analysis
            %   signal - Signal data [PMUs x samples]
            %   parameters - Structure with:
            %       - modelOrder: Model order (default: 20)
            %       - blockSize: Number of block rows (default: 80)
            %       - windowSize: Window size in samples (default: 600*samplingRate)
            %       - windowStep: Window step in samples (default: 60*samplingRate)
            %       - samplingRate: Sampling rate (required)
            %       - timeStart: Start time index (default: 1)
            %       - timeEnd: End time index (default: length(signal))
            %       - removeTrend: Remove trend flag (default: false)
            %       - frequencyRange: [min max] frequency range (default: [0.1 3.0])
            %   Returns: Result structure with modes, frequencies, damping, amplitudes
            
            % Validate inputs
            if isempty(signal)
                error('RBEAnalysisService:EmptySignal', 'Signal is empty');
            end
            
            % Set default parameters
            params = obj.setDefaultParameters(parameters);
            
            % Extract signal segment
            t1 = params.timeStart;
            t2 = params.timeEnd;
            signalSegment = signal(:, t1:t2);
            
            % Remove trend if requested
            if params.removeTrend
                for i = 1:size(signalSegment, 1)
                    signalSegment(i, :) = detrend(signalSegment(i, :));
                end
            end
            
            % Initialize result structure
            result = struct();
            result.modes = [];
            result.frequencies = [];
            result.damping = [];
            result.amplitudes = [];
            result.phases = [];
            result.windows = [];
            
            % Process in windows
            windowSize = params.windowSize;
            windowStep = params.windowStep;
            Ntot = size(signalSegment, 2);
            
            ini_control = 1;
            fim_control = min(windowSize, Ntot);
            windowIdx = 1;
            
            while fim_control <= Ntot
                % Extract window
                windowSignal = signalSegment(:, ini_control:fim_control);
                
                % Perform RBE analysis on window
                windowResult = obj.analyzeWindow(windowSignal, params);
                
                % Store results
                result.windows{windowIdx} = windowResult;
                result.modes = [result.modes; windowResult.modes];
                result.frequencies = [result.frequencies; windowResult.frequencies];
                result.damping = [result.damping; windowResult.damping];
                result.amplitudes = [result.amplitudes; windowResult.amplitudes];
                
                % Move window
                ini_control = ini_control + windowStep;
                fim_control = min(ini_control + windowSize - 1, Ntot);
                windowIdx = windowIdx + 1;
                
                if fim_control - ini_control < windowSize / 2
                    break;
                end
            end
            
            % Filter by frequency range
            freqMask = result.frequencies >= params.frequencyRange(1) & ...
                      result.frequencies <= params.frequencyRange(2);
            result.frequencies = result.frequencies(freqMask);
            result.damping = result.damping(freqMask);
            result.amplitudes = result.amplitudes(freqMask);
            result.modes = result.modes(freqMask);
        end
        
        function windowResult = analyzeWindow(obj, signal, params)
            %ANALYZEWINDOW Analyze a single window using RBE method
            [p, Ndat] = size(signal);
            k = params.modelOrder;
            
            % Build data matrix Y
            N = Ndat - 2*k;
            if N <= 0
                error('RBEAnalysisService:InsufficientData', ...
                    'Insufficient data for RBE analysis');
            end
            
            Y = [];
            for i = 1:2*k*p-p+1
                ii = floor((i-1)/p) + 1;
                colIdx = ii:(ii+N-1);
                if max(colIdx) <= size(signal, 2)
                    Y(i:i+p-1, :) = signal(:, colIdx);
                end
            end
            
            Yp = Y(1:k*p, :);
            Yf = Y(k*p+1:2*k*p, :);
            
            % LQ decomposition
            H = [Yp; Yf];
            [QQ, L] = qr(H', 0);
            L = L' / sqrt(N);
            
            L11 = L(1:k*p, 1:k*p);
            L21 = L(k*p+1:2*k*p, 1:k*p);
            L22 = L(k*p+1:2*k*p, k*p+1:2*k*p);
            
            % Covariance matrices
            Rff = (L21*L21' + L22*L22');
            Rfp = L21*L11';
            Rpp = L11*L11';
            
            % Square roots & inverses
            [Uf, Sf, Vf] = svd(Rff);
            [Up, Sp, Vp] = svd(Rpp);
            Sf = sqrtm(Sf);
            Sp = sqrtm(Sp);
            L = Uf*Sf*Vf';
            M = Up*Sp*Vp';
            Sfi = inv(Sf);
            Spi = inv(Sp);
            Linv = Vf*Sfi*Uf';
            Minv = Vp*Spi*Up';
            
            OC = Linv*Rfp*Minv';
            [UU, SS, VV] = svd(OC);
            
            n = params.modelOrder;
            S = SS(1:n, 1:n);
            Ok = L*UU(:, 1:n)*sqrtm(S);
            
            % Calculate system matrix A
            A = Ok(1:k*p-p, :)\Ok(p+1:k*p, :);
            
            % Calculate eigenvalues (modes)
            z = eig(A);
            
            % Convert to frequency and damping
            amos = 1/params.samplingRate;
            z_s = log(z) / amos;
            damping = (-real(z_s) ./ (real(z_s).^2 + imag(z_s).^2).^0.5) * 100;
            frequencies = angle(z) / (2*pi*amos);
            
            % Calculate amplitudes
            Z = [];
            for loop = 1:Ndat
                Z(loop, :) = z.^(loop-1);
            end
            Z = pinv(Z);
            
            ampl = [];
            for i = 1:size(signal, 1)
                Y_res = signal(i, 1:Ndat)';
                res = Z*Y_res;
                ampl(:, i) = abs(res);
            end
            ampl = mean(ampl, 2);
            
            % Store window result
            windowResult = struct();
            windowResult.modes = z;
            windowResult.frequencies = frequencies;
            windowResult.damping = damping;
            windowResult.amplitudes = ampl;
        end
        
        function params = setDefaultParameters(obj, parameters)
            %SETDEFAULTPARAMETERS Set default parameter values
            params = struct();
            
            if isfield(parameters, 'modelOrder')
                params.modelOrder = parameters.modelOrder;
            else
                params.modelOrder = 20;
            end
            
            if isfield(parameters, 'blockSize')
                params.blockSize = parameters.blockSize;
            else
                params.blockSize = 80;
            end
            
            if isfield(parameters, 'samplingRate')
                params.samplingRate = parameters.samplingRate;
            else
                error('RBEAnalysisService:MissingSamplingRate', 'Sampling rate is required');
            end
            
            if isfield(parameters, 'windowSize')
                params.windowSize = parameters.windowSize;
            else
                params.windowSize = 600 * params.samplingRate;
            end
            
            if isfield(parameters, 'windowStep')
                params.windowStep = parameters.windowStep;
            else
                params.windowStep = 60 * params.samplingRate;
            end
            
            if isfield(parameters, 'timeStart')
                params.timeStart = parameters.timeStart;
            else
                params.timeStart = 1;
            end
            
            if isfield(parameters, 'timeEnd')
                params.timeEnd = parameters.timeEnd;
            else
                params.timeEnd = [];
            end
            
            if isfield(parameters, 'removeTrend')
                params.removeTrend = parameters.removeTrend;
            else
                params.removeTrend = false;
            end
            
            if isfield(parameters, 'frequencyRange')
                params.frequencyRange = parameters.frequencyRange;
            else
                params.frequencyRange = [0.1 3.0];
            end
        end
    end
end



