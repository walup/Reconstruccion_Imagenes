classdef Ray
   properties
      %Rays will be rectangles. 
      rectX;
      rectY;
      height;
      width;
   end
   methods
       
       function obj = setRay(obj,rectX,rectY,width,height)
           obj.rectX = rectX;
           obj.rectY = rectY;
           obj.width = width;
           obj.height = height;
           
       end
       %Will check if the rectangle contains
       %A given point. If it does we return 
       %1, else we return 0
       function contains = containsPoint(obj,x,y)
           if(x>obj.rectX && x<obj.rectX+obj.width && y>obj.rectY && y<obj.rectY+obj.height)
              contains = true;
              
           else
               contains = false;
           end
       end
       
       
   end
    
    
    
end