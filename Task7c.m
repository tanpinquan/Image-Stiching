clc
clear
close all
run('vlfeat/vlfeat-0.9.21/toolbox/vl_setup')

%% This file performs gain adjustment on imagees. The first image has been intentionally brightened

peakThresh = 7.65;
edgeThresh = 10;
nSubsetPoints = 5;
errorThresh = 2;
nRuns = 10000;
alpha = 8;
beta = 0.1;
startImage = 1 ;
gainAdjust = true;

%% Load roads

images{1} = imread('images/im01.jpg');
images{2} = imread('images/im02.jpg');
images{3} = imread('images/im03.jpg');
increaseAmount = 30;
images{1} = images{1}+increaseAmount;



nodenames = {'1','2','3'};
shuffle = [1,2,3];
images = images(shuffle);


for i = 1:length(images)
    I = single(rgb2gray(images{i})) ;
    [sift{i}.features,sift{i}.descriptors] = vl_sift(I,'PeakThresh', peakThresh, 'EdgeThresh',edgeThresh) ;
    figure(1)
    subplot(ceil(length(images)/3),3,i); imshow(images{i});title(['image ' num2str(i)]) 
end

for i = 1:length(images)
    for j=i:length(images)
        if(i~=j)
            disp(['image ' num2str(i) ' <-> image ' num2str(j)])
            [matchResult{i,j}.matches, matchResult{i,j}.scores] = matchDescriptors(sift{i}.descriptors,sift{j}.descriptors,1.5) ;

            
            if(size(matchResult{i,j}.matches,2)>=nSubsetPoints)
                %% Perform RANSAC without bundle adjustment
                [h{i,j},matchResult{i,j}.inlierIdx] = performRansac(sift{i}.features,sift{j}.features,matchResult{i,j}.matches,nSubsetPoints,errorThresh,nRuns,true);
                numInliers(i,j) = length(matchResult{i,j}.inlierIdx);
                
                numOverlappedFeatures(i,j) = numberOverlappedFeatures(images{i}, images{j}, sift{i}.features, sift{j}.features, h{i,j});             
                
                numInliers(j,i) = numInliers(i,j);
                numOverlappedFeatures(j,i) = numOverlappedFeatures(i,j);
                matchResult{j,i}.matches = flipud(matchResult{i,j}.matches);
                matchResult{j,i}.scores = matchResult{i,j}.scores;
                matchResult{j,i}.inlierIdx = matchResult{i,j}.inlierIdx;

                h{j,i} = inv(h{i,j});
            end
        end
    end
end

minInliersNeeded = alpha + beta.*numOverlappedFeatures;
matchGraphAdj = numInliers>minInliersNeeded;


matchGraph = graph(matchGraphAdj,nodenames);
figure(2);plot(matchGraph);
bins = conncomp(matchGraph);

for subGraph = 1:max(bins)
    connectedSubGraphs{subGraph} = subgraph(matchGraph,bins==subGraph);
    figure;plot(connectedSubGraphs{subGraph});
    subGraphAdj = adjacency(connectedSubGraphs{subGraph});
    [~, startImage] = max(sum(subGraphAdj));

    v = dfsearch(connectedSubGraphs{subGraph},startImage,'edgetonew');
    v = connectedSubGraphs{subGraph}.Nodes.Name(v);
    v = cellfun(@str2num,v,'UniformOutput',false);
    v = cell2mat(v);
    
    startImage = str2double(cell2mat(connectedSubGraphs{subGraph}.Nodes.Name(startImage)));
    stitchedImage = images{startImage};
    stitchedImageRef = imref2d(size(stitchedImage));
    if(gainAdjust)
        images = gainAdjustment(images,h,connectedSubGraphs{subGraph});
    end

    cascadedH{startImage} = eye(3);

    for i = 1:size(v,1)
        fixedNode = v(i,1);
        transformedNode = v(i,2);

        cascadedH{transformedNode} = h{fixedNode,transformedNode}*cascadedH{fixedNode};

        tform = projective2d(cascadedH{transformedNode});        
        [transformedImage,transformedImageRef] = imwarp(images{transformedNode},tform);

        [stitchedImage, stitchedImageRef] = mergeImages(stitchedImage,stitchedImageRef,transformedImage,transformedImageRef,'image2');


    end
    figure; image(stitchedImageRef.XWorldLimits,stitchedImageRef.YWorldLimits,stitchedImage);

end



