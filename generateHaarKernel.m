function kernel = generateHaarKernel(type,scale)

if(type==1)
    kernel = [ones(scale) -1*ones(scale)];
elseif(type==2)
    kernel = [-1*ones(scale);ones(scale)];
elseif(type==3)
    kernel = [ones(scale) -1*ones(scale) ones(scale)];
elseif(type==4)
    kernel = [ones(scale); -1*ones(scale); ones(scale)];
elseif(type==5)
    kernel = [ones(scale) -1*ones(scale);
              -1*ones(scale) ones(scale)];

else
    disp('Please choose number between 1 to 5')
end