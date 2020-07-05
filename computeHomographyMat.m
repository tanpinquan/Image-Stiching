function h = computeHomographyMat(initialPoints,mappedPoints)

nPoints = size(initialPoints,1);

for i = 1:nPoints
    A((i-1)*2+1,:) = [initialPoints(i,1) initialPoints(i,2) 1 0 0 0 -mappedPoints(i,1)*initialPoints(i,1) -mappedPoints(i,1)*initialPoints(i,2) -mappedPoints(i,1)];
    A((i-1)*2+2,:) = [0 0 0 initialPoints(i,1) initialPoints(i,2) 1 -mappedPoints(i,2)*initialPoints(i,1) -mappedPoints(i,2)*initialPoints(i,2) -mappedPoints(i,2)]; 
     
end


[U,D,V] = svd(A);
h = V(:,end);
h = reshape(h,[3 3]);



