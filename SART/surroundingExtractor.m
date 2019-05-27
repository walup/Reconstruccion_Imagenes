function surroundings = surroundingExtractor(ray,grid,coeffs,base)
%The ray we are receiving has some points
surroundings = {};
for i = 1:length(ray)
   point = ray(i);
   %Find the points and the indexes
   [points,inds] = grid.getSurroundingPoints(point.x,point.y);
   surrounder = [];
   for s = 1:4
      point = points(:,s);
      index = inds(:,s);
      surrPoint = RayPointSurrounder();
      surrPoint = surrPoint.initDefault();
      if(index(1)~= 0 && index(2)~=0  && grid.grid(index(1),index(2),1)~= 0)
          surrPoint.x = point(1);
          surrPoint.y = point(2);
          
          surrPoint.index = grid.grid(index(1),index(2),1);
          surrPoint.funcVal = base.getFuncVal(surrPoint.index,coeffs);
      end
      surrounder = [surrounder,surrPoint];
   end
   surroundings{end+1} = surrounder; 
    
end



end