function outputImage = stitchImage(image1,image2)
peakThresh = 7.65;
edgeThresh = 10;
nSubsetPoints = 5;
errorThresh = 10;
nRuns = 500000;

%% Load and get SIFT descriptors for image 1

I1 = single(rgb2gray(image1)) ;
[f1,d1] = vl_sift(I1,'PeakThresh', peakThresh, 'EdgeThresh',edgeThresh) ;

% figure(1);
% subplot(1,2,1); image(image1) ;
% h1 = vl_plotsiftdescriptor(d1(:,1:end),f1(:,1:end)) ;
% set(h1,'color','y') ;

%% Load and get SIFT descriptors for image 2
I2 = single(rgb2gray(image2)) ;
[f2,d2] = vl_sift(I2,'PeakThresh', peakThresh, 'EdgeThresh',edgeThresh) ;

% subplot(1,2,2); image(image2) ;
% h2 = vl_plotsiftdescriptor(d2(:,1:end),f2(:,1:end)) ;
% set(h2,'color','y') ;

%% Match descriptors
[matches, scores1] = matchDescriptors(d1, d2) ;
[scores1, sortInd] = sort(scores1,'ascend');
matches = matches(:,sortInd);

%% Perform ransac
[h, inlierIdx] = performRansac(f1(1:2,:),f2(1:2,:),matches,5,10,500000);

%% Apply Homography
image1Ref = imref2d(size(image1));
tform = projective2d(h);
[image2Trans,image2TransRef] = imwarp(image2,tform,'FillValues',-1);
outputImage = mergeImages(image1,image1Ref,image2Trans,image2TransRef,'image2');

%% Plot matches
maxHeight = max(size(image1,1),size(image2,1));
maxWidth = max(size(image1,2),size(image2,2));

imagePad1 = zeros(maxHeight,maxWidth,3);
imagePad2 = zeros(maxHeight,maxWidth,3);
imagePad1(1:size(image1,1),1:size(image1,2),1:3) = image1;
imagePad2(1:size(image2,1),1:size(image2,2),1:3) = image2;

imageMerge = uint8(cat(2,imagePad1,imagePad2));
figure; imshow(imageMerge)

selMatch = matches(:,inlierIdx);
matchLoc1 = f1(1:2,selMatch(1,:));
matchLoc2 = f2(1:2,selMatch(2,:));
matchLoc2(1,:) = matchLoc2(1,:) + size(imagePad1,2);

hold on ;
l = line([matchLoc1(1,:) ; matchLoc2(1,:)], [matchLoc1(2,:) ; matchLoc2(2,:)]) ;
set(l,'linewidth', 1) 

