classdef IOscillationAnalysisService < handle
    %IOSCILLATIONANALYSISSERVICE Interface for oscillation analysis methods
    %   Defines contract for RBE, Prony, Matrix Pencil, and DFT methods
    
    methods (Abstract)
        result = analyze(obj, signal, parameters)
        %ANALYZE Perform oscillation analysis
        %   signal - Signal data [samples x 1] or [PMUs x samples]
        %   parameters - Structure with analysis parameters
        %   Returns: Result structure with modes, frequencies, damping, etc.
    end
end



