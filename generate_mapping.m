function [mapping, target_idx_candidate_shuffle] = generate_mapping(gt_idx)
% generate adversarial targets for the gt category randomly(e.g., car -> aeroplane)
% ----------------------------------------------------------------------

target_idx_candidate = setdiff(1:20, gt_idx); % returns the values between 1 and 20 that is not in gt_idx
% This further suggests that gt_idx should be a vector rather than a
% required scalar.

% shuffles colors
target_idx_candidate_shuffle = target_idx_candidate(randperm(length(target_idx_candidate)));


% mapping does nothing except cause the code to crash when using
% segmentation attacks
% Create a vector of length 20 of zeros
% mapping is used in detection
mapping = zeros(1, 20);

% turn this function off is you are running a segmentation attack
mapping(gt_idx) = target_idx_candidate_shuffle(1:length(gt_idx));

end