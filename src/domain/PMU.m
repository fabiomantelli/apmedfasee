classdef PMU < handle
    %PMU Domain entity representing a Phasor Measurement Unit
    %   Encapsulates PMU data and behavior
    
    properties
        id = 0;                    % PMU index/identifier
        name = '';                 % PMU name
        baseVoltage = 0;           % Base voltage (kV)
        hasCurrent = false;        % Whether current measurements are available
        hasFrequency = false;      % Whether frequency measurements are available
    end
    
    properties (Access = private)
        voltageData = [];          % Voltage phasor data [samples x 14]
        currentData = [];          % Current phasor data [samples x 6]
        frequencyData = [];        % Frequency data [samples x 1]
        timeVector = [];           % Time vector [samples x 1]
    end
    
    methods
        function obj = PMU(id, name, baseVoltage)
            %PMU Constructor
            if nargin >= 1
                obj.id = id;
            end
            if nargin >= 2
                obj.name = name;
            end
            if nargin >= 3
                obj.baseVoltage = baseVoltage;
            end
        end
        
        function setVoltageData(obj, data)
            %SETVOLTAGEDATA Set voltage phasor data
            %   data - [samples x 14] array with voltage data
            obj.voltageData = data;
        end
        
        function data = getVoltageData(obj)
            %GETVOLTAGEDATA Get voltage phasor data
            data = obj.voltageData;
        end
        
        function setCurrentData(obj, data)
            %SETCURRENTDATA Set current phasor data
            obj.currentData = data;
            obj.hasCurrent = ~isempty(data);
        end
        
        function data = getCurrentData(obj)
            %GETCURRENTDATA Get current phasor data
            data = obj.currentData;
        end
        
        function setFrequencyData(obj, data)
            %SETFREQUENCYDATA Set frequency measurements
            obj.frequencyData = data;
            obj.hasFrequency = ~isempty(data);
        end
        
        function data = getFrequencyData(obj)
            %GETFREQUENCYDATA Get frequency measurements
            data = obj.frequencyData;
        end
        
        function setTimeVector(obj, time)
            %SETTIMEVECTOR Set time vector
            obj.timeVector = time;
        end
        
        function time = getTimeVector(obj)
            %GETTIMEVECTOR Get time vector
            time = obj.timeVector;
        end
        
        function isValid = validate(obj)
            %VALIDATE Validate PMU data integrity
            isValid = ~isempty(obj.name) && ...
                      ~isempty(obj.voltageData) && ...
                      ~isempty(obj.timeVector) && ...
                      size(obj.voltageData, 1) == length(obj.timeVector);
        end
    end
end



