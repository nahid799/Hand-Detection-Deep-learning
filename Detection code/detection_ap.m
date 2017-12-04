function [ap, prec, rec, all_confidences] = detection_ap(root_dir)

all_confidences = [];
all_gts = [];

current_dir = '';
if ~isempty(root_dir)     
    current_dir = ['../data/' root_dir '/'];    
else
    current_dir = '../data/post_predictions/';    
end

uf = dir([current_dir  '*.mat']);
num_tests = length(uf);
for i= 1: num_tests 
    fprintf('current file %s\n',[current_dir uf(i).name]);
    load([current_dir uf(i).name]);
    gt = post_prediction{1,2};
    confidence = post_prediction{1,1};
    
    all_confidences = [all_confidences; confidence];
    all_gts = [all_gts; gt];
    
end
%size(all_confidences)
%size(all_gts)    

[ap, prec, rec] = ml_ap(all_confidences, all_gts, 1);  


    [all_confidences,~]=sort(all_confidences, 'descend');
    
end