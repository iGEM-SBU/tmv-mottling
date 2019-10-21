% Script file: tmv_mottling_bulk
%
% Purpose: To analyze a set of images in a folder using the function
% "tmv_mottling"

% Clear the workspace
clear;

% Prompt the user to choose a folder with the images to be analyzed
directory = uigetdir('', 'Please choose a folder of photos to be analzyed');

% Check to make sure user chose a directory
if directory == 0
    % If not, display an error message, and stop the callback function
    fprintf('Error: A folder was not selected \n');
    return
end

% Filter out the pictures using the function "fullfile" such that only
% images from the file are selected
filters = fullfile(directory, {'*.jpg', '*.tiff', '*.png', '*.bmp'});

% Initialize the file empty array
file_empty = zeros(1,4);

% Loop through the four filters
for v = 1:4
    % Create the filenames based on the different filters
    varnames{v} = dir(filters{v});
    
    % Check to see if the file is empty based on the filters, and add it to
    % the array
    file_empty(v) = isempty(varnames{v});
end

% Check to make sure there is at least one file that is an image
if all(file_empty)
    % If there are no images, display an error message, and stop the
    % callback function
    fprintf('Error: No files in the folder were images \n');
    return
else
    % If there are images, find the first filter that has an image in it,
    % and save it for the folder to properly be identified
    for v = 1:4
        if ~file_empty(v)
            folder_index = v;
            break
        end
    end
end

% Add all these names to one cell array
unsortfilenames = {varnames{1}.name, varnames{2}.name, varnames{3}.name,...
    varnames{4}.name};

% Find the folder name
foldername = {varnames{folder_index}.folder};
foldername = foldername{1};

% Create the proper file path names
unsortfiles = fullfile(foldername, unsortfilenames);

% Turn the file names to lowercase
lowerfiles = lower(unsortfiles);

% Sort the lowercase files in alphabetical order, and set the sorting index
% array
[~, sorting_index] = sort(lowerfiles);

% Create a cell array to have sorted file names
files = cell(size(unsortfiles));
sortfilenames = cell(size(unsortfiles));

% Loop through the sorting index matrix
for jj = 1:length(sorting_index)
    % Add the appropriate value to the cell array. This will sort the file
    % names irrespective of whether they are uppercase or lowercase
    files{jj} = unsortfiles{sorting_index(jj)};
    sortfilenames{jj} = unsortfilenames{sorting_index(jj)};
end

% Create valid names from file names
validnames = matlab.lang.makeValidName(sortfilenames);

% Prompt the user to input the area of the standard used in the pictures.
% Note: this assumes that the same standard is used in every picture 
area = input('Please input the area of the standard in the pictures: ');

% Initialize the index for raw data, the index for summary data, and the
% index for the error tag array
raw_index = 1;
summary_index = 1;
errortag_index = 1;

% Communicate with the user that the function is analyzing
fprintf('Analyzing... \n');

% Loop through the files cell array
for ii = 1:length(files)
    % Call the function "tmv_mottling" to output the raw and summary stats
    [raw, summary, errortag] = tmv_mottling(files{ii}, area);
    
    % Create a cell array for the raw data (because there is no guarantee
    % that all pictures have the same number of spots
    total_raw_data{raw_index} = raw(:,1);
    
    % Create a table for the summary data (because each summary table is
    % the same size)
    total_summary_data(summary_index,:) = summary(1,:);
    
    % Create an array of the error tags
    errortag_array{errortag_index} = errortag;
    
    % Modify the headings of the raw data tables to reflect the image
    % names. Make sure the new name is also valid
    new_name = [total_raw_data{raw_index}.Properties.VariableNames{1},...
        '_', validnames{raw_index}];
    new_name = matlab.lang.makeValidName(new_name);
    total_raw_data{raw_index}.Properties.VariableNames{1} = new_name;
    
    % Increment the indexes
    raw_index = raw_index + 1;
    summary_index = summary_index + 1;
    errortag_index = errortag_index + 1;
end

% Clear the command window of any messages outputted during the function
% loop
clc;

% Communicate with the user that the function finished analyzing all images
fprintf('All images have been analyzed \n');

% Add a column to the summary data table that has the names of the pictures
total_summary_data(:, 8) = sortfilenames';
total_summary_data.Properties.VariableNames{8} = 'Image_Name';

% Add a column to the summary data table that has the errortags of the
% pictures
total_summary_data(:,9) = errortag_array';
total_summary_data.Properties.VariableNames{9} = 'Error_Tag';

% Communicate with the user the variables outputted
fprintf('VARIABLES OUTPUTTED: \ntotal_raw_data: area of every spot in every image \ntotal_summary_data: summary statistics for all images \n');

