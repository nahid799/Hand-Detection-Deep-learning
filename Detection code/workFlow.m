%% workFlow
% startup.m
% extractProposals

% file_name = 'VOC2007_31.jpg.mat';
%file_name = 'VOC2007_580.jpg.mat';

% runHandDetector(file_name, encoder);
% analyzeHandDetector(file_name,100,8,2);
% %showProposal(file_name,100,8,2);
% ap = detection_ap();
% fprintf('detection ap: %f\n', ap);


%% image to test
count = 0;

% uf = dir('../data/proposals/*.mat');
% num_tests= length(uf);
% if num_tests > 50
%     num_tests = 50; 
% end

%list = [37]%, 38, 43, 44, 46, 49,57,63,64,65, 68, 71, 74, 88,91, 95];
num_tests = length(list);
num_boxes = 100;
num_rotation = 8;
num_voting = 2;

for i=2:100
    file_name = ['VOC2007_' int2str(i) '.jpg.mat'];
    %file_name = uf(i).name;
    
    fprintf('current file is %s assuming that you previously extracted proposal by running extractProposal.m file \n', ...
        file_name);
    runHandDetector(file_name, encoder);
    analyzeHandDetector(file_name,num_boxes,num_rotation)%,num_voting);
    %showProposal(file_name,100,8,2);
    ap = detection_ap([]);
    fprintf('%d detection ap: %f\n', i, ap);
end

disp('done doing the taks!');
