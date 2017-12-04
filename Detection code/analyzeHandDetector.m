function analyzeHandDetector(name, num_boxes,num_rotation)
%num_votes = 4;
angle = 360/num_rotation;
a1 = 0.0;
a2 = 0.0;


dot = strfind(name,'.');
imname = name(1:dot-1);

load(['../data/proposals/' name]); %load proposals var
load(['../data/predictions/' name], 'prediction'); % prediction data

im = imread(['../data/test_data/images/' imname '.jpg']);
im_size = size(im);

if num_boxes == 0
    num_boxes = size(proposal{1,1},1);
end

count = 0;
gt_angles = proposal{1,3}(1:num_boxes,:);
all_confidences = prediction{1,2}; % {feature, confidence, label}
all_labels = prediction{1,3}; % num_boxes*num_rotation x 1

fprintf('curren image is %s, total proposals:%d, num_rotation:%d\n', name, num_boxes, num_rotation);
%imshow(im)

final_confidence = ones(num_boxes,1);
gt=ones(num_boxes,1);

for p = 1:num_boxes    
    gt(p) = proposal{1,2}(p);
    
    start_index = 1+(p-1)*num_rotation;    
    end_index = start_index+(num_rotation-1);
    confidence = all_confidences(start_index:end_index, :);
    labels = all_labels(start_index:end_index, :);
    
    if gt(p) == 0
        gt(p) = -1;
        final_confidence(p) = median(confidence);
    else
        theta = proposal{1,3}(p);
        if theta<0
            a1 = 360+theta;
            a2 = 180+theta;
        else
            a1 = theta;
            a2 = 180+theta;
        end
        a1 = fix(a1/angle);
        a2 = fix(a2/angle);
        if a1 == 0
            a1=1;
        end
        if a2==0
            a2=1;
        end
        final_confidence(p) = max(confidence(a1), confidence(a2));
    end
    
    %imshow(im_hand);
    %waitforbuttonpress;
end

%% save post_predictions data
post_prediction = {final_confidence, gt};    %final_orientation
save(['../data/post_predictions/' name], 'post_prediction');


end
