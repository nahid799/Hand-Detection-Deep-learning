function showProposal(name, num_boxes, num_rotation, num_votes)

%num_votes = 4;
angle = 360/num_rotation;

dot = strfind(name,'.');
imname = name(1:dot-1);

load(['../data/proposals/' name]); %load proposals var
load(['../data/predictions/' name], 'prediction'); % prediction data

im = imread(['../data/test_data/images/' imname '.jpg']);
imshow(im);
im_size = size(im);

if num_boxes == 0
    num_boxes = size(proposal{1,1},1);
end
count = 0;
gt_angles = proposal{1,3};

all_confidences = prediction{1,2}; % {feature, confidence, label}
all_labels = prediction{1,3}; % num_boxes*num_rotation x 1

fprintf('curren image is %s, total proposals:%d, num_rotation:%d\n', name, num_boxes, num_rotation);
%imshow(im)

todraw_box=[];
todraw_confidence = [];
todraw_orientation=[];
a1=0.0;
a2=0.0;

final_confidence = ones(num_boxes,1);
gt=ones(num_boxes,1);

for p = 1:num_boxes
    box = proposal{1,1}(p,:);
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
        if a2 == 0 
            a2=1;
        end
        final_confidence(p) = 0.5*confidence(a1) + 0.5*confidence(a2);
    end
    
        
%     if sum(labels == 1 ) >= num_votes;
%         todraw_box= [todraw_box; box];        
%         todraw_confidence = [todraw_confidence ; max(confidence(labels==1,:))];
%     end
    
    xmin = box(2); xmax = box(4); ymin=box(1); ymax=box(3);
    im_hand = im(ymin:ymax, xmin:xmax,:);
    
    %fprintf('\t total false positives %d for proposal:%d\n', sum(labels==1), p);    
    for theta=0:num_rotation-1 % 15 degree rotation
        im_hand = imrotate(im_hand,-angle,'bilinear','crop');
        if gt(p)==1 %&& (((theta+1) == a1) ||((theta+1) == a1)) %&&labels(theta+1) == 1
            imshow(imresize(im_hand, [255 255]));
            fprintf('\t \t %d: confidence %f label %d theta:%d a1:%d a2:%d\n', p, ...
                confidence(theta+1), labels(theta+1),theta+1, a1,a2);
            waitforbuttonpress;
        end
    end
    
    %break;
end



%% non maximal suppression
ShowRectsWithinImage(todraw_box, 5, 5, im, todraw_confidence);

suppressed_box = nms_median(todraw_box,todraw_confidence);
refined_box = todraw_box(suppressed_box == 1,:);
refined_confidence = todraw_confidence(suppressed_box == 1,:);
ShowRectsWithinImage(refined_box, 5, 5, im);

suppressed_box = nms_regular(refined_box, ones(length(refined_box),1), im_size);
refined_box = refined_box(suppressed_box == 1,:);
refined_confidence = refined_confidence(suppressed_box == 1,:);
ShowRectsWithinImage(refined_box, 5, 5, im, refined_confidence);

%% drawing bounding boxes
for b =1:size(refined_box,1)
    box = refined_box(b,:);
    for k = box(1):box(3)
        im(k, box(2),:)=[255, 0 , 0];
        im(k, box(4),:)=[255, 0 , 0];
    end
    for k = box(2):box(4)
        im(box(1), k,:)=[255, 0 , 0];
        im(box(3), k,:)=[255, 0 , 0];
    end
end

end