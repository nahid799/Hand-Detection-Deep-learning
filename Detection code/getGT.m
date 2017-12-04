function [is_gt, angles]=getGT(gt_boxes, gt_angles, boxes)
%gt_boxes;
num_gt = size(gt_boxes,1);
num_proposal = size(boxes,1);
is_gt = false(1,num_proposal);
angles = ones(1,num_proposal);

for i=1:num_proposal
    cur_bb = boxes(i,:);       
    cur_bb_is_valid = false;            
    for j = 1:num_gt        
        gt_box = gt_boxes(j,:);
        bi=[max(cur_bb(1),gt_box(1)) ; ... 
            max(cur_bb(2),gt_box(2)) ; ...
            min(cur_bb(3),gt_box(3)) ; ...
            min(cur_bb(4),gt_box(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>0 && ih>0                
            % compute overlap as area of intersection / area of union
            ua=(cur_bb(3)-cur_bb(1)+1)*(cur_bb(4)-cur_bb(2)+1)+...
               (gt_box(3)-gt_box(1)+1)*(gt_box(4)-gt_box(2)+1)-...
               iw*ih;
            ov=iw*ih/ua;
            if ov >= 0.5 % overlapped more than 50%
                cur_bb_is_valid = true;                
            end
            
            %special case-- the center coordinate of the current bbox is
            %inside the gt bbox.
            center_coord = [(cur_bb(1) + cur_bb(3))/2, (cur_bb(2) + cur_bb(4))/2];
            if( center_coord(1) > gt_box(1) && center_coord(1) < gt_box(3) && ...
                center_coord(2) > gt_box(2) && center_coord(2) < gt_box(4))               
                cur_bb_is_valid = true;
            end
        end
      is_gt(i)= cur_bb_is_valid;
      if cur_bb_is_valid
          if length(gt_angles) ~= 0
            angles(i) = gt_angles(j);
          end
          break;
      end
    end
end
end