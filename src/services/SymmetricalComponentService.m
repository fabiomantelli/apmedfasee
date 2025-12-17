classdef SymmetricalComponentService < src.services.ISymmetricalComponentService
    %SYMMETRICALCOMPONENTSERVICE Service for calculating symmetrical components
    %   Implements Fortescue's method for symmetrical component decomposition
    
    methods
        function [positiveSeq, negativeSeq, zeroSeq] = calculate(obj, pmu)
            %CALCULATE Calculate symmetrical components from PMU data
            voltageData = pmu.getVoltageData();
            
            if isempty(voltageData) || size(voltageData, 2) < 7
                error('SymmetricalComponentService:InvalidData', ...
                    'PMU voltage data is invalid or incomplete');
            end
            
            numSamples = size(voltageData, 1);
            
            % Initialize output arrays
            positiveSeq = zeros(numSamples, 5);  % [mod, ang, I_mod, I_ang, freq]
            negativeSeq = zeros(numSamples, 4);  % [mod, ang, I_mod, I_ang]
            zeroSeq = zeros(numSamples, 4);      % [mod, ang, I_mod, I_ang]
            
            % Conversion constants
            angleConv = 2*pi/360;  % degrees to radians
            def3f = 2*pi/3;        % 120 degrees
            a = cos(def3f) + 1i * sin(def3f);  % operator "a"
            aa = a^2;
            
            % Extract voltage phasors
            va_mod = voltageData(:, 2);  % VA_MOD
            va_ang = voltageData(:, 5);  % VA_ANG
            vb_mod = voltageData(:, 3);  % VB_MOD
            vb_ang = voltageData(:, 6);  % VB_ANG
            vc_mod = voltageData(:, 4);  % VC_MOD
            vc_ang = voltageData(:, 7);  % VC_ANG
            
            % Calculate voltage symmetrical components
            for i = 1:numSamples
                va = va_mod(i) * exp(1i * va_ang(i) * angleConv);
                vb = vb_mod(i) * exp(1i * vb_ang(i) * angleConv);
                vc = vc_mod(i) * exp(1i * vc_ang(i) * angleConv);
                
                fasor_sp = (va + vb * a + vc * aa) / 3;
                fasor_sn = (va + vb * aa + vc * a) / 3;
                fasor_s0 = (va + vb + vc) / 3;
                
                positiveSeq(i, 1) = abs(fasor_sp);
                positiveSeq(i, 2) = angle(fasor_sp) / angleConv;
                
                negativeSeq(i, 1) = abs(fasor_sn);
                negativeSeq(i, 2) = angle(fasor_sn) / angleConv;
                
                zeroSeq(i, 1) = abs(fasor_s0);
                zeroSeq(i, 2) = angle(fasor_s0) / angleConv;
            end
            
            % Calculate current symmetrical components if available
            if pmu.hasCurrent
                currentData = pmu.getCurrentData();
                if ~isempty(currentData) && size(currentData, 2) >= 6
                    ia_mod = currentData(:, 1);  % IA_MOD
                    ia_ang = currentData(:, 4);  % IA_ANG
                    ib_mod = currentData(:, 2);  % IB_MOD
                    ib_ang = currentData(:, 5);  % IB_ANG
                    ic_mod = currentData(:, 3);  % IC_MOD
                    ic_ang = currentData(:, 6);  % IC_ANG
                    
                    for i = 1:numSamples
                        ia = ia_mod(i) * exp(1i * ia_ang(i) * angleConv);
                        ib = ib_mod(i) * exp(1i * ib_ang(i) * angleConv);
                        ic = ic_mod(i) * exp(1i * ic_ang(i) * angleConv);
                        
                        fasor_sp = (ia + ib * a + ic * aa) / 3;
                        fasor_sn = (ia + ib * aa + ic * a) / 3;
                        fasor_s0 = (ia + ib + ic) / 3;
                        
                        positiveSeq(i, 3) = abs(fasor_sp);
                        positiveSeq(i, 4) = angle(fasor_sp) / angleConv;
                        
                        negativeSeq(i, 3) = abs(fasor_sn);
                        negativeSeq(i, 4) = angle(fasor_sn) / angleConv;
                        
                        zeroSeq(i, 3) = abs(fasor_s0);
                        zeroSeq(i, 4) = angle(fasor_s0) / angleConv;
                    end
                end
            end
            
            % Calculate frequency from positive sequence angle
            samplingRate = 60;  % Default, should come from query
            for i = 2:numSamples
                diffAngle = positiveSeq(i, 2) - positiveSeq(i-1, 2);
                if diffAngle > 180.0
                    diffAngle = diffAngle - 360;
                elseif diffAngle < -180.0
                    diffAngle = diffAngle + 360;
                end
                positiveSeq(i, 5) = 60.0 + diffAngle * samplingRate / 360;
            end
            if numSamples > 1
                positiveSeq(1, 5) = positiveSeq(2, 5);
            end
        end
    end
end



