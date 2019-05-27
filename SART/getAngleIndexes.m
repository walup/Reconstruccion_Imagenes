%Kak in his book says that you should iterate not in sequential order. but
%with an angle delta of 73.8°

function angles = getAngleIndexes(maxAngle)

ordered = 1:1:maxAngle;
delta = 73.8;
angles = zeros(length(ordered),1);
angles(1) = ordered(1);
for i = 2:length(ordered)
    newAngle = ceil(mod(angles(i-1)+delta,maxAngle));
    angles(i) = newAngle;
end

end



