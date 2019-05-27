classdef Rays 
   properties
      rays;
      angledRays;
      numberOfRays;
      raySurroundings;
   end
   
   
   methods
       %Parallel implemented method 
       %To create the rays with its
       %own progress bar. 
       function obj = createRays(obj,grid,sinogram,deltaS,projectionSize,deltaAngle,base,g)
          projections = size(sinogram,2);
          %Initialize the ray matrix. 
          rays= cell(projectionSize,projections);
          raySurroundings = cell(projectionSize,projections);
          %Angles to rotate the grid
          maxAngle = projections;
          angles = 0:deltaAngle:maxAngle-1;
          xRays = 1:deltaS:projectionSize;
   
          %Create the waitbar 
          D = parallel.pool.DataQueue;
          h = waitbar(0, 'Creating rays');
          afterEach(D, @nUpdateWaitbar);
          p = 1;
          N = length(angles);
          X = grid.grid(:,:,2);
          Y = grid.grid(:,:,3);
          parfor i = 1:length(angles)
              send(D,i);
              %Define the rotation matrix
              R = [cosd(-angles(i)) -sind(-angles(i));sind(-angles(i)) cosd(-angles(i))];
              for j = 1:projectionSize
                  %Create the ray
                  ray = [];
                  for m = 1:length(xRays)
                      pointX = xRays(m)*grid.L/grid.physLength-grid.circle.centerX;
                      pointY = j*grid.L/grid.physLength-grid.circle.centerY;
                      rotPoint = R*[pointX;pointY];
                      rotPoint(1) = rotPoint(1)+grid.circle.centerX;
                      rotPoint(2) = rotPoint(2)+grid.circle.centerY;
                      %If the point is inside the circle we add it to the
                      %ray 
                      if(grid.circle.isInsideCircle(rotPoint(1),rotPoint(2)))
                          rayPoint = RayPoint();
                          rayPoint.x = (rotPoint(1))*grid.physLength/grid.L;
                          rayPoint.y = (rotPoint(2))*grid.physLength/grid.L;
                          ray = [ray,rayPoint];
                      end
                  end
                  %Add the new ray to the array
                  rays{j,i} = ray;
              end
          end
          obj.angledRays = rays;
          obj.rays = rays;
          obj.numberOfRays = size(obj.rays,1)*size(obj.rays,2);
          %obj.rays = reshape(obj.rays,[obj.numberOfRays,1]);
          delete(h);
        function nUpdateWaitbar(~)
        waitbar(p/N, h);
        p = p + 1;
        end
       end
       
       
           
           

       
       function y = drawRays(obj,angle,grid)
           gridImage = grid.showGrid();
           
           figure();
           %Draw the grid 
           imagesc(gridImage),colormap gray
           hold on;
           %We get the rays corresponding to the angle
           angleRays = obj.angledRays(:,angle);
           %Select 10 rays
           delta = floor(length(angleRays)/10);
           raysToDraw = 1:delta:length(angleRays);
           disp(length(angleRays));
           for r = raysToDraw
               ray = angleRays{r};
               for j = 1:length(ray)
                   plot(ray(j).x*grid.L/grid.physLength,ray(j).y*grid.L/grid.physLength,'.','MarkerSize',10);
               end
           end
           hold off;
           y = 1;
       end
       
          end
       end
      