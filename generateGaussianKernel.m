function kernel = generateGaussianKernel(sigma,kernelSize)
axis = -(kernelSize-1)/2:(kernelSize-1)/2;
for i=1:kernelSize
   for j=1:kernelSize
       kernel(i,j) = exp(-((axis(i)^2+axis(j)^2)/(2*sigma^2)));
       
   end
end

kernel = kernel./sum(kernel(:));