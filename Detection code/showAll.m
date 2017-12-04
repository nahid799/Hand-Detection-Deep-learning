function showAll()
% shows hand-detection capability on ../data/images directory
pause on;
current_dir = '../data/images/';    
uf = dir([current_dir  '*.jpg']);
num_tests = length(uf);

gt_count = 0;
our_count = 0;
for i= 1: num_tests 
    fprintf('current file %s\n',[current_dir uf(i).name]);
     [gt, our] = showResults([uf(i).name '.mat'], 100,8, 2, -0.8151);   
     gt_count = gt_count+gt;
     our_count = our_count+our;
     pause;
    %break;
end

fprintf('recalled %d out of %d (%f)\n',our_count, gt_count, our_count/gt_count*100);
end