function imagesAdjust = getOverlapIntensity(images, H, matchGraph)

matchingAdj = full(adjacency(matchGraph));
if(length(matchingAdj)==1)
    imagesAdjust = images;
    return
end
% [r c] = find(matchingAdj==1)

for i=1:length(matchingAdj)
    for j = i+1:length(matchingAdj)
        if(matchingAdj(i,j))
            fixedNode = str2num(cell2mat(matchGraph.Nodes.Name(i)));
            transformedNode = str2num(cell2mat(matchGraph.Nodes.Name(j)));
            
            fixedImage = images{fixedNode};
            movingImage = images{transformedNode};
            h = H{fixedNode,transformedNode};
            
            fixedImageVertices.x = [1 1 size(fixedImage,2) size(fixedImage,2)];
            fixedImageVertices.y = [size(fixedImage,1) 1 1 size(fixedImage,1)];

            movingImageVertices.x = [1 1 size(movingImage,2) size(movingImage,2)];
            movingImageVertices.y = [size(movingImage,1) 1 1 size(movingImage,1)];

            fixedPoly = polyshape(fixedImageVertices.x,fixedImageVertices.y);
            movingPoly = polyshape(movingImageVertices.x,movingImageVertices.y);

            %% Compute overlap for image 1
            mappedVertices = applyHomographyToFeatures(h,[movingImageVertices.x;movingImageVertices.y]);
            mappedImageVertices.x = mappedVertices(1,:);
            mappedImageVertices.y = mappedVertices(2,:);

            mappedPoly = polyshape(mappedImageVertices.x,mappedImageVertices.y);

            fixedOverlappedPoly = intersect(fixedPoly,mappedPoly);
            
            %% Plot for image 1
%             figure;plot(fixedPoly)
%             hold on;plot(mappedPoly)
%             
%             figure;plot(fixedPoly)
%             hold on; plot(fixedOverlappedPoly);
            
            %% Compute overlap for image 2
            mappedVertices2 = applyHomographyToFeatures(inv(h),[fixedImageVertices.x;fixedImageVertices.y]);
            mappedImageVertices.x = mappedVertices2(1,:);
            mappedImageVertices.y = mappedVertices2(2,:);

            mappedPoly2 = polyshape(mappedImageVertices.x,mappedImageVertices.y);

            movingOverlappedPoly = intersect(movingPoly,mappedPoly2);     
            
            %% Plot for image 2
%             figure;plot(movingPoly)
%             hold on; plot(movingOverlappedPoly);

            %% Get average intensities and overlap size
            [xFixed,yFixed] = meshgrid(1:size(fixedImage,2),1:size(fixedImage,1));
            overlappedFixedPixels = inpolygon(xFixed,yFixed,fixedOverlappedPoly.Vertices(:,1),fixedOverlappedPoly.Vertices(:,2));

            [xMoving,yMoving] = meshgrid(1:size(movingImage,2),1:size(movingImage,1));
            overlappedMovingPixels = inpolygon(xMoving,yMoving,movingOverlappedPoly.Vertices(:,1),movingOverlappedPoly.Vertices(:,2));            
                
            fixedGrayImage = rgb2gray(fixedImage);
            movingGrayImage = rgb2gray(movingImage);
            
            averageIntensities{fixedNode,transformedNode}.averageFixedIntensity = mean(mean(fixedGrayImage(overlappedFixedPixels)));
            averageIntensities{fixedNode,transformedNode}.averageMovingIntensity = mean(mean(movingGrayImage(overlappedMovingPixels)));
            
            averageIntensities{transformedNode,fixedNode}.averageFixedIntensity = mean(mean(movingGrayImage(overlappedMovingPixels)));
            averageIntensities{transformedNode,fixedNode}.averageMovingIntensity = mean(mean(fixedGrayImage(overlappedFixedPixels))); 
            
%             I(fixedNode,transformedNode) = mean(mean(fixedGrayImage(overlappedFixedPixels)));
%             I(transformedNode,fixedNode) = mean(mean(movingGrayImage(overlappedMovingPixels)));
%             
%             N(fixedNode,transformedNode) = sum(sum(overlappedFixedPixels));
%             N(transformedNode,fixedNode) = sum(sum(overlappedMovingPixels));

            I(i,j) = mean(mean(fixedGrayImage(overlappedFixedPixels)));
            I(j,i) = mean(mean(movingGrayImage(overlappedMovingPixels)));
            
            N(i,j) = sum(sum(overlappedFixedPixels));
            N(j,i) = sum(sum(overlappedMovingPixels));            
            
            
            fixedRImage = fixedImage(:,:,1);
            fixedGImage = fixedImage(:,:,2);
            fixedBImage = fixedImage(:,:,3);
            
            movingRImage = movingImage(:,:,1);
            movingGImage = movingImage(:,:,2);
            movingBImage = movingImage(:,:,3);
                        
%             Ir(fixedNode,transformedNode) = mean(mean(fixedRImage(overlappedFixedPixels)));
%             Ir(transformedNode,fixedNode) = mean(mean(movingRImage(overlappedMovingPixels)));
%             
%             Ig(fixedNode,transformedNode) = mean(mean(fixedGImage(overlappedFixedPixels)));
%             Ig(transformedNode,fixedNode) = mean(mean(movingGImage(overlappedMovingPixels)));
%             
%             Ib(fixedNode,transformedNode) = mean(mean(fixedBImage(overlappedFixedPixels)));
%             Ib(transformedNode,fixedNode) = mean(mean(movingBImage(overlappedMovingPixels)));            

            
            Ir(i,j) = mean(mean(fixedRImage(overlappedFixedPixels)));
            Ir(j,i) = mean(mean(movingRImage(overlappedMovingPixels)));
            
            Ig(i,j) = mean(mean(fixedGImage(overlappedFixedPixels)));
            Ig(j,i) = mean(mean(movingGImage(overlappedMovingPixels)));
            
            Ib(i,j) = mean(mean(fixedBImage(overlappedFixedPixels)));
            Ib(j,i) = mean(mean(movingBImage(overlappedMovingPixels)));             

        end

    end
end

%% Compute gain
sigmaN = 10;
sigmaG = 0.1;

k1=1/sigmaN^2;
k2=1/sigmaG^1;


for i=1:length(N)
   result(i,1) = sum(k2.*N(i,:));
   A(i,:) = -N(i,:).*k1.*I(i,:).*I(:,i)';
   A(i,i) = A(i,i) + sum(N(i,:).*(k1.*I(i,:).^2+k2));

   Ar(i,:) = -N(i,:).*k1.*Ir(i,:).*Ir(:,i)';
   Ar(i,i) = Ar(i,i) + sum(N(i,:).*(k1.*Ir(i,:).^2+k2));
   
   Ag(i,:) = -N(i,:).*k1.*Ig(i,:).*Ig(:,i)';
   Ag(i,i) = Ag(i,i) + sum(N(i,:).*(k1.*Ig(i,:).^2+k2));   
   
   Ab(i,:) = -N(i,:).*k1.*Ib(i,:).*Ib(:,i)';
   Ab(i,i) = Ab(i,i) + sum(N(i,:).*(k1.*Ib(i,:).^2+k2));   

end

gain = inv(A)*result
gainR = inv(Ar)*result;
gainG = inv(Ag)*result;
gainB = inv(Ab)*result;

imagesAdjust = images;

%% Apply gain adjustment
for i =1:length(gain)
    imageNode = str2num(cell2mat(matchGraph.Nodes.Name(i)));

%     imagesAdjust{imageNode} = images{imageNode}.*gain(i);
    imagesAdjust{imageNode}(:,:,1) = images{imageNode}(:,:,1).*gainR(i);
    imagesAdjust{imageNode}(:,:,2) = images{imageNode}(:,:,2).*gainG(i);
    imagesAdjust{imageNode}(:,:,3) = images{imageNode}(:,:,3).*gainB(i);

    figure;subplot(1,2,1); imshow(images{imageNode})
    subplot(1,2,2); imshow(imagesAdjust{imageNode})
end

beforeAdjustment = I
adjustedIntensities = I.*gain


    