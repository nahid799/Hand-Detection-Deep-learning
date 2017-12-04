clear;
%% preparing deepeval feature extractor
addpath('..');
model_dir = '../models/CNN_M_128';
param_file = sprintf('%s/param.prototxt', model_dir);
model_file = sprintf('%s/model', model_dir);
average_image = sprintf('%s/../mean.mat',model_dir);
use_gpu = false;
if use_gpu
    featpipem.directencode.ConvNetEncoder.set_backend('cuda');
end

encoder = featpipem.directencode.ConvNetEncoder(param_file, model_file, ...
    average_image, ...
    'output_blob_name', 'fc7');
%  encoder.augmentation = 'aspect_corners';
%  encoder.augmentation_collate = 'sum';%max

%% warm-up mkl engine with dummy run 
image_path = '../data/start.jpg';
im = imread(image_path);

size_x = size(im,2);
size_y = size(im,1);
padding = 0.2;

xmin = fix(6.301989e+01);
ymin= fix(3.028980e+02);
xmax= fix(1.381817e+02);
ymax= fix(3.691260e+02);
width = xmax - xmin; height = ymax - ymin;
xpad = fix(width*padding/2);
ypad = fix(height*padding/2);
    

% im_hand = im(ymin:ymax, xmin:xmax,:);    
% imshow(im_hand);
% fprintf('(%i %i) (%i %i) width:%i height:%i xpad:%i ypad:%i\n',ymin, ymax, xmin, xmax, width, height, xpad,ypad);
% waitforbuttonpress;    
    
if (xmin-xpad)<1
    xmin = 1;
else
    xmin = xmin-xpad;
end
if (ymin-ypad)<1
    ymin = 1;
else
    ymin = ymin-ypad;
end

if (xmax + xpad)> size_x
    xmax = size_x;
else
    xmax = xmax + xpad;
end

if (ymax + ypad)> size_y
    ymax = size_y;
else
    ymax = ymax + ypad;
end

% fprintf('(%i %i) (%i %i) width:%i height:%i xpad:%i ypad:%i\n',ymin, ymax, xmin, xmax, width, height, xpad,ypad);
im_hand = im(ymin:ymax, xmin:xmax,:);
% imshow(im_hand);
% waitforbuttonpress;

im_hand = imresize(im_hand, [256 256]);
% imshow(im_hand);

im_hand = featpipem.utility.standardizeImage(im_hand); % ensure of type single, w. three channels           
code = encoder.encode(im_hand);
train_instance = double(code');
train_label=1;

% [label] = svmpredict(train_label',train_instance,model, '-b 0 -q');
% fprintf( 'predicted output is %d\n',label);
