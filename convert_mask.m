% create masks for DAG algorithm
clc
clear
% addpath('../SEQ1_segment')
% imread('resized_gray.0000000.png');
image_files = dir('../SEQ1_segment/*.png');      
nfiles = length(image_files);    % Number of files found

for ii=1:nfiles
    current_filename = image_files(ii).name;
    current_image = imread(current_filename);
    mask_double = im2double(current_image)*255;
    save(['mask.',current_filename,'.mat'],'mask_double');
    images{ii} = current_image;
end