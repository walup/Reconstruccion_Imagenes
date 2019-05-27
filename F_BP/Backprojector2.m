classdef Backprojector2
    properties
       sinogram;
       deltaAngle;
       filter;
       imageSize;
       projections;
       projectionSize;
       halfProjections;
       halfProjectionsSize;
       maxAngle;
       W;
       Wmax;
       img;
    end
    
    methods
        %Method to set a sinogram and filter
        function obj = setSinogram(obj,sinogram,filter,maxAngle)
           obj.sinogram = sinogram;
           obj.projections = size(sinogram,2);
           obj.deltaAngle = maxAngle/obj.projections;
           
           %Size of reconstructed image
           obj.projectionSize = size(sinogram,1);
           obj.imageSize = 2*floor(obj.projectionSize/(2*sqrt(2)));
           
           obj.filter = filter;
           obj.maxAngle = maxAngle;
           obj.halfProjections = floor(obj.projections/2);
           obj.halfProjectionsSize = floor(obj.projectionSize/2);
           
           %The famous W in the book
           obj.W = -obj.halfProjectionsSize: obj.halfProjectionsSize;
           obj.Wmax = 2*obj.W/obj.projectionSize;
           obj.Wmax = obj.Wmax(end);
        end
        
        %Method to get the fourier transform of projections  
        function projectionTransf = getFourierTransform(obj)
            projectionTransf = obj.sinogram;
            for j = 1:obj.projections
                for s = 1:obj.projectionSize
                    sum = 0;
                    for i = 1:obj.projectionSize
                        w = obj.W(i);
                        sum = sum + obj.sinogram(i,j)*exp(-1i*2*pi*(obj.W(s)*w/obj.projectionSize));
                    end
                    sum = (1/(2*obj.Wmax))*sum;
                    projectionTransf(s,j) = sum;
                end
            end
        end
        
        
        function filteredProj = filterProjections(obj,projections)
            ramLack = obj.W*(2/obj.projectionSize);
            filtFunc = @(x) FilterDistributer(obj.filter,x,obj.Wmax);
            
            for i = 1:length(ramLack)
                filtArray(i) = filtFunc(ramLack(i));
            end
            filteredProj = [];
            for i = 1:obj.projections
                projection = projections(:,i); 
                for j = 1:obj.projectionSize
                   projection(j) =  projection(j)*abs(ramLack(j))*filtArray(j);
                end
                filteredProj(:,i) = projection; 
            end        
        end
        
        %Inverse fourier
        function invProj = inverseFourier(obj,filteredProjections)
            invProj = [];
            
            for i = 1:obj.projections
                projection = filteredProjections(:,i);
                for k = 1: obj.projectionSize
                    sum = 0;
                    for m = 1: obj.projectionSize
                        sum = sum+projection(m)*exp(2i*pi*((obj.W(m)*obj.W(k))/obj.projectionSize));
                    end
                    invProj(k,i) = real((2*obj.Wmax/obj.projectionSize)*sum);
                end
            end
        end
        
        function obj = backprojection(obj)
            halfSize = obj.imageSize/2;
            img = zeros(obj.imageSize);
            [posX,posY] = meshgrid((1:obj.imageSize)-halfSize);
            %Get the fourier transform of the projections
            freqProjections = obj.getFourierTransform();
            %Apply the filter
            filteredProjections = obj.filterProjections(freqProjections);
            %Get the inverse fourier
            finalProjections = obj.inverseFourier(filteredProjections);
            %Finally backproject into the image
            anglesArray = 0:obj.deltaAngle:obj.maxAngle-obj.deltaAngle;
            finalInterval = obj.W/(obj.Wmax);
            for i = 1:length(anglesArray)
               %Matrix of positions for the current angle 
               pos = posX*cos(anglesArray(i))+posY*sin(anglesArray(i)); 
               %Interpolate and add
               img = img+interp1(finalInterval,finalProjections(:,i),pos); 
            end
            
            %Multiply by the factor
            img = img*(pi/(2*obj.projections));
            %Store the image
            obj.img = img;
        end
            
            
            
        end
        
        
    end
    
    
    
    