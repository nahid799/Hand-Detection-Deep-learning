function [gt_count, our_count] = showResults(name, num_boxes,num_rotation, num_votes, threshold)
%num_votes = 2;

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

fprintf('current image is %s, total proposals:%d, num_rotation:%d\n', name, num_boxes, num_rotation);
%imshow(im)

todraw_box=[];
todraw_confidence = [];
todraw_orientation=[];

final_labels = ones(num_boxes,1);
for p = 1:num_boxes
    box = proposal{1,1}(p,:);
    
    start_index = 1+(p-1)*num_rotation;
    end_index = start_index+(num_rotation-1);
    confidence = all_confidences(start_index:end_index, :);
    labels = all_labels(start_index:end_index, :);
    
    for k=1:length(labels)
        if confidence(k) < threshold
            labels(k) = -1;
        else
            labels(k) = 1;
        end
    end
    
    %imshow(im_hand);
    %waitforbuttonpress;
    
    
    if sum(labels == 1) >= num_votes;
        todraw_box= [todraw_box; box];
        %take max confidence
        [conf, orin] = min(abs(confidence(labels==1,:) - median(confidence(labels==1,:))));
        todraw_confidence = [todraw_confidence ; conf];                        
        todraw_orientation = [todraw_orientation; orin];               
    end
end


%% non maximal suppression
% ShowRectsWithinImage(todraw_box, 5, 5, im, todraw_confidence);

suppressed_box = nms_median(todraw_box,todraw_confidence);
refined_box = todraw_box(suppressed_box == 1,:);
refined_confidence = todraw_confidence(suppressed_box == 1,:);
refined_orientation = todraw_orientation(suppressed_box == 1,:);
% ShowRectsWithinImage(refined_box, 5, 5, im);

suppressed_box = nms_regular(refined_box, ones(size(refined_box,1),1), im_size);
refined_box = refined_box(suppressed_box == 1,:);
refined_confidence = refined_confidence(suppressed_box == 1,:);
refined_orientation = refined_orientation(suppressed_box == 1,:);
% ShowRectsWithinImage(refined_box, 5, 5, im, refined_confidence);

%% drawing bounding boxes
imshow(im);

for b =1:size(refined_box,1)
    box = refined_box(b,:);
    xmin = box(2); xmax = box(4); ymin=box(1); ymax=box(3);    
    
    for k = box(1):box(3)
        im(k, box(2),:)=[255, 0 , 0];
        im(k, box(4),:)=[255, 0 , 0];
    end
    for k = box(2):box(4)
        im(box(1), k,:)=[255, 0 , 0];
        im(box(3), k,:)=[255, 0 , 0];
    end
end

imshow(im);

[gt_boxes, gt_count] =  compareFinalProposalWithGrountTruth(name, im);
result = getGT(gt_boxes, [], refined_box);
our_count = sum(result);

f = getframe(gca);
im = frame2im(f);

imwrite(im, ['../data/results/' name '.jpg']);
end