%SIRT reconstructor is basically the same as ART
%but updating in iterations is donde differently 
classdef SIRTReconstructor
    
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
          obj.solution = zeros(obj.grid.count,1);
          obj.numberOfProjections = obj.numberOfRays*length(obj.angles);
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
              g = waitbar(0,'Iteration progress');
              waitbar((1/obj.iterations)*i,f,strcat('iteration ',{' '},num2str(i)));
              %Iterate over the system of eqs. 
              delta = zeros(obj.grid.count,1);
              for j = 1:obj.numberOfProjections
                  waitbar((1/obj.numberOfProjections)*j,g);
                  del = obj.p(j)-obj.A(:,j)'*obj.solution;
                  N = sum(obj.A(:,j).^2);
                  if(N~= 0)
                    delta = delta + (del/N)*obj.A(:,j)*obj.relaxation;                    
                  end
              end
              %For SIRT we update at the end of every iteration
              obj.solution = obj.solution+delta/obj.grid.count;
              delete(g);
          end
              
          %Now that we have the solution just reconstruct. 
          obj.grid = obj.grid.setValues(obj.solution);
          obj.img = obj.grid.getValuesLayer();
          delete(f)
       end
       end
       
       
   end
    
    
  