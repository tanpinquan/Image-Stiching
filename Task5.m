clc
clear
close all
run('vlfeat/vlfeat-0.9.21/toolbox/vl_setup')
vl_version

peakThresh = 7.65;
edgeThresh = 10;
nSubsetPoints = 5;
errorThresh = 1;
nRuns = 50000;
%% Load and get SIFT descriptors for image 1
image1 = imread('images/im01.jpg');
I1 = single(rgb2gray(image1)) ;
figure(1);
subplot(1,2,1); image(image1) ;

[f1,d1] = vl_sift(I1,'PeakThresh', peakThresh, 'EdgeThresh',edgeThresh) ;
h1 = vl_plotsiftdescriptor(d1(:,1:end),f1(:,1:end)) ;
set(h1,'color','y') ;

%% Load and get SIFT descriptors for image 2
image2 = imread('images/im02.jpg');
I2 = single(rgb2gray(image2)) ;

subplot(1,2,2); image(image2) ;
[f2,d2] = vl_sift(I2,'PeakThresh', peakThresh, 'EdgeThresh',edgeThresh) ;
h2 = vl_plotsiftdescriptor(d2(:,1:end),f2(:,1:end)) ;
set(h2,'color','y') ;

%% Match descriptors
[matches, scores] = matchDescriptors(d1, d2,1) ;
[scores, sortInd] = sort(scores,'ascend');
matches = matches(:,sortInd);

% [matches1, scores1] = vl_ubcmatch(d1, d2,1) ;
% [scores1, sortInd1] = sort(scores1,'ascend');
% matches1 = matches1(:,sortInd);

imageMerge = cat(2,image1,image2);
figure; imshow(imageMerge)

selMatch = matches(:,1:end);
matchLoc1 = f1(1:2,selMatch(1,:));
matchLoc2 = f2(1:2,selMatch(2,:));
matchLoc2(1,:) = matchLoc2(1,:) + size(image1,2);

hold on ;
l = line([matchLoc1(1,:) ; matchLoc2(1,:)], [matchLoc1(2,:) ; matchLoc2(2,:)]) ;
set(l,'linewidth', 1) ;

%% Peform RANSAC

[h, inlierIdx] = performRansac(f1(1:2,:),f2(1:2,:),matches,nSubsetPoints,errorThresh,nRuns,false);

imageMerge = cat(2,image1,image2);
figure; imshow(imageMerge)

selMatch = matches(:,inlierIdx);
matchLoc1 = f1(1:2,selMatch(1,:));
matchLoc2 = f2(1:2,selMatch(2,:));
matchLoc2(1,:) = matchLoc2(1,:) + size(image1,2);

hold on ;
l = line([matchLoc1(1,:) ; matchLoc2(1,:)], [matchLoc1(2,:) ; matchLoc2(2,:)]) ;
set(l,'linewidth', 1) ;


%% Apply Homography
image1Ref = imref2d(size(image1));


tform = projective2d(h);
[image2Trans,image2TransRef] = imwarp(image2,tform,'FillValues',-1);
stitchedImage = mergeImages(image1,image1Ref,image2Trans,image2TransRef,'average');
figure; imshow(stitchedImage)


image2Ref = imref2d(size(image2));

tform = projective2d(inv(h));
[image1Trans,image1TransRef] = imwarp(image1,tform,'FillValues',-1);
stitchedImage = mergeImages(image2,image2Ref,image1Trans,image1TransRef,'average');
figure; imshow(stitchedImage)
