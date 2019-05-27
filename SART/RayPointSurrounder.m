classdef RayPointSurrounder
    properties
        x;
        y;
        index;
        funcVal;
    end
    
    methods 
        function obj = initDefault(obj)
            obj.x = 0;
            obj.y = 0;
            obj.index = 0;
            obj.funcVal = 0;
        end
    end
    
end