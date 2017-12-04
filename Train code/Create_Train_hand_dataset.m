clear;
pause on;
uf = dir('../data/training_data/images/*.jpg');
z=1;
for i = 1:length(uf)
    dot = strfind(uf(i).name,'.');
    imname = uf(i).name(1:dot-1);
    load(['../data/training_data/annotations/' imname '.mat']);
    im = imread(['../data/training_data/images/' uf(i).name]);
    
    [h, w, d] = size(im);
    
    for j = 1:length(boxes)
        box = boxes{j};
        [truea, trueb, truec, trued] = getBox(boxes,j);
        angle = 180*atan2(truea(1)-trueb(1),trueb(2)-truea(2))/pi;
        segh = (truea(1)-trued(1))*(truea(1)-trued(1))+(truea(2)-trued(2))*(truea(2)-trued(2));
        segw = (truea(1)-trueb(1))*(truea(1)-trueb(1))+(truea(2)-trueb(2))*(truea(2)-trueb(2));
        segh = round(sqrt(segh)); segw = round(sqrt(segw));
        ta = ptRotate(truea,angle,h,w);
        
        segh1 = segh+(segh*.2);
        segw1 = segw+(segw*.2);
        xmin = round(ta(2)-(segw*.2));
        ymin = round(ta(1)-(segh*.2));
        xmax = round(ta(2) + segw1+(segw*.2));
        ymax = round(ta(1) + segw1+(segh*.2));
        
        
        img1 = imrotate(im,-angle,'bilinear','crop');
        if xmin<=0
            xmin=1;
        end
        x1=int64(max([box.b(2) box.c(2) box.d(2) box.a(2)]));
        if xmax>w
            xmax=w;
        end
        y=int64(min([box.b(1) box.c(1) box.d(1) box.a(1)]));
        if ymin<=0
            ymin=1;
        end
        y1=int64(max([box.b(1) box.c(1) box.d(1) box.a(1)]));
        if ymax>h
            ymax=h;
        end
        
        img = img1(ymin:ymax,xmin:xmax,:);
        if isempty(img)
            continue;
        end
        [l m n] = size(img);
        size_min = min([l m]);
        res = 256/size_min;
        img = imresize(img,res);
        string = 'PosHandMain2/hand_';
        num = num2str(z);
        string = strcat(string,num,'.jpg');
        imwrite(uint8(img),string,'jpg');
        z = z+1;
    end
end

