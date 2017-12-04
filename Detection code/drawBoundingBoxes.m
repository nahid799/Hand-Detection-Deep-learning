function drawBoundingBoxes(refined_box, im)
%% drawing bounding boxes
imshow(im);
    for b =1:size(refined_box,1)
        box = refined_box(b,:);
        
    xmin = box(2);
    xmax = box(4);
    ymin=box(1);
    ymax=box(3);    
    imshow(im);
    line([xmin, xmax, xmax, xmin, xmin]',[ymin, ymin, ymax, ymax, ymin]','LineWidth',2,'Color','r');    
    
    end
    imshow(im);
end