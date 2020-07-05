function [outputH, inlierIdx]= performRansac(mappedFeatures,initialFeatures,matches,nPoints,threshold,nRuns,bundleAdjust)
mappedPoints = mappedFeatures(1:2,matches(1,:))';
initialPoints = initialFeatures(1:2,matches(2,:))';
maxInliers = 0;
outputH = eye(3);
inlierIdx = [];
for i =1:nRuns
    perm = randperm(size(matches,2)) ;
    selectedMatches = matches(:,perm(1:nPoints));
    selectedMappedPoints = mappedFeatures(1:2,selectedMatches(1,:))';
    selectedInitialPoints = initialFeatures(1:2,selectedMatches(2,:))';


    h = computeHomographyMat(selectedInitialPoints,selectedMappedPoints);


    initialPoints(:,3) = 1;
    transformedPoints = h'*initialPoints';
    transformedPoints = transformedPoints';
    transformedPoints = transformedPoints./transformedPoints(:,3);
    transformedPoints = transformedPoints(:,1:2);
    errors = sum((transformedPoints-mappedPoints).^2,2);
    
    
    numInliers = sum(errors<threshold);
    if(numInliers>maxInliers) 
%         i
        maxInliers = numInliers;
        display(['iteration ' num2str(i) ': ' num2str(maxInliers) ' inliers'])
        inlierIdx = find(errors<threshold);
        outputH = h;
        
    end
end

if (isempty(inlierIdx))
    outputH = [];

else
    targetInliers = mappedPoints(inlierIdx,:);
    targetInliers(:,3) = 1;
    initialInliers = initialPoints(inlierIdx,:);

    
    outputH = computeHomographyMat(initialInliers,targetInliers);
%     outputH = outputH./outputH(3,3);
    if(bundleAdjust)
        outputH = bundleAdjustment(outputH,initialInliers,targetInliers);
    end
    
    display('-------------------')
end




