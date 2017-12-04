uf = dir('../data/training_data/images/*.jpg');
d=1;
for i = 1:length(uf)
    ran = 1;
    dot = strfind(uf(i).name,'.');
    imname = uf(i).name(1:dot-1);
    load(['../data/training_data/annotations/' imname '.mat']);
    im = imread(['../data/training_data/images/' uf(i).name]);
    %imshow(im);
    [a b c] = size(im);
    if(a>64 && b>64)
        %pause;
        for j = 1:length(boxes)
            box = boxes{j};
            x=int64(min([box.b(2) box.c(2) box.d(2) box.a(2)]));
            if x<=0
                x=1;
            end
            x1=int64(max([box.b(2) box.c(2) box.d(2) box.a(2)]));
            if x1>b
                x1=b;
            end
            y=int64(min([box.b(1) box.c(1) box.d(1) box.a(1)]));
            if y<=0
                y=1;
            end
            y1=int64(max([box.b(1) box.c(1) box.d(1) box.a(1)]));
            if y1>a
                y1=a;
            end
            trig = 1;
            while(ran<=20)
                randx = randi(a-63);
                randy = randi(b-63);
                trig = trig+1;
                if trig>30
                    break;
                end
                if((randx>=y1 || randx+63<=y) && (randy>=x1 || randy+63<=x))
                    img = im(randx:randx+63,randy:randy+63,:);
                    img = imresize(img,4);
                    string = 'NegMain1/hand_';
                    num = num2str(d);
                    string = strcat(string,num,'.jpg');
                    imwrite(uint8(img),string,'jpg');
                    d = d+1;
                    ran = ran+1;
                end
                
            end
            %disp('Press any key to move onto the next image');pause;
        end
    end
end