classdef ARTReconstructor
    
   properties
       sinogram;
       relaxation;
       iterations;
       outputSize;
       projectionSize;
       numberOfRays;
       angles;
       solution;
       grid;
       numberOfProjections;
       A;
       p;
       img;
   end
   
   
   methods
       
       function obj = setSinogram(obj,sinogram,relaxation,iterations)
          obj.sinogram = sinogram; 
          obj.relaxation = relaxation;
          obj.iterations =  iterations;
          obj.projectionSize = size(sinogram,1);
          obj.outputSize = 2*floor(obj.projectionSize/(2*sqrt(2)));
          
          obj.projectionSize = size(sinogram,1);
          obj.numberOfRays = obj.projectionSize-1;
          
          maxAngle = size(sinogram,2);
          deltaAngle = 1;
          obj.angles = 0:deltaAngle:maxAngle-1;
          %Create a grid
          obj.grid = IndexedGrid();
          obj.grid = obj.grid.setGrid(obj.outputSize,obj.projectionSize);
          obj.solution = zeros(1,obj.grid.count);
          obj.numberOfProjections = obj.numberOfRays*length(obj.angles);
          
          %The p values
          sinogramP = sinogram(1:obj.numberOfRays,1:length(obj.angles));
          pSize = size(sinogramP,1)*size(sinogramP,2);
          obj.p = reshape(sinogramP,[pSize,1]);
       end
       
       
       %Obtain the system of equations. 
       function obj = obtainEquations(obj)
           %Create the matrix A (it is quite big)
           A = zeros(obj.numberOfRays,length(obj.angles),obj.grid.count);
           %Do a parallel waitbar. 
           D = parallel.pool.DataQueue;
           h = waitbar(0, 'Obtaining equations');
           afterEach(D, @nUpdateWaitbar);
           del = 1;
           N = length(obj.angles);
           %Apply the rays
           parfor i = 1:length(obj.angles)
               send(D,i);
               %Rotate the grid. 
               rotGrid = obj.grid.rotate(obj.angles(i));
               angleA = zeros(obj.numberOfRays,obj.grid.count);
               for j = 1:obj.numberOfRays
                   %Create a row
                   Aj = zeros(1,obj.grid.count);
                   %Create the ray 
                   ray = Ray();
                   ray = ray.setRay(1,j,obj.projectionSize,1);
                   %Now we will check if it intersects the grid points
                   for m = 1:rotGrid.L
                       for n = 1:rotGrid.L
                           %If it does intersect we set the entry to 1. 
                           if(rotGrid.grid(m,n,1)~= 0 && ray.containsPoint(rotGrid.grid(m,n,2),rotGrid.grid(m,n,3)))
                               Aj(rotGrid.grid(m,n,1)) = 1;
                           end
                       end
                   end
                   angleA(j,:) = Aj;
               end
               A(:,i,:) = angleA;
           end
           obj.A = reshape(A,[obj.numberOfProjections,obj.grid.count]);
           delete(h);
           function nUpdateWaitbar(~)
           waitbar(del/N, h);
           del = del + 1;
           end
       end
       
       function obj= reconstruct(obj)
          f = waitbar(0,'Reconstructing '); 
          %Now solve by iterating
          for i = 1:obj.iterations
              waitbar((1/obj.iterations)*i,f,strcat('iteration ',{' '},num2str(i)));
              %Iterate over the system of eqs. 
              for j = 1:obj.numberOfProjections
                  delta = obj.p(j)-obj.A(j,:)*obj.solution'*obj.relaxation;
                  N = sum(obj.A(j,:).^2);
                  if(N~= 0)
                    delta  = (delta/N)*obj.A(j,:);
                    obj.solution = obj.solution+delta;
                  end
              end
          end
              
          %Now that we have the solution just reconstruct. 
          obj.grid = obj.grid.setValues(obj.solution);
          obj.img = obj.grid.getValuesLayer();
          delete(f)
          end
           
       end
       
       
   end
    
    
  