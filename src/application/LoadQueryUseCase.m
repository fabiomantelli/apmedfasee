classdef LoadQueryUseCase < handle
    %LOADQUERYUSECASE Use case for loading a query
    %   Orchestrates loading query data from repository
    
    properties (Access = private)
        repository = [];
    end
    
    methods
        function obj = LoadQueryUseCase(repository)
            %LOADQUERYUSECASE Constructor
            %   repository - IQueryRepository implementation
            obj.repository = repository;
        end
        
        function query = execute(obj, queryName)
            %EXECUTE Execute the use case
            %   queryName - Name of query to load
            %   Returns: Query domain object
            
            if isempty(queryName)
                error('LoadQueryUseCase:InvalidInput', 'Query name cannot be empty');
            end
            
            try
                query = obj.repository.loadQuery(queryName);
                
                if ~query.validate()
                    error('LoadQueryUseCase:InvalidQuery', 'Loaded query failed validation');
                end
                
            catch ME
                error('LoadQueryUseCase:LoadFailed', 'Failed to load query: %s', ME.message);
            end
        end
    end
end



