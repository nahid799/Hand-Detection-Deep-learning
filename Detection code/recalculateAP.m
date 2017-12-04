function recalculateAP(num_boxes,num_rotation)
% this function provides an alternative to calculate confidence on rotated
% raw predictions.
% inputs:
% num_boxes : the number of proposal used
% num_rotation: how many orientation we try for detection
%


angle = 360/num_rotation;
a1 = 0.0;
a2 = 0.0;

uf = dir('../data/predictions/*.mat');
num_tests = length(uf);
for i=1:num_tests
    name = uf(i).name;
    dot = strfind(name,'.');
    
    load(['../data/proposals/' name]); %load proposals var
    load(['../data/predictions/' name], 'prediction'); % prediction data
    
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
        temp = -Inf;
        for k=1:num_rotation/2
            temp= max(temp, max(confidence(k), confidence(num_rotation/2+k)));
        end
        final_confidence(p) = temp;
        
    end
    
    %% save post_predictions data
    post_prediction = {final_confidence, gt};    %final_orientation
    save(['../data/post_predictions2/' name], 'post_prediction');
    
end
end