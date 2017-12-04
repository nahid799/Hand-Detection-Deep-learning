%fprintf('first run startup.m before running this\n');

%% preparing svm_model
% load('svm_models/train_model_large(noaugmentation).mat');
% load('svm_models/train_model_large(sum).mat');
% load('svm_models/train_model_huge(noaug).mat');
load('svm_models/model_face_new_noaug_boost.mat');

threshold = -0.60; % prec: 90 recall:83
% threshold = 0.10; % prec: 96 recall:67
% threshold = -0.014; % prec: 94 recall:73

%% preparing objectness module
addpath('Dependencies');
% Compile anisotropic gaussian filter
if(~exist('anigauss'))
    mex Dependencies/anigaussm/anigauss_mex.c Dependencies/anigaussm/anigauss.c -output anigauss
end

if(~exist('mexCountWordsIndex'))
    mex Dependencies/mexCountWordsIndex.cpp
end

% Compile the code of Felzenszwalb and Huttenlocher, IJCV 2004.
if(~exist('mexFelzenSegmentIndex'))
    mex Dependencies/FelzenSegment/mexFelzenSegmentIndex.cpp -output mexFelzenSegmentIndex;
end

% Parameters. Note that this controls the number of hierarchical
% segmentations which are combined.
colorTypes = {'Hsv', 'Lab', 'RGI', 'H', 'Intensity'};
colorType = colorTypes{1}; % Just HSV is good for us

% Here you specify which similarity functions to use in merging
simFunctionHandles = {@SSSimColourTextureSizeFillOrig, @SSSimTextureSizeFill, @SSSimBoxFillOrig, @SSSimSize};
% simFunctionHandles = simFunctionHandles(1:4); % Two different merging strategies

% Thresholds for the Felzenszwalb and Huttenlocher segmentation algorithm.
% Note that by default, we set minSize = k, and sigma = 0.8.
k = 200; % controls size of segments of initial segmentation.
minSize = k;
sigma = 0.8;

color = [255, 255,255];
%% image to test
uf = dir('../data/proposals/*.mat');
for i=1:length(uf) %100 (328,1,2) (215,1)  (235, 1)
    dot = strfind(uf(i).name,'.');
    imname = uf(i).name(1:dot-1);
    load(['../data/proposals/' uf(i).name]); %load proposals var
    im = imread(['../data/test_data/images/' imname '.jpg']);

    im_size = size(im);
    size_x = size(im,2);
    size_y = size(im,1);

    
   for theta=1:24 % 15 degree rotation 
    num_proposal = size(proposal,1);
    
    for p=1:num_proposal;
    end
%     im = imrotate(im,80,'bilinear','crop');    
    im = imrotate(im_org,-angle(theta),'bilinear','crop');    
    
    
    %     imshow(im);
    
    % Perform Selective Search
    [boxes, blobIndIm, blobBoxes, hierarchy] = Image2HierarchicalGrouping(im, sigma, k, minSize, colorType, simFunctionHandles);
    boxes = BoxRemoveDuplicates(boxes);
    boxes =  flipud(boxes);
    num_boxes = size(boxes,1);
    num_boxes = fix(num_boxes - 0.10*num_boxes);
    boxes = boxes(1:num_boxes,:);
    %ShowRectsWithinImage(boxes, 5, 5, im);
    
    tic
    
    confidence = ones(num_boxes,1);
    values = ones(num_boxes,1);
    scale = 1.0;
    count = 0;
    padding = 0.2;
    for i=1:num_boxes
        box = boxes(i,:);
        xmin = box(2);xmax = box(4); ymin=box(1); ymax=box(3);
        width = xmax - xmin; height = ymax - ymin;
        if width > height
            padding = width-height;
            ypad = fix(padding/2);
            xpad = 0;
        else
            padding = height-width;
            xpad = fix(padding/2);
            ypad = 0;
        end
        
        %         im_hand = im(ymin:ymax, xmin:xmax,:);
        %         imshow(im_hand);
        %         fprintf('before padding:(%i %i) (%i %i) width:%i height:%i xpad:%i ypad:%i\n',ymin, ymax, xmin, xmax, width, height, xpad,ypad);
        %         waitforbuttonpress;
        %
        if (xmin-xpad)<1
            xmin2 = 1;
        else
            xmin2 = xmin-xpad;
        end
        if (ymin-ypad)<1
            ymin2 = 1;
        else
            ymin2 = ymin-ypad;
        end
        
        if (xmax + xpad)> size_x
            xmax2 = size_x;
        else
            xmax2 = xmax + xpad;
        end
        
        if (ymax + ypad)> size_y
            ymax2 = size_y;
        else
            ymax2 = ymax + ypad;
        end
        %im_hand = im(ymin:ymax, xmin:xmax,:);
        im_hand = im(ymin2:ymax2, xmin2:xmax2,:);
        %         imshow(im_hand);
        %         waitforbuttonpress;
        
        for k = 1:ypad
            for l=1:size(im_hand,2);
                im_hand(k, l,:) = color;
            end
        end
        for k = size(im_hand,1)-ypad:size(im_hand,1)
            for l=1:size(im_hand,2);
                im_hand(k, l,:) = color;
            end
        end
        for k = 1:xpad
            for l=1:size(im_hand,1);
                im_hand(l, k,:) = color;
            end
        end
        for k = size(im_hand,2)-ypad:size(im_hand,2)
            for l=1:size(im_hand,1);
                im_hand(l, k,:)=color;
            end
        end
        
        %         fprintf('after padding:(%i, %i  %i,%i) (%i,%i  %i.%i) width:%i height%i xpad:%i ypad:%i\n',ymin2, ymin,ymax2, ymax,xmin2, xmin, xmax2,xmax, width, height, xpad,ypad);
        %         imshow(im_hand);
        %         waitforbuttonpress;
        
        %         if size(im_hand,1)> size(im_hand,2)
        %             scale = 256/size(im_hand,2);
        %         else
        %             scale = 256/size(im_hand,1);
        %         end
        %         im_hand = imresize(im_hand,scale);
        im_hand = imresize(im_hand,[256 256]);
        %         imshow(im_hand);
        %         waitforbuttonpress;
        
        code = encoder.encode(featpipem.utility.standardizeImage(im_hand));
        train_instance = double(code');
        train_label=1;
        [label, accuracy, confidence_svm] = svmpredict(train_label',train_instance,model, '-q');
        values(i) = confidence_svm;
        if confidence_svm < threshold
            confidence(i) = -1;
        else
            confidence(i) = 1;
            count = count+1;
        end
        %confidence(i) = label;
        %if label == 1
        %count = count+1;
        %end
        %         fprintf('predicted %i confidence:%f\n',confidence(i),confidence_svm);
        %         waitforbuttonpress;
    end
    %     toc
    
    fprintf('positive count: %d\n', count);
    
    %     tic
    todraw_box = ones(count,4);
    todraw_confidence = ones(count,1);
    j=1;
    for i=1:num_boxes
        if confidence(i) == -1
            continue;
        end
        box = boxes(i,:);
        todraw_box(j,:) = box;
        todraw_confidence(j) = values(i);
        j = j+1;
    end
    fprintf('total hands detected %i out of %i proposal\n',count, num_boxes);
    ShowRectsWithinImage(todraw_box, 5, 5, im, todraw_confidence);
    
    % non maximal suppression
    suppressed_box = non_max_supr_bbox(todraw_box,todraw_confidence, im_size);
    refined_box = todraw_box(suppressed_box == 1,:);
    ShowRectsWithinImage(refined_box, 5, 5, im);
    
    % drawing bounding boxes
    for i=1:size(refined_box,1)
        box = refined_box(i,:);
        for k = box(1):box(3)
            im(k, box(2),:)=[fix(255*j/num_boxes), 0 , 0];
            im(k, box(4),:)=[fix(255*j/num_boxes), 0 , 0];
        end
        for k = box(2):box(4)
            im(box(1), k,:)=[fix(255*j/num_boxes), 0 , 0];
            im(box(3), k,:)=[fix(255*j/num_boxes), 0 , 0];
        end
    end
    figure, imshow(im);
    % ShowRectsWithinImage(boxes, 5, 5, im);
    
    % Show blobs which result from first similarity function
    %hBlobs = RecreateBlobHierarchyIndIm(blobIndIm, blobBoxes, hierarchy{1});
    %ShowBlobs(hBlobs, 5, 5, im);
end
end