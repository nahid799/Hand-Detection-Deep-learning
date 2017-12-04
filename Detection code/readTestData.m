function [im, ymin, xmin, ymax, xmax, angles] = readTestData(uf, index)
%uf = dir('../data/test_data/images/*.jpg');
for i = index:index%1:length(uf)
    dot = strfind(uf(i).name,'.');
    imname = uf(i).name(1:dot-1);
    load(['../data/test_data/annotations/' imname '.mat']);
    im = imread(['../data/test_data/images/' uf(i).name]);
    
    %     imshow(im);
    angles = ones(length(boxes),1);
    ymin = ones(length(boxes),1);
    ymax = ones(length(boxes),1);
    xmin = ones(length(boxes),1);
    xmax = ones(length(boxes),1);
    
    [h, w, ~] = size(im);
    for j = 1:length(boxes)
        [a, b, c, d, angle] = getBox(boxes,j);
        angles(j) = angle;
        ymin(j) =  min([a(1),b(1), c(1), d(1)]);
        ymax(j) =  max([a(1),b(1), c(1), d(1)]);
        xmin(j) =  min([a(2),b(2), c(2), d(2)]);
        xmax(j) =  max([a(2),b(2), c(2), d(2)]);
    end
    
end
end