function calculateProposalRecall()
uf = dir('../data/proposals/*mat');
num_test = length(uf);
gt_count = 0;
our_count = 0;

for i=1:num_test
    name = uf(i).name;
    dot = strfind(name,'.');
    imname = name(1:dot-1);
    fprintf('reading %s\n', name);
    load(['../data/test_data/annotations/' imname '.mat']);    
    gt_count = gt_count + length(boxes); 
    
    load(['../data/proposals/' name]);
    if length(proposal{1,2})> 100
        our_count = our_count+ sum(proposal{1,2}(1:100,:));        
    else
        our_count = our_count+ sum(proposal{1,2});        
end

fprintf('proposal recall is %d out of %d (%f)\n', our_count, gt_count, our_count/gt_count);

end