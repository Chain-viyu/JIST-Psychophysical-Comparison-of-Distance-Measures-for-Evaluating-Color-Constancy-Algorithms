%{
Date: 2025.11.13
Author: wcy
Purpose: Perform white balance, color space conversion, and gamma correction
         on dataset images to generate images for subjective experiments
%}

%% ==================== Configuration Parameters ====================
% Set the input source: 'GT' for ground truth, or algorithm name like 'GI', 'WP', 'GW', etc.
input_source = 'GI';

% Base paths (use forward slashes)
input_base_path = '.../images_without_mcc';  % change input image folder
output_base_path = [input_source, '_image'];  % Output folder based on input_source

% Automatically determine illuminant file based on input_source
if strcmp(input_source, 'GT')
    illuminant_file = 'gt.mat';
    illuminant_var_name = 'REC_groundtruth';  % Variable name for ground truth
else
    illuminant_file = ['EstI_results_', input_source, '.mat'];  % e.g., 'EstI_results_GI.mat'
    illuminant_var_name = 'est_ills';  % Variable name for algorithm estimates
end

% Define dataset configurations
% Each entry: {subfolder_name, color_space_type, start_index}
% Input/Output paths will be automatically generated
dataset_configs = {
    '1D', '1D', 1;
    '5D', '5D', 87;
};

% Gamma correction value
gamma_value = 2.2;

% Image file extension
image_extension = '*.png';

%% ==================== Generate Full Paths for Datasets ====================
% Automatically generate input and output paths based on input_source
num_datasets = size(dataset_configs, 1);
datasets = cell(num_datasets, 4);

for d = 1:num_datasets
    subfolder = dataset_configs{d, 1};
    color_space = dataset_configs{d, 2};
    start_index = dataset_configs{d, 3};
    
    % Generate paths using forward slashes
    datasets{d, 1} = [input_base_path, '/', subfolder, '/'];
    datasets{d, 2} = [output_base_path, '/', subfolder, '/'];
    datasets{d, 3} = color_space;
    datasets{d, 4} = start_index;
end

%% ==================== Load Illuminant Data ====================
fprintf('=== White Balance Processing ===\n');
fprintf('Input source: %s\n', input_source);
fprintf('Loading illuminant data from: %s\n', illuminant_file);

% Check if illuminant file exists
if ~exist(illuminant_file, 'file')
    error('Illuminant file not found: %s', illuminant_file);
end

data = load(illuminant_file);

% Extract the illuminant matrix using the specified variable name
if isfield(data, illuminant_var_name)
    Est_Illuminants = data.(illuminant_var_name);
else
    error('Variable "%s" not found in %s.\nAvailable variables: %s', ...
        illuminant_var_name, illuminant_file, strjoin(fieldnames(data), ', '));
end

fprintf('Loaded %d illuminant estimates\n', size(Est_Illuminants, 1));

%% ==================== Process Each Dataset ====================
for d = 1:size(datasets, 1)
    % Get dataset configuration
    Input_path = datasets{d, 1};
    Output_path = datasets{d, 2};
    color_space = datasets{d, 3};
    start_index = datasets{d, 4};
    
    fprintf('\n--- Processing dataset: %s ---\n', color_space);
    fprintf('Input folder: %s\n', Input_path);
    fprintf('Output folder: %s\n', Output_path);
    
    % Check if input directory exists
    if ~exist(Input_path, 'dir')
        warning('Input directory not found: %s. Skipping...', Input_path);
        continue;
    end
    
    % Create output directory if it doesn't exist
    if ~exist(Output_path, 'dir')
        mkdir(Output_path);
        fprintf('Created output directory: %s\n', Output_path);
    end
    
    % Get list of images in the input folder
    namelist = dir(strcat(Input_path, image_extension));
    num_images = length(namelist);
    
    if num_images == 0
        warning('No images found in %s', Input_path);
        continue;
    end
    
    fprintf('Found %d images to process\n', num_images);
    
    % Process each image
    for i = 1:num_images
        % Get image filename
        name = namelist(i).name;
        
        % Get corresponding illuminant estimate (adjust index based on start_index)
        ill_index = start_index + i - 1;
        
        if ill_index > size(Est_Illuminants, 1)
            warning('Illuminant index %d exceeds available data. Skipping image %s', ...
                ill_index, name);
            continue;
        end
        
        current_illuminant = Est_Illuminants(ill_index, :);
        
        % Read and convert image to double precision
        input_im = imread(strcat(Input_path, name));
        input_im = im2double(input_im);
        
        % Apply white balance correction
        % Normalize R and B channels relative to G channel
        corrected_im = input_im;
        corrected_im(:,:,1) = input_im(:,:,1) / (current_illuminant(1) / current_illuminant(2));
        corrected_im(:,:,2) = input_im(:,:,2);  % G channel unchanged
        corrected_im(:,:,3) = input_im(:,:,3) / (current_illuminant(3) / current_illuminant(2));
        
        % Apply color space transformation
        corrected_im = trans(corrected_im, color_space);
        
        % Apply gamma correction
        corrected_im = gama(corrected_im, gamma_value);
        
        % Clip values to valid range [0, 1]
        corrected_im = max(0, min(1, corrected_im));
        
        % Generate output filename and save using forward slashes
        output_fullpath = [Output_path, 'out', num2str(i), '.png'];
        imwrite(corrected_im, output_fullpath);
        
        % Display progress
        if mod(i, 10) == 0 || i == num_images
            fprintf('Processed %d/%d images\n', i, num_images);
        end
    end
end

fprintf('\n=== Processing complete ===\n');
fprintf('Results saved to: %s\n', output_base_path);