clc
clear
close all

image1 = imread('images/h1.jpg');
image2 = imread('images/h2.jpg');
I1 = rgb2gray(image1);
figure;
ax1 = subplot(1,2,1); 
imshow(image1) ;
title(ax1,'Click a new point here')
ax2 = subplot(1,2,2); 
imshow(image2) ;

colors = ['b','r','y','g'];
testLoc1 = [114,121;
            1099,121;
            121,1079;
            1099,1079];
testLoc2 = [109,222;
            460,74;
            376,471;
            741,287];
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

h1 = computeHomographyMat(points1,points2);
disp((h1./h1(3,3))')
% test1 = h1'*[points1';ones(1,4)];
% test1 = test1./test1(3,:)

tform = projective2d(h1);
imageTrans1 = imwarp(image1,tform);
figure();
subplot(1,2,1);imshow(imageTrans1)
title('h1 mapped to h2')


h2 = computeHomographyMat(points2,points1);
disp((h2./h2(3,3))')
% test2 = h2'*[points1';ones(1,4)];
% test2 = test2./test2(3,:)

tform = projective2d(h2);
imageTrans1 = imwarp(image2,tform);

subplot(1,2,2);imshow(imageTrans1)
title('h2 mapped to h1')

% tform = fitgeotrans(points1,points2,'projective');
% imageTrans2 = imwarp(image1,tform);
% figure;imshow(imageTrans2)
% test3= tform.T'*[points1';ones(1,4)];
% test3 = test3./test3(3,:)
