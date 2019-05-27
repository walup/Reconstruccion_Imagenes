%We will create this class called an indexed grid
%Which will store a 2d matrix with 4 layers
%first layer will be an identificator, labels 1,2,3 etc.. second and
%third layers are physical x and y coordinates
%the fourth layer will hold any desired value

classdef IndexedMetricalGrid
    properties
       grid;
       L;
       count;
       physLength;
       circle;
    end
    
    methods
        function obj = setCircularGrid(obj,L,physLength)
            obj.L = L;
            obj.physLength = physLength;
            %Create a square grid. 
            grid  = zeros(L,L,4);
            
            %Index everything that is inside the circle
            centerX = L/2;
            centerY = L/2;
            circle = Circle();
            circle = circle.setCircle(centerX,centerY,L/2);
            obj.circle = circle;
            label = 1;
            %First layer: Labels
            for i = 1:L-1
                for j = 1:L-1
                    pointX = (2*i+1)/2;
                    pointY = (2*j+1)/2;
                    if(circle.isInsideCircle(pointX,pointY))
                        %Label the first layer. 
                        grid(i,j,1) = label;
                        label = label+1;
                        %Physical X in second layer
                        grid(j,i,2) = pointX*physLength/L;
                        %Physical Y in third layer
                        grid(j,i,3) = pointY*physLength/L;
                    else
                        %If its not in the circle its label is zero. 
                        grid(i,j,1) = 0;
                    end
                end
            end
            
            %Store the number of counts. 
            obj.count = label-1;
            %Store the grid. 
            obj.grid = grid;
        end
       
        %Function to show the circle
        function img = showGrid(obj)
           %Create the image.  
           img = zeros(obj.L,obj.L);
           
           for i = 1:obj.L
               for j = 1:obj.L
                   %If the label is 0 set the value as white. 
                   if(obj.grid(i,j,1)~= 0)
                       img(i,j) = 255;
                   %If the label ain't 0 then set the value as 0 (so, the area will be dark)
                   else 
                       img(i,j) = 0;
                   end
               end
           end
           %Show the image. 
           imshow(uint8(img));
        end
        
        function obj = setValue(obj,index,value)
           for i = 1:obj.L
               for j = 1:obj.L
                  if(obj.grid(i,j,1) == index && obj.grid(i,j,1)~=0)
                      %Layer 4 is the value layer
                      obj.grid(i,j,4) = value;
                      break;
                      
                  else
                      disp("Index is not valid.");
                  end
               end 
           end
        end
        %Given an index returns the pair of indexes i,j in the grid
        function [ind1,ind2] = get2DIndexes(obj,index)
             for i = 1:obj.L
               for j = 1:obj.L
                   if(obj.grid(i,j,1) == index)
                       ind1 = i;
                       ind2 = j;
                   end
               end
             end 
        end 
        
        function [points,inds] = getSurroundingPoints(obj,pointX,pointY)
            %Get the indeces of the point
            X = obj.grid(:,:,2);
            Y = obj.grid(:,:,3);
            [yInd,xInd] = findNearest(pointX,pointY,X,Y);
            inds = zeros(2,4);
            points = zeros(2,4);
            if(xInd > 1 && yInd > 1 &&xInd<obj.L && yInd<obj.L)
            %Fill the indices array     
            inds(:,1) = [yInd-1;xInd-1];
            inds(:,2) = [yInd-1;xInd];
            inds(:,3) = [yInd;xInd-1];
            inds(:,4) = [yInd;xInd];
            
            %Fill the positions array
            points(:,1) = [X(yInd-1,xInd-1);Y(yInd-1,xInd-1)];
            points(:,2) = [X(yInd-1,xInd);Y(yInd-1,xInd)];
            points(:,3) = [X(yInd,xInd-1);Y(yInd,xInd-1)];
            points(:,4) = [X(yInd,xInd);Y(yInd,xInd)];
            end
            
        end
       

    end
    
    
    
    
end