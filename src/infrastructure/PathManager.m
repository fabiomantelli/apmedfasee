classdef PathManager < handle
    %PATHMANAGER Manages MATLAB paths and directory navigation
    %   Provides robust path management for MATLAB 2025 compatibility
    
    methods (Static)
        function rootPath = getRootDirectory()
            %GETROOTDIRECTORY Get root directory of the project
            %   Uses mfilename('fullpath') to find medfasee.m location
            [filePath, ~, ~] = fileparts(mfilename('fullpath'));
            % Navigate up from src/infrastructure to root
            rootPath = fileparts(fileparts(filePath));
        end
        
        function queriesPath = getQueriesDirectory()
            %GETQUERIESDIRECTORY Get path to queries directory
            rootPath = src.infrastructure.PathManager.getRootDirectory();
            queriesPath = fullfile(rootPath, 'consultas');
        end
        
        function graphicsPath = getGraphicsDirectory()
            %GETGRAPHICSDIRECTORY Get path to graphics directory
            rootPath = src.infrastructure.PathManager.getRootDirectory();
            graphicsPath = fullfile(rootPath, 'graficos');
        end
        
        function methodsPath = getMethodsDirectory()
            %GETMETHODSDIRECTORY Get path to methods directory
            rootPath = src.infrastructure.PathManager.getRootDirectory();
            methodsPath = fullfile(rootPath, 'metodos');
        end
        
        function addToPath(directory)
            %ADDTOPATH Add directory to MATLAB path if not already present
            if exist(directory, 'dir')
                if isempty(strfind(path, directory))
                    addpath(directory);
                end
            end
        end
        
        function removeFromPath(directory)
            %REMOVEFROMPATH Remove directory from MATLAB path
            if ~isempty(strfind(path, directory))
                rmpath(directory);
            end
        end
        
        function changeToRoot()
            %CHANGETOROOT Change current directory to project root
            rootPath = src.infrastructure.PathManager.getRootDirectory();
            cd(rootPath);
        end
    end
end

