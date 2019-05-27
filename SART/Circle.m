 classdef Circle
    properties 
       radius;
       centerX;
       centerY;
    end
    
    methods
        function obj = setCircle(obj,centerX,centerY,radius)
           obj.centerX = centerX;
           obj.centerY = centerY;
           obj.radius = radius;
            
        end
        %Function to check if a point is inside the circle
        function y = isInsideCircle(obj,pointX,pointY) 
           if(sqrt((pointX-obj.centerX)^2 +(pointY-obj.centerY)^2)<obj.radius)
               y = true;
           else
               y = false;
           end
        end
        
        
    end
     
     
 end