%%  
% Create dataset from SYNTHIA-SF virtual dataset

% load image from folder
% select images from GTLeftDebug and RGBLeft. since GTLeftDebug has
% additional steps, those images will be modified with a different program.

% image_path = '/datasets/SYNTHIA-SF/SEQ1/GTLeftDebug'
% image = imread(image_path);
% resized_image = imresize(image, [500,500]);
% imwrite(org_1_500, '../data/org_1_500.jpg')
% 
% 
% 
% for:
%     org_1 = imread(sprintf('../data/%s.jpg',0000000+i')); % let i start at 0
% resize image

% convert to grayscale

% Select desired pixels from list. set all others equal to zero

% create unique mask for each individual image

%% 
% Get list of all BMP files in this directory
% DIR returns as a structure array.  You will need to use () and . to get
% the file names.
image_files = dir('*.png');      
nfiles = length(image_files);    % Number of files found

for ii=1:nfiles
   current_filename = image_files(ii).name;
   current_image = imread(current_filename);
   resized_image = imresize(current_image, [500,500]);
   imwrite(resized_image, ['../SEQ1_resize_segment/SEQ1_resize/resized.',current_filename]);
   images{ii} = current_image;
end