classdef SARTReconstructor
    %This is my improved version of the SARTReconstructor
    %i hope to do it very quickly 
   properties
       sinogram;
       iterations;
       outputSize;
       numberOfRays;
       base;
       grid;
       A;
       g;
       deltaS;
       rays;
       img;
       angleDelta;
       p;
       totalNumberOfRays;
       projectionSize;
   end
   methods
       function obj = setSinogram(obj,sinogram,L,iterations)
           %Set the sinogram
           obj.sinogram = sinogram;
           %Create a circular grid
           %The physical length is the projections length
           obj.grid = IndexedMetricalGrid();
           projectionSize = size(sinogram,1);
           obj.grid = obj.grid.setCircularGrid(L,projectionSize);
           %Now, create a base
           obj.base = BaseCreator();
           obj.base = obj.base.setNewBase(BaseType.BILINEAR,obj.grid); 
           obj.numberOfRays = projectionSize;
           obj.totalNumberOfRays = projectionSize*size(sinogram,2);
           %The deltaS should be 1/2 the sampling os the lattice
           obj.deltaS = (1/2)*projectionSize/L;
           disp(obj.deltaS);
           obj.g = zeros(obj.grid.count,1);
           %The output size
           obj.outputSize = 2*floor(projectionSize/(2*sqrt(2)));
           obj.angleDelta = 1;
           %Create the rays 
           obj.rays = Rays();
           obj.rays  = obj.rays.createRays(obj.grid,obj.sinogram,obj.deltaS,projectionSize,obj.angleDelta,obj.base,obj.g);
           %The projections 
           obj.iterations = iterations;
           obj.p = reshape(sinogram,[obj.totalNumberOfRays,1]);
           obj.projectionSize = projectionSize;
       end
       
       function obj = reconstruct(obj)
          for i = 1:obj.iterations
              numAngles = size(obj.sinogram,2);
              %We will iterate over all rays
              %update equation system
              A = zeros(obj.base.baseSize,obj.rays.numberOfRays);
              %Create the waitbar 
              D = parallel.pool.DataQueue;
              h = waitbar(0, 'Reconstructing');
              afterEach(D, @nUpdateWaitbar);
              p = 1;
              N = numAngles;
              angle = 0;
              accumG = zeros(length(obj.g),obj.projectionSize);
              angleIndexes = getAngleIndexes(numAngles);
              for j = 1:length(angleIndexes)
                  send(D,j);
                  %Create the accumulated array
                  accumG = zeros(length(obj.g),obj.projectionSize);
                  for s = 1:obj.projectionSize
                  %Get the ray
                  ray = obj.rays.rays{s,angleIndexes(j)};
                  %Get the points surrounding the points of the ray
                  surr = surroundingExtractor(ray,obj.grid,obj.g,obj.base);
                  Aj = obj.projectRay(ray,surr);
                  ind = (angleIndexes(j)-1)*obj.projectionSize +s;
                  if(sum(Aj)~= 0)
                  accumG(:,s) = ((obj.p(ind)-Aj'*obj.g)/sum(Aj))*Aj;
                  end
                  end
                  obj.g = obj.g+mean(accumG,2);
                  end
          end
          obj.img = obj.base.getImage(obj.g,obj.grid);
          delete(h);
           function nUpdateWaitbar(~)
           waitbar(p/N, h);
           p = p + 1;
           end
       end
       
       function Aj = projectRay(obj,ray,raySurroundings)
           if(~isempty(ray) && ~length(ray)== 0)
           %We will project all the
           %points of the ray 
           d = zeros(length(ray),obj.base.baseSize);
           for i = 1:length(ray)
               point = ray(i);
               pointX = point.x;
               pointY = point.y;
               %Now we interpolate
               %First get the interpolating points
               interPoints = raySurroundings{i};
               %Get the x and y values of the surr
               X = [interPoints.x];
               Y = [interPoints.y];
               Z = [interPoints.funcVal];
               indices = [interPoints.index];
               %Interpolate
               dVals = bilinearInterpolation(X,Y,Z,pointX,pointY);
               %Iterate over the points used to interpolate
               dVal = zeros(obj.base.baseSize,1);
               for m = 1:4
               %Get the dijm
               if(indices(m)~= 0 && obj.g(indices(m))~=0)
                 dVal(indices(m)) = dVals(m);
               end
               d(i,:) = dVal;
               end
           end
           %Obtain the non normalized column
           %First and last rows of d should be normalized
           aCol = sum(d*obj.deltaS,1);
           sumCol = sum(aCol);
           physLength = obj.deltaS*size(d,1);
           if(sumCol~=physLength)
             if(sumCol<physLength)    
             delta = physLength-sumCol;
             delta = delta/(2*obj.base.baseSize*obj.deltaS);
             d(1,:) =  d(1,:)+delta;
             d(length(ray),:) = d(length(ray),:)+delta;
             else
                 delta = sumCol-physLength;
                 delta = -delta/(2*obj.base.baseSize*obj.deltaS);
                 d(1,:) =  d(1,:)+delta;
                 d(length(ray),:) = d(length(ray),:)+delta;
             end
           end
           aCol = sum(d*obj.deltaS,1);
           Aj = aCol';
           else
               Aj = zeros(obj.base.baseSize,1);
           end
       
   end
   
    
    
   end
end