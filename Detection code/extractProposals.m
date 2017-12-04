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
colorTypes = colorTypes{1};
% Here you specify which similarity functions to use in merging
simFunctionHandles = {@SSSimColourTextureSizeFillOrig, @SSSimTextureSizeFill, @SSSimBoxFillOrig, @SSSimSize};


% Thresholds for the Felzenszwalb and Huttenlocher segmentation algorithm.
% Note that by default, we set minSize = k, and sigma = 0.8.
%k = 200; % controls size of segments of initial segmentation.
%ks = [50 100 150 300];
k = 200;
sigma = 0.8;
minSize = k;
minBoxWidth = 20;

color = [255, 255,255];

%% image to test
count = 0;
uf = dir('../data/test_data/images/*.jpg');
num_tests = length(uf);
for i=1:num_tests
    name = uf(i).name;
    [im, gt_ymin, gt_xmin, gt_ymax, gt_xmax, gt_angles] = readTestData(uf, i); %100 (328,1,2) (215,1)  (235, 1)
    gt_boxes = [gt_ymin gt_xmin gt_ymax gt_xmax];    
    
    % Perform Selective Search
    [boxes, blobIndIm, blobBoxes, hierarchy] = ...
        Image2HierarchicalGrouping(im, sigma, k, minSize, colorTypes, simFunctionHandles);
    
    %boxes = FilterBoxesWidth(boxes, minBoxWidth);
    boxes = BoxRemoveDuplicates(boxes);
    boxes =  flipud(boxes);
    num_boxes = size(boxes,1);
    num_boxes = fix(num_boxes - 0.20 * num_boxes);
    boxes = boxes(1:num_boxes,:);
    
    % compare with ground truths
    [is_gt, angles] = getGT(gt_boxes, gt_angles, boxes);
    
    proposal = {boxes, is_gt', angles'};
    save(sprintf('../data/proposals/%s.mat',name), 'proposal');
    count = count + 1;
    
    if count == 50
        fprintf('current test data is %s. remaining %d/n%d\n...', name, i, num_tests);
        count = 0;
    end
    %figure, imshow(im);
    %ShowRectsWithinImage(gt_boxes, 1, 1, im);
    %ShowRectsWithinImage(boxes(is_gt==1,:), 1, 1, im);
    
    %break;    
end
