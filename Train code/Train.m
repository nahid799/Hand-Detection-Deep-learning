% REQUIRED model directory location

model_dir = '../models/CNN_M_128';
i=1;
param_file = sprintf('%s/param.prototxt', model_dir);
model_file = sprintf('%s/model', model_dir);

average_image = '../models/mean.mat';


%checking for gpu support
use_gpu = false;

if use_gpu
    featpipem.directencode.ConvNetEncoder.set_backend('cuda');
end

encoder = featpipem.directencode.ConvNetEncoder(param_file, model_file, ...
    average_image, ...
    'output_blob_name', 'fc7');

%To remove augmentation remove the comments from the following two lines
% encoder.augmentation = 'aspect_corners';
% encoder.augmentation_collate = 'max';

for k=1:9000
    a = num2str(k);
    string = strcat('PosHandMain/hand_',a);
    sample_image_path = strcat(string,'.jpg');
    
    im = imread(sample_image_path);
    im = featpipem.utility.standardizeImage(im); % ensure of type single, w. three channels
    
    code = encoder.encode(im);
    train_instance(i,:) = double(code');
    train_label(i)=1;
    i = i+1;
    if(mod(i,10000)==0)
        i
    end
end


for k=1:73500
    a = num2str(k);
    string = strcat('NegMain/hand_',a);
    sample_image_path = strcat(string,'.jpg');
    
    im = imread(sample_image_path);
    im = featpipem.utility.standardizeImage(im); % ensure of type single, w. three channels

    
    code = encoder.encode(im);
    train_instance(i,:) = double(code');
    train_label(i)=-1;
    i = i+1;
    if(mod(i,10000)==0)
        i
    end
end

%Randomly swapping the rows of the matrix for better svm prediction
data = horzcat(train_label',train_instance);
data_ran = data(randperm(82500),:);
train_instance = data_ran(:,2:129);
train_label = train_label'
train_label = data_ran(:,1);
train_label = train_label';

%training the data using a classifier. We've used the LivSVM library for classification
model = svmtrain(train_label',train_instance,'-t 0 -h 0');

%Training the model with hard negatives

[label] = svmpredict(train_label',train_instance,model); 
i=82501;
for k = 1:size(label)
    if label(k) ~= train_label(k)
        train_instance(i,:) = train_instance(k,:);
        train_label(i) = train_label(k);
        i = i+1;
    end
end
model = svmtrain(train_label',train_instance,'-t 0 -h 0');

save('model_face_new_noaug_boost','model');

