classdef IQueryRepository < handle
    %IQUERYREPOSITORY Interface for query data persistence
    %   Defines contract for loading and saving queries
    
    methods (Abstract)
        query = loadQuery(obj, queryName)
        %LOADQUERY Load query from storage
        %   queryName - Name of the query to load
        %   Returns: Query domain object
        
        saveQuery(obj, query)
        %SAVEQUERY Save query to storage
        %   query - Query domain object to save
        
        queryNames = listQueries(obj)
        %LISTQUERIES List all available query names
        %   Returns: Cell array of query names
    end
end

