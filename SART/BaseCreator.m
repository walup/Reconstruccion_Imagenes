classdef BaseCreator
    %This class wiil give us an ordered base
    %of the type specified
    properties
       base;
       type;
       baseSize;
       smartIndexing;
    end
    
    methods
        %Function to create a new base
        %Parallelized
        function obj = setNewBase(obj,type,grid)
            %First set the size
            obj.baseSize = grid.count;
            %Set the type
            obj.type = type;
            %The base
            obj.base = zeros(grid.L,grid.L,obj.baseSize);
            obj.smartIndexing = zeros(2,obj.baseSize);
            switch(type)
                %for the unit type case.
                case BaseType.UNIT
                    for i = 1:obj.baseSize
                       mat = zeros(grid.L,grid.L);
                       [m,n] = grid.get2DIndexes(i);
                       mat(m,n) = 1;
                       obj.smartIndexing(1,i) = m;
                       obj.smartIndexing(2,i) = n;
                       obj.base(:,:,i) = mat;
                    end
                    
                %Bilinear type case. 
                case BaseType.BILINEAR
                    smartIndexing = obj.smartIndexing;
                    base = obj.base;
                    parfor i = 1:obj.baseSize
                       colIndexing = zeros(2,1); 
                       mat = zeros(grid.L,grid.L);
                       [m,n] = grid.get2DIndexes(i);
                       mat(m,n) = 1;
                       colIndexing(1) = m;
                       colIndexing(2) = n;
                       for s = m:m+1
                           for k = n:n+1
                               pointX = (2*s+1)/2;
                               pointY = (2*k+1)/2;
                               if(grid.circle.isInsideCircle(pointX,pointY))
                                   mat(s,k) = 1;
                               end
                           end
                       end
                       smartIndexing(:,i) = colIndexing;
                       base(:,:,i) = mat;
                    end
                    obj.smartIndexing = smartIndexing;
                    obj.base = base;
            end
        end
        
        %Function to create a new image as a linear combination
        %of the base
        function img = getImage(obj,coeffs,grid)
            %Create the image
            img = zeros(grid.L,grid.L);
            %Make the linear combinations
            parfor i = 1:obj.baseSize
                img = img+coeffs(i)*obj.base(:,:,i);
            end
        end
        
        function y = getFuncVal(obj,index,coeffs)
           if(index~=0)
              y = coeffs(index);
           else
               y = 0;
           end
        end
        
        
    end
    
end