classdef IndexedGrid
   properties
       L;
       grid;
       count;
       projectionsLength;
   end
   
   methods
       function obj = setGrid(obj,L,projectionsLength)
          obj.L = L;
          obj.projectionsLength = projectionsLength;
          %Create a grid of size L 
          grid = zeros(L,L,4);
          %Index the first layer of the grid
          index = 1;
          for i = 1:L
              for j = 1:L
                  grid(i,j,1) = index;
                  index = index+1;
              end
          end
          obj.count = index-1;
          %The second layer will be equal to the 
          %x points of the grid
          for i = 1:L-1
            grid(:,i,2) = (2*i+1)*projectionsLength/(2*L);
          end
          grid(:,L,2) = projectionsLength;
          %The third layer will be equal to the 
          %y points of the grid
          for j = 1:L-1
              grid(j,:,3) = (2*j+1)*projectionsLength/(2*L);
          end
          grid(L,:,3) = projectionsLength;
          
          obj.grid = grid;
       end
       
       %Function to rotate the grid. 
       function grid = rotate(obj,angle)
          grid = obj;
          grid.grid(:,:,1) = imrotate(grid.grid(:,:,1),-angle,'crop');
          grid = grid.reindex();
       end
       
       function obj = reindex(obj)
          for i = 1:obj.L-1
            obj.grid(:,i,2) = (2*i+1)*obj.projectionsLength/(2*obj.L);
          end
          obj.grid(:,obj.L,2) = obj.projectionsLength;
          %The third layer will be equal to the 
          %y points of the grid
          for j = 1:obj.L-1
              obj.grid(j,:,3) = (2*j+1)*obj.projectionsLength/(2*obj.L);
          end
          obj.grid(obj.L,:,3) = obj.projectionsLength;
           
       end
       
       
       function obj = setValues(obj,values)
           for i = 1:length(values)
               for m = 1:obj.L
                   for n = 1:obj.L
                       if(obj.grid(m,n,1) == i)
                           obj.grid(m,n,4) = values(i);
                           continue;
                       end
                   end
               end
           end
       end
       
       function valLayer = getValuesLayer(obj)
          valLayer = obj.grid(:,:,4); 
       end
       
       function grd = drawGridWithRay(obj,ray)
           grd = zeros(obj.L,obj.L);
           
           for i = 1:obj.L
               for j = 1:obj.L
                   if(obj.grid(i,j,1) ~=0)
                       grd(i,j) = 255;
                   else
                       grd(i,j) = 0;
                   end
               end
           end
           figure()
           imagesc(grd),colormap gray
           hold on; 
            for i = 1:obj.L
               for j = 1:obj.L
                   if(obj.grid(i,j,1) ~=0 && ray.containsPoint(obj.grid(i,j,2),obj.grid(i,j,3)))
                       plot((obj.grid(i,j,2)*(obj.L/obj.projectionsLength)), obj.grid(i,j,3)*(obj.L/obj.projectionsLength), '.', 'MarkerSize', 10);
                   else
                       grd(i,j) = 0;
                   end
               end
           end
           hold off;
           
               end
           end
           
           
           
       end
       
    
   