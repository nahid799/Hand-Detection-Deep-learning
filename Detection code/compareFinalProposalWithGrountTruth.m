function [gt_boxes, gt_count] = compareFinalProposalWithGrountTruth(name, im)

dot = strfind(name,'.');
imname = name(1:dot-1);
load(['../data/test_data/annotations/' imname '.mat']);
%im = imread(['../data/test_data/images/' uf(i).name]);
gt_count = length(boxes); 
imshow(im);
for j = 1:length(boxes)
    box = boxes{j};
    line([box.a(2) box.b(2)]',[box.a(1) box.b(1)]','LineWidth',1,'Color','y');
    line([box.b(2) box.c(2) box.d(2) box.a(2)]',[box.b(1) box.c(1) box.d(1) box.a(1)]','LineWidth',1,'Color','y');
end

ymin = ones(length(boxes),1);
ymax = ones(length(boxes),1);
xmin = ones(length(boxes),1);
xmax = ones(length(boxes),1);

for j = 1:length(boxes)
    [a, b, c, d, ~] = getBox(boxes,j);
    ymin(j) =  min([a(1),b(1), c(1), d(1)]);
    ymax(j) =  max([a(1),b(1), c(1), d(1)]);
    xmin(j) =  min([a(2),b(2), c(2), d(2)]);
    xmax(j) =  max([a(2),b(2), c(2), d(2)]);
end
gt_boxes = [ymin xmin ymax xmax];
%disp('Press any key to move onto the next image');pause;
end


