classdef ISymmetricalComponentService < handle
    %ISYMMETRICALCOMPONENTSERVICE Interface for symmetrical component calculations
    %   Defines contract for calculating positive, negative, and zero sequence components
    
    methods (Abstract)
        [positiveSeq, negativeSeq, zeroSeq] = calculate(obj, pmu)
        %CALCULATE Calculate symmetrical components
        %   pmu - PMU domain object
        %   Returns:
        %       positiveSeq - [samples x 5] positive sequence data
        %       negativeSeq - [samples x 4] negative sequence data
        %       zeroSeq - [samples x 4] zero sequence data
    end
end



