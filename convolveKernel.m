function [out] = convolveKernel(image,kernel)

sizeImage = size(image);
sizeKernel = size(kernel);

for i=1:sizeImage(1)-sizeKernel(1)+1
    for j=1:sizeImage(2)-sizeKernel(2)+1
        out(i,j) = sum(sum(image(i:i+sizeKernel(1)-1,j:j+sizeKernel(2)-1).*kernel));
    end
end
