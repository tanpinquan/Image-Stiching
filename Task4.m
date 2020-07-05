clc
clear
close all

image1 = imread('images/im01.jpg');
image2 = imread('images/im02.jpg');
I1 = rgb2gray(image1);
figure(1);
ax1 = subplot(1,2,1); 
imshow(image1) ;
title(ax1,'Click a new point here')
ax2 = subplot(1,2,2); 
imshow(image2) ;

colors = ['b','r','y','g'];
testLoc1 = [328,271;
            489,276;
            329,307;
            490,331];
testLoc2 = [28,297;
            212,301;
            26,337;
            212,354];
for i=1:4
%     dp1 = drawpoint(ax1,'Position',testLoc1(i,:),'Color',colors(i));
    dp1 = drawpoint(ax1,'Color',colors(i));
    title(ax2,'Click a corresponding point here')
    title(ax1,'')
    
    points1(i,:) = dp1.Position;

%     dp2 = drawpoint(ax2,'Position',testLoc2(i,:),'Color',colors(i));
    dp2 = drawpoint(ax2,'Color',colors(i));
    title(ax1,'Click a new point here')
    title(ax2,'')
    
    points2(i,:) = dp2.Position;
     disp([num2str(dp1.Position) '   =>   ' num2str(dp2.Position)])
    A((i-1)*2+1,:) = [dp1.Position(1) dp1.Position(2) 1 0 0 0 -dp2.Position(1)*dp1.Position(1) -dp2.Position(1)*dp1.Position(2) -dp2.Position(1)];
    A((i-1)*2+2,:) = [0 0 0 dp1.Position(1) dp1.Position(2) 1 -dp2.Position(2)*dp1.Position(1) -dp2.Position(2)*dp1.Position(2) -dp2.Position(2)];

end
    title(ax1,'')
    title(ax2,'')

%% Homography
h1 = computeHomographyMat(points2,points1);
disp('Homography matrix:')
disp((h1./h1(3,3))')
test = h1'*[points2';ones(1,4)];
test = test./test(3,:);
% h1 = [1 0 500;0 1 500; 0 0 1]';


image1Ref = imref2d(size(image1));


%% Apply Homography
tform = projective2d(h1);
% [imageTrans2,cb_translated_ref] = imwarp(image2,tform,'OutputView',RA);
[image2Trans,image2TransRef] = imwarp(image2,tform);

stitchedImage = mergeImages(image1,image1Ref,image2Trans,image2TransRef,'average');
figure; imshow(stitchedImage)


% tform = fitgeotrans(points2,points1,'projective')
% imageTrans2 = imwarp(image2,tform);
% figure(4);imshow(imageTrans2)

