% Vogado's Image Segmentation Method
%
% @author       Khakim Assidiqi <hamas182@gmail.com>
% @created      march, 4th 2020
%% initialize
clc
clear all
close all

% loading rgb image
image_path = 'all-idb/02.jpg';
image_rgb = imread(image_path); %Read the color image

figure('name','Vogado et al. (2016) Method Remake');

%  convert into CIELAB
colorTransform = makecform('srgb2lab');
lab = applycform(image_rgb, colorTransform);
% get only *b (yellow) from CIELAB
lab_y = lab(:,:,3);
% apply contrast adjustment
lab_y_con = imadjust(lab_y);
% apply 7x7 median filter
lab_y_con_med = medfilt2(lab_y_con, [7 7]);

% convert into cmyk 
colorTransform = makecform('srgb2cmyk');
image_cmyk = applycform(image_rgb, colorTransform);
% get only M (magenta/pink) from CMYK
cmyk_m = image_cmyk(:,:,2);
% apply contrast adjustment
cmyk_m_con = imadjust(cmyk_m);
% apply 7x7 median filter
cmyk_m_con_med = medfilt2(cmyk_m_con, [7 7]);

% subtract *b(with cont adj and medfilter) with M
img_subt = imsubtract(cmyk_m_con_med, lab_y_con_med);

% turn into grayscale 
img_subt = 255 * repmat(uint8(img_subt), 1, 1, 3);
img_gray = rgb2gray(img_subt);
img_gray = ind2rgb(img_gray, gray(256));


% do clustering segmentation
img_clustering = kmeans(img_gray, 4);
% img_clustering = img_gray;

% morphological operation
img_morpho_input = img_clustering;
% 
% 
% dilating
se = strel('disk',2);
afterDilating = imdilate(img_morpho_input,se);
% eroding
se = strel('disk',1);
afterEroding = imerode(afterDilating,se);
% morpho out
img_morpho = afterEroding;

subplot(2,4,1);
imshow(image_rgb);
title('Original', 'FontSize', 8);

subplot(2,4,2);
imshow(cmyk_m);
title('M from CMYK', 'FontSize', 8);


subplot(2,4,3);
imshow(lab_y);
title('*b from CIELAB', 'FontSize', 8);


subplot(2,4,4);
imshow(cmyk_m_con);
title('M con adj + med(7x7)', 'FontSize', 8);

subplot(2,4,5);
imshow(lab_y_con_med);
title('*b con adj + med(7x7)', 'FontSize', 8);

subplot(2,4,6);
imshow(img_subt);
title('*b - M', 'FontSize', 8);

subplot(2,4,7);
imshow(img_clustering);
title('k-means clustering', 'FontSize', 8);

subplot(2,4,8);
imshow(img_morpho);
title('Morphological Operation', 'FontSize', 8);