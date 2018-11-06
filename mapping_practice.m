% mapping_practice

target_idx_candidate = setdiff(1:20, 1:9);
% returns the values between 1 and 20 that is not in gt_idx
% This further suggests that gt_idx should be a vector rather than a
% required scalar.

target_idx_candidate_shuffle = target_idx_candidate(randperm(length(target_idx_candidate)));
mapping = zeros(1, length(gt_idx));


% mapping cannot be longer than 20
% we need to get the proper length for mapping
% currently it 


% mapping(gt_idx) = target_idx_candidate_shuffle(1:length(gt_idx));



% gt_idx cannot exceed a certain value.