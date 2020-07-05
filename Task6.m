clc
clear
close all
run('vlfeat/vlfeat-0.9.21/toolbox/vl_setup')

peakThresh = 7.65;
edgeThresh = 10;
nSubsetPoints = 5;
errorThresh = 1;
nRuns = 50000;
middleImage = 2;

%% Load images
images{1} = imread('images/im01.jpg');
images{2} = imread('images/im02.jpg');
images{3} = imread('images/im03.jpg');
images{4} = imread('images/im04.jpg');
images{5} = imread('images/im05.jpg');

for i = 1:length(images)
    I = single(rgb2gray(images{i})) ;
    [sift{i}.features,sift{i}.descriptors] = vl_sift(I,'PeakThresh', peakThresh, 'EdgeThresh',edgeThresh) ;
end


stitchedImage = images{middleImage};
stitchedImageRef = imref2d(size(images{middleImage}));

%% Stitch images to the left
direction = -1;
for i = middleImage:direction:2
    [matchResult{i}.matches, matchResult{i}.scores] = matchDescriptors(sift{i}.descriptors, sift{i+direction}.descriptors,1) ;
    %% Perform RANSAC without bundle adjustment
    [h{i},inlierIdx{i}] = performRansac(sift{i}.features,sift{i+direction}.features,matchResult{i}.matches,nSubsetPoints,errorThresh,nRuns,false);
    tform = projective2d(h{i});    
    [transformedImage,transformedImageRef] = imwarp(images{i+direction},tform);
    sift{i+direction}.features = applyHomographyToFeatures(h{i},sift{i+direction}.features);
    
    [stitchedImage, stitchedImageRef] = mergeImages(stitchedImage,stitchedImageRef,transformedImage,transformedImageRef,'image2');

    figure; image(stitchedImageRef.XWorldLimits, stitchedImageRef.YWorldLimits, stitchedImage) 
end

%% Stitch images to the right
direction = 1;
for i = middleImage:direction:4
    [matchResult{i}.matches, matchResult{i}.scores] = matchDescriptors(sift{i}.descriptors, sift{i+direction}.descriptors,1) ;

    [h{i},inlierIdx{i}] = performRansac(sift{i}.features,sift{i+direction}.features,matchResult{i}.matches,nSubsetPoints,errorThresh,nRuns,false);
    tform = projective2d(h{i});    
    [transformedImage,transformedImageRef] = imwarp(images{i+direction},tform);
    sift{i+direction}.features = applyHomographyToFeatures(h{i},sift{i+direction}.features);
    
    [stitchedImage, stitchedImageRef] = mergeImages(stitchedImage,stitchedImageRef,transformedImage,transformedImageRef,'image2');

    figure; image(stitchedImageRef.XWorldLimits, stitchedImageRef.YWorldLimits, stitchedImage) 

end

