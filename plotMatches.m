function plotMatches(image1,image2, stitchedImageRef, features1,features2, matches, inlierIdx)
mergedImageRef = stitchedImageRef;
mergedImageRef.XWorldLimits(2) = mergedImageRef.XWorldLimits(2) + size(image2,2);
image2Offset = max(0,round(-1*min(stitchedImageRef.YWorldLimits)));
maxHeight = max(size(image1,1),size(image2,1));
maxWidth = max(size(image1,2),size(image2,2));

imagePad1 = zeros(maxHeight,size(image1,2),3);
imagePad2 = zeros(maxHeight,size(image2,2),3);
imagePad1(1:size(image1,1),1:size(image1,2),1:3) = image1;
imagePad2(1+image2Offset:size(image2,1)+image2Offset,1:size(image2,2),1:3) = image2;

imageMerge = uint8(cat(2,imagePad1,imagePad2));
figure; image(mergedImageRef.XWorldLimits,mergedImageRef.YWorldLimits,imageMerge);
selMatch = matches(:,inlierIdx);
matchLoc1 = features1(1:2,selMatch(1,:));
matchLoc2 = features2(1:2,selMatch(2,:));
matchLoc2(1,:) = matchLoc2(1,:) + stitchedImageRef.XWorldLimits(2);

hold on ;
l = line([matchLoc1(1,:) ; matchLoc2(1,:)], [matchLoc1(2,:) ; matchLoc2(2,:)]) ;
set(l,'linewidth', 1) 

