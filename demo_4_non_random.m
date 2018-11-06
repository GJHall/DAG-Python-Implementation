% % ------------ This script is for generating adversarial examples for
% segmentation and detection (https://arxiv.org/abs/1703.08603)
addpath('/home/garrett/MATLAB/caffe-master/caffe-rc5/DAG-master/code/new_images_for_report/virtual_seq_4_right/new_masks')
clear
close all;

config ='generate_config_3'; % see generate_config.m

% image to be attacked. These files be set up so all you have to change is
% the numerical value.
new_mask    = 'mask_gray_0000276_seg.png.mat';
new_image   = 'resize_0000276.png';
new_gray    = 'gray_0000276_seg.png'; % grayscale image
new_result  = 'reg_00000276_seg.png'; % what attack will be saved as

try
    eval(config);
catch
    keyboard;
end

% add matlab caffe path
addpath('../../matlab/');
% addpath('/home/garrett/18_s_project/caffe-master/DAG-master/code/new_images_for_report/virtual_seq_4_right')

% load caffe models
caffe.set_mode_gpu();
% caffe.set_mode_cpu();
caffe.set_device(0)
caffe.reset_all();
net = caffe.Net(net_model, net_weights, 'test'); % these parameters are passed with generate_config.m

%% generating adversarial examples now
fprintf('now generating adversarial examples for %s\n\n', model_select);

% prepare image info. reads in the images
% seg uses jpg and png
% det uses jpg and xml

image = imread(new_image);
% image = imread(sprintf('../data/%s.png', im_name));

%%% Begin Detection Attack
% image is used for detection attack, NOT segmentation attack

if strfind(model_select, 'det')
    % for the detection network, input short size is 600
    image = myresize(image, 600, 'short'); 
end

if size(image, 3) == 1 % W x H x C, where C=3. Looks for 1 dimensional images.
    image = cat(3, image, image, image); % Converts grascale images to 3 channels with same properties
end
% convert image format
image = image(:, :, [3, 2, 1]);  % format: W x H x C with BGR channels
image = single(image);  % convert from uint8 to single
image = bsxfun(@minus, image, mean_data);% subtract mean_data (already in W x H x C, BGR)
image = permute(image, [2, 1, 3]);  % flip width and height

% r means noise perturbation, itr means iteration number
if strfind(model_select, 'det')
    xml_info = VOCreadrecxml(sprintf('../data/%s.xml', im_name));
    annotation = xml_info.objects; % object detection annotation
    ratio = 600/min(xml_info.imgsize(1:2));  
    % use nms = 0.9 in RPN and choose Top 3000 boxes
    load(sprintf('../data/%s_box_3000_%s.mat', im_name, model_select)); 
    boxes = aboxes(:,1:4);
    % extract gt, construct sturcture like [obj_index, bbox]
    gt = zeros(numel(annotation), 5); 
    for j = 1:numel(annotation)
        obj_idx = strfind(legends, annotation(j).class);
        obj_idx = cellfun('isempty', obj_idx);
        obj_idx = find(obj_idx==0);
        gt(j,:) = [obj_idx, ratio*annotation(j).bbox];
    end
    mapping = generate_mapping(unique(gt(:,1))-1);
    mapping(mapping~=0) = mapping(mapping~=0) + 1;
    mapping = [1, mapping]; % leave background class untouched
    [r, itr, status, box_num] = fooling_det_net(image, boxes, gt, net, mapping, config);    
    detection_visualization(image+r, boxes, net, config);
%%% detection attack end

%%% Begin Segmentation Attack
else if strfind(model_select, 'seg')
        % prepare segmentation data
        seg_mask_ori = imread(new_gray); % reads in segmentated image as ground truth
        seg_mask_ori(seg_mask_ori == 255) = 0; % ignore white space. set all white values to black
%         gt_idx = unique(seg_mask_ori); % determines the amount of unique colors from segment
        
        % I am not sure if this functions works properly. It produces an
        % array in certain cases when it needs to be scalar.
        
        % It should actually be a vector of the colors that exist in the
        % image as the ground truth
%         gt_idx(gt_idx == 0) = []; % ignore class background
        
        
%         [~, target_idx_candidate_shuffle] = generate_mapping(gt_idx);  % target_idx is in generate_mapping.m   
%         load(sprintf('../data/%s.mat', shape)); % load pre-defined mask
        load(new_mask)
        
        % assigns a random color
        % mask ~=0 means mask does not equal zero. 
        % ~ is the not operator
%         mask(mask~=0) = target_idx_candidate_shuffle(mask(mask~=0));
        
%         mask=load(new_mask);
        
        % see fooling_seg_net.m
        [r, itr, status, box_num, seg_result] = fooling_seg_net(image, double(mask), double(seg_mask_ori), net, config);
        imshow(seg_result, colormap);
        imwrite(seg_result, colormap, new_result)
    else
        error('this model type is not available in our setting')
        
    end
end

%% show another visualization
% restore the images to normal status
image_fool = image + r;
image_fool = permute(image_fool, [2,1,3]);
image_fool = bsxfun(@plus, image_fool, mean_data);
image_fool = image_fool(:, :, [3,2,1]);

% also do processing for r
r = permute(r, [2,1,3]);
r = r(:, :, [3,2,1]);

fig = figure(2);
scr_size = get(0,'screensize');
set(fig,'pos',[scr_size(3)/2,scr_size(4)/2,900,250]);
pbaspect([1,1,1])
subplot(1,3,1)
imagesc((image_fool - r)/255)
subplot(1,3,2)
imagesc((image_fool)/255)
subplot(1,3,3)
imagesc(r)

imwrite(r,['noise_',new_image]);
imwrite(image_fool/255,['adversarial_',new_image]);

caffe.reset_all();