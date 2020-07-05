function numFeatures = numberOverlappedFeatures(fixedImage, movingImage, fixedFeatures, movingFeatures, h)
warning('off','MATLAB:polyshape:repairedBySimplify')
% figure; 
% subplot(1,2,1); image(fixedImage)
% h1 = vl_plotframe(fixedFeatures);
% subplot(1,2,2); image(movingImage)
% h2 = vl_plotframe(movingFeatures);
if(isempty(h))
    numFeatures = 0;
    return
end

fixedImageVertices.x = [1 1 size(fixedImage,2) size(fixedImage,2)];
fixedImageVertices.y = [size(fixedImage,1) 1 1 size(fixedImage,1)];

movingImageVertices.x = [1 1 size(movingImage,2) size(movingImage,2)];
movingImageVertices.y = [size(movingImage,1) 1 1 size(movingImage,1)];

fixedPoly = polyshape(fixedImageVertices.x,fixedImageVertices.y);

mappedVertices = applyHomographyToFeatures(h,[movingImageVertices.x;movingImageVertices.y]);
mappedImageVertices.x = mappedVertices(1,:);
mappedImageVertices.y = mappedVertices(2,:);

mappedPoly = polyshape(mappedImageVertices.x,mappedImageVertices.y);

overlappedPoly = intersect(fixedPoly,mappedPoly);
% 
% figure;plot(fixedPoly)
% hold on;plot(mappedPoly)
% hold on; plot(overlappedPoly);

fixedFeaturePoints.x =  fixedFeatures(1,:);
fixedFeaturePoints.y =  fixedFeatures(2,:);

mappedFeatures = applyHomographyToFeatures(h,movingFeatures);
mappedFeaturePoints.x =  mappedFeatures(1,:);
mappedFeaturePoints.y =  mappedFeatures(2,:);

overlappedFixedFeatures = inpolygon(fixedFeaturePoints.x,fixedFeaturePoints.y,overlappedPoly.Vertices(:,1),overlappedPoly.Vertices(:,2));
overlappedMappedFeatures = inpolygon(mappedFeaturePoints.x,mappedFeaturePoints.y,overlappedPoly.Vertices(:,1),overlappedPoly.Vertices(:,2));

% hold on; plot(fixedFeaturePoints.x,fixedFeaturePoints.y,'.b')
% hold on; plot(fixedFeaturePoints.x(overlappedFixedFeatures),fixedFeaturePoints.y(overlappedFixedFeatures),'.r')
% 
% hold on; plot(mappedFeaturePoints.x,mappedFeaturePoints.y,'.k')
% hold on; plot(mappedFeaturePoints.x(overlappedMappedFeatures),mappedFeaturePoints.y(overlappedMappedFeatures),'.g')

numOverlappedFixedFeatures = sum(overlappedFixedFeatures);
numOverlappedMappedFeatures = sum(overlappedMappedFeatures);
numFeatures = min(numOverlappedFixedFeatures,numOverlappedMappedFeatures);
