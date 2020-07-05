clc
clear
close all
run('vlfeat/vlfeat-0.9.21/toolbox/vl_setup')
vl_version

peakThresh = 7.65;
edgeThresh = 10;

image1 = imread('images/im01.jpg');
imshow(image1) ;
I1 = single(rgb2gray(image1)) ;
[f1,d1] = vl_sift(I1,'PeakThresh', peakThresh, 'EdgeThresh',edgeThresh) ;

perm = randperm(size(f1,2)) ;
sel = perm(1:end);
h1 = vl_plotsiftdescriptor(d1(:,sel),f1(:,sel)) ;
set(h1,'color','y') ;
