clc
clear 
close all
run('vlfeat/vlfeat-0.9.21/toolbox/vl_setup')

testImage = imread('images/test_image.png');
% testImage = imread('images/face.jpg');
testImage = double(rgb2gray(testImage));

%% Choose kernel scale (for Gaussian and Haar) and sigma (for gaussian) here
kernelScale = 3;
gaussianSigma = 20;

kernels.sobel.x = [-1 0 1; -2 0 2; -1 0 1];
kernels.sobel.y = [-1 -2 -1; 0 0 0; 1 2 1];
kernels.gaussian = generateGaussianKernel(gaussianSigma,5);
kernels.haar.type1a = generateHaarKernel(1,kernelScale);
kernels.haar.type1b = generateHaarKernel(2,kernelScale);
kernels.haar.type2a = generateHaarKernel(3,kernelScale);
kernels.haar.type2b = generateHaarKernel(4,kernelScale);
kernels.haar.type3 = generateHaarKernel(5,kernelScale);


%% Choose kernel type here based on the names above
selectedKernel = kernels.gaussian;
selectedKernel = fliplr(flipud(selectedKernel));

imageConv = convolveKernel(testImage,selectedKernel);
imageConvDisp = uint8(rescale(imageConv,0, 255));

figure; subplot(1,2,1)
imshow(uint8(testImage));
title('Original Image')

subplot(1,2,2);imshow(imageConvDisp);
title('After convolution')


% kernels.haar.type2a = generateHaarKernel(3,10);
% 
% selectedKernel = kernels.haar.type2a;
% selectedKernel = fliplr(flipud(selectedKernel));
% 
% subplot(1,3,3);imshow( uint8(rescale(convolveKernel(testImage,selectedKernel),0,255)));


% 
% c2 = conv2(testImage,kernels.sobel.x,'valid');
% imageConv = convolveKernel(testImage,kernels.sobel.x);

