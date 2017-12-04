function runHandDetector(name, encoder)
fprintf('run startup.m at least once before running this file\n');

%% preparing svm_model
load('svm_models/model_face_new_noaug_boost.mat');

threshold = -0.60; % prec: 90 recall:83
% threshold = 0.10; % prec: 96 recall:67
% threshold = -0.014; % prec: 94 recall:73

%% model parameters
padding_fraction = sqrt(2)-1;
num_rotation = 8;
angle = 360/num_rotation;   % 30 degree;


%% testing

%for i= 215:215 %num_tests %%test {100 (328,1,2) (215,1)  (235, 1)}
dot = strfind(name,'.');
imname = name(1:dot-1);
load(['../data/proposals/' name]); %load proposals var
im = imread(['../data/test_data/images/' imname '.jpg']);
imshow(im);

size_x = size(im,2);
size_y = size(im,1);

num_boxes = size(proposal{1,1},1);
if num_boxes>100
    num_boxes = 100;
end

count = 0;
padding = 0;

% accumulators
all_gts = ones(num_boxes*num_rotation,1);
all_labels = ones(num_boxes*num_rotation,1);
all_confidences = ones(num_boxes*num_rotation,1);
all_features = ones(num_boxes*num_rotation,128);
fprintf('current image is %s, total proposals:%d, num_rotation:%d\n', ...
    name, num_boxes, num_rotation);

%imshow(im)
tic;
count = 0;
for p = 1:num_boxes
    box = proposal{1,1}(p,:);
    xmin = box(2);xmax = box(4); ymin=box(1); ymax=box(3);
    width = xmax - xmin; height = ymax - ymin;
    if width > height
        padding = width-height;
        ypad = padding/2;
        ypad = fix(ypad + width*padding_fraction);
        xpad = fix(width*padding_fraction);
    else
        padding = height-width;
        xpad = padding/2;
        xpad = fix(xpad + height*padding_fraction);
        ypad = fix(height*padding_fraction);
    end
    
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
    
    im_hand = im(ymin2:ymax2, xmin2:xmax2,:);
    im_hand_org = im_hand;
    
    features = ones(num_rotation, 128);
    labels = ones(num_rotation,1);
    for theta=0:num_rotation-1
        Irot = imrotate(im_hand_org,-angle*theta);
        Mrot = ~imrotate(true(size(im_hand_org)),-angle*theta);
        Irot(Mrot&~imclearborder(Mrot)) = 255;
        im_hand = Irot;
        
        %imshow(im_hand);
        %waitforbuttonpress;
        
        % resize for model
        im_hand = imresize(im_hand,[256 256]);
        %imshow(im_hand);
        %waitforbuttonpress;
        
        code = encoder.encode(featpipem.utility.standardizeImage(im_hand));
        features(theta+1,:) = double(code');
        labels(theta+1) = 1;
    end
    start_index = 1+(p-1)*num_rotation;
    end_index = start_index+(num_rotation-1);
    all_features(start_index:end_index, :) = features(1:num_rotation,:);
    all_labels(start_index:end_index, :) = labels;
    %break;
    
    count = count+1;
    if count == 50
        fprintf('(in progress) proposals %d/%d...\n', p, num_boxes);
        count = 0;
    end
end

% call svm
[~, ~, confidence_svm] = svmpredict(all_labels,all_features, model, '-q');
toc;

% thresholding labels
for k=1:num_rotation*num_boxes
    if confidence_svm(k) < threshold
        all_labels(k) = -1;
    else
        all_labels(k) = 1;
        count = count+1;
    end
end
fprintf('positive count: %d\n', count);

%% save data prediction folder
prediction = {all_features, confidence_svm, all_labels};
save(['../data/predictions/' name], 'prediction');
%end
end