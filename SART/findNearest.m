function [yInd,xInd] = findNearest(x,y,X,Y)
    %Lets start in the middle 
    row = floor(size(X,1)/2);
    col = floor(size(Y,2)/2);
    xInd = 1;
    yInd = 1;
    for i = 1:size(X,2)
        if(x<X(row,i))
            xInd = i;
            break;
        end
    end
    
    for j = 1:size(Y,1)
       if(y<Y(j,col))
          yInd = j;
          break;
       end
    end
end