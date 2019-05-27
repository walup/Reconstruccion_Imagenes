classdef RayPoint 
    
    properties
        x;
        y;
    end
    
    methods
        function obj = setRayPoint(obj,x,y)
            obj.x = x;
            obj.y  = y;
        end
    end
end