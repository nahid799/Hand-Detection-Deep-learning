function [is_valid_bbox] = nms(todraw_box, todraw_confidence)
bboxes = todraw_box;
confidences = todraw_confidence;
num_detections = size(confidences,1);

%higher confidence detections get priority.
% [~, ind] = sort(confidences, 'descend');
% bboxes = bboxes(ind,:);

% indicator for whether each bbox will be accepted or suppressed
is_valid_bbox = false(1,num_detections);
white_list = true(1,num_detections);
for i = 1:num_detections
    cur_bb = bboxes(i,:);
    candidates = [i];
    
    if ~white_list(i)
        continue;
    end
    
    for j = 1:num_detections
        if i==j || ~white_list(j)
            continue
        end
        
        %compute overlap with each previously confirmed bbox.
        prev_bb=bboxes(j,:);
        bi=[max(cur_bb(1),prev_bb(1)) ; ...
            max(cur_bb(2),prev_bb(2)) ; ...
            min(cur_bb(3),prev_bb(3)) ; ...
            min(cur_bb(4),prev_bb(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>0 && ih>0
            % compute overlap as area of intersection / area of union
            ua=(cur_bb(3)-cur_bb(1)+1)*(cur_bb(4)-cur_bb(2)+1)+...
                (prev_bb(3)-prev_bb(1)+1)*(prev_bb(4)-prev_bb(2)+1)-...
                iw*ih;
            ov=iw*ih/ua;
            if ov > 0.2
                candidates = [candidates;j];    
            end
        end
    end
    
    %     if length(candidates)<3
    %         is_valid_bbox(i)=false;
    %         continue;
    %     end
    
    %candidates'
    scores = confidences(candidates);
    %scores'
    %     scores = ones(length(candidates),1);%confidences(candidates);
    for k=1:length(candidates)
        cur_bb = bboxes(candidates(k),:);
        scores(k) = (cur_bb(3)-cur_bb(1)+1)*(cur_bb(4)-cur_bb(2)+1);
    end
    %scores'
    mid = ceil((length(scores)+1)/2);
    [~, idx] = sort(scores);
    mid = candidates(idx(mid));
    
    for k=1:length(candidates)
        if mid == candidates(k)
            is_valid_bbox(candidates(k)) = true;
        else
            is_valid_bbox(candidates(k))= false;
            white_list(candidates(k)) = false;
        end
    end
    %fprintf('done for now %d\n', i);
    %break;
end
%fprintf(' non-max suppression: %d detections to %d final bounding boxes\n', num_detections, sum(is_valid_bbox));
end