function dVals = bilinearInterpolation(X,Y,funcVals,x,y)
%Get the important points
dVals = zeros(1,4);
%Get the coordinates
x0 = X(1);
y0 = Y(1);
x1 = X(4);
y1 = Y(4);
Zs = funcVals;
d1 = (1/((x1-x0)*(y1-y0)))*(x1-x)*(y1-y);
d2 = (1/((x1-x0)*(y1-y0)))*(x-x0)*(y1-y);
d3 = (1/((x1-x0)*(y1-y0)))*(x1-x)*(y-y0);
d4 = (1/((x1-x0)*(y1-y0)))*(x-x0)*(y-y0);
z = d1*Zs(1)+d2*Zs(2)+d3*Zs(3)+d4*Zs(4);
  
if(isnumeric(z) && ~isinf(z) && ~isnan(z))
    dVals =[d1;d2;d3;d4];
end
end