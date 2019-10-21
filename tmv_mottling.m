% function [raw, summary] = tmv_mottling(filepath, area, histstate)
%
% Purpose: To calculate data of the mottling of a leaf in a picture, with a
% standard included to calculate real areas. 
% 
% Define variables:
%   Input variables:
%       filepath: the combined file name and path name of the image file to
%       be analyzed. This can be generated from the "fullfile" function
%       area: the area of the standard included in the image. If an empty
%       value is inputted, the  statistics are calculated in pixels
%       histstate: an optional parameter of whether the user would like the
%       function to create a histogram('on' or 'off'). Default is 'off'.
%   Output variables:
%       raw: tabulated raw data of the areas of each spot in the leaf,
%       specified as one column
%       summary: tabulated summary data describing the data. In order, this
%       is the total area of the leaf, the total area infected, the percent
%       infected, the number of spots, the average area of the spots, the
%       standard deviation of the spots, and the standard error of the
%       spots. This will be specified as one row


function [raw, summary] = tmv_mottling(filepath, area, histstate)

% INITIALIZATION

% Check to make sure the user inputted the correct number of parameters
narginchk(1,3)

% Check to make sure the filepath variable is inputted correctly
if ~ischar(filepath)
    % If not, output an error message and stop the callback function
    fprintf('Error: A valid file path name was not inputted \n');
    return
end

% Check to see if user inputted an area correctly. Flag this information
if ~exist('area', 'var')
    % If the variable does not exist, flag this information
    area_empty = 1;
elseif ~isnumeric(area)
      % If the area is not valid, output an error message and stop the
      % callback function
      fprintf('Error: A valid area was not inputted \n');
      return
elseif isempty(area)
    % If the area is empty, flag this information
    area_empty = 1;
else
    % If the area is valid, flag this information
    area_empty = 0;
end

% Set the histogram state variable accordingly

if nargin <= 2
    histstate = 'off';
end
switch lower(histstate)
    case 'on'
        histstate = 1;
    case 'off'
        histstate = 0;
    otherwise
        fprintf('Error: The histogram value was not set accordingly \n');
        return
end

% LOADING AND BINARIZING IMAGE DATA

% Read the image file using the function "imread"
original_photo_data = imread(filepath);

% Convert RGB to greyscale using the weighted formula
greyscale = 0.3 .* original_photo_data(:,:,1) + ...
    0.59 .* original_photo_data(:,:,2) + ...
    0.11 .* original_photo_data(:,:,3);

% Initialize the processed image data
processed_image_data = original_photo_data;

% Set this intensity to each pixel in the new image data. Since each pixel
% will have the same intensity, it will appear as a shade of grey. Lighter
% areas (spots) will appear light, while darker areas (leaf) will appear
% dark
processed_image_data(:,:,1) = greyscale;
processed_image_data(:,:,2) = greyscale;
processed_image_data(:,:,3) = greyscale;

% Binarize this image using the function "imbinarize". Use only one channel
binary_image_data = imbinarize(processed_image_data);
binary_image_data = binary_image_data(:,:,1);

% FINDING TOTAL AREA OF LEAF AND STANDARD IN PIXELS

% Complement the image. This will make the background and spots black, and
% the leaf and standard white
full_leaf_standard_data = imcomplement(binary_image_data);

% Fill the holes in the leaf using the function "imfill"
full_leaf_standard_data = imfill(full_leaf_standard_data, 'holes');

% Use function "bwboundaries" to get the label matrix of the image
[~, label] = bwboundaries(full_leaf_standard_data);

% Use function "bwconncomp" to find connected components in the image,
% which should just be the full leaf and the standard
leaf_standard = bwconncomp(full_leaf_standard_data);

% Use function "regionprops" to get the eccentricity and the areas of the
% objects. Save these values to arrays for easier processing
leaf_standard_stats = regionprops(leaf_standard, 'Eccentricity', 'Area');
eccentricity = [leaf_standard_stats.Eccentricity];
areas = [leaf_standard_stats.Area];

% Sort the areas in descending order, and save the sorting index
[~, sort_index] = sort(areas, 'descend');

% Compare the eccentricities of the two objects with the largest areas
if eccentricity(sort_index(1)) > eccentricity(sort_index(2))
    % If the eccentricity of the first object is larger, it is the leaf.
    % Therefore, the second object is the standard. Save this index
    leaf_index = sort_index(1);
    standard_index = sort_index(2);
else
    % Otherwise, the eccentricity of the second object is larger, so it is
    % the leaf. Therefore, the first object is the standard. Save both of
    % these areas
    leaf_index = sort_index(2);
    standard_index = sort_index(1);
end

% Note: it is assumed the above is true based on data carried out by the
% script "tmv_mottling_program_eccentricity_analysis" on 6/24/19

% Save the areas of the leaf and the standard
area_leaf_pixels = areas(leaf_index);
area_standard_pixels = areas(standard_index);

% Adjust the label matrix so that everything that is the leaf is a "1", and
% everything that is not the leaf is a "0"
label(label ~= leaf_index) = 0;
label(label == leaf_index) = 1;

% If the area is empty, set the area of the standard equal to the area of
% pixels. This will keep all areas calculated in terms of pixels
if area_empty
    area = area_standard_pixels;
end

% FINDING AREA OF SPOTS IN PIXELS

% Clear the border of the binarized image. This will leave only the spots
% as white
only_spots_data = imclearborder(binary_image_data);

% Use the label matrix to only get the spots within the leaf
only_spots_data = only_spots_data & label;

% Use the function "bwconncomp" to find all the spots in the image
spots = bwconncomp(only_spots_data);

% Use the function "regionprops" to get the area of all the spots. Save
% this into an array for easier processing
spots_data = regionprops(spots, 'Area');
spots_areas = [spots_data.Area];

% CALCULATING DATA

% Calculate the area per pixel based on the standard
area_per_pixel = area / area_standard_pixels;

% Convert the total leaf area and the area of each spot to cm^2 based on
% the area per pixel
total_area_leaf = area_leaf_pixels * area_per_pixel;
spots_areas_cm2 = spots_areas .* area_per_pixel;

% Calculate the total area infected by summing the areas of each spot
total_area_infected = sum(spots_areas_cm2);

% Calculate the percent infected
percent_infected = total_area_infected / total_area_leaf;

% Calculate the average, standard deviation, and standard error of the
% areas of each spots
average_area_spots = mean(spots_areas_cm2);
std_spots = std(spots_areas_cm2);
se_spots = std_spots / sqrt(spots.NumObjects);

% TABULATING AND EXPORTING DATA

% Check the inputs to use the write units from the analysis
if area_empty
    % If no area was inputed, use the units of pixels
    var_names_raw = {'Area_px'};
    var_names_summary = {'Total_Area_Leaf_px', 'Total_Area_Infected_px',...
        'Percent_Infected', 'Number_Spots', 'Average_Area_Spots_px',...
        'Standard_Deviation_Areas_px', 'Standard_Error_Areas_px'};
else
    % If an area was inputed, use the units of cm^2
    var_names_raw = {'Area_cm2'};
    var_names_summary = {'Total_Area_Leaf_cm2', 'Total_Area_Infected_cm2',...
        'Percent_Infected', 'Number_Spots', 'Average_Area_Spots_cm2',...
        'Standard_Deviation_Areas_cm2', 'Standard_Error_Areas_cm2'};
end

% Tabulate the raw data and the summary data from the spot analysis
raw = table([spots_areas_cm2]', 'VariableNames', var_names_raw);
summary = table(total_area_leaf, total_area_infected, percent_infected,...
    spots.NumObjects, average_area_spots, std_spots, se_spots,...
    'VariableNames', var_names_summary);

% CREATING HISTOGRAM

% Create titles and axes labels based on the units
if area_empty
    labels = {'Area of Spots (px)', 'Area (px)', 'Number'};
else
    labels = {'Area of Spots (cm^{2})', 'Area (cm^{2})', 'Number'};
end

% Check to see if user wanted to create a histogram of the data
if histstate
    % If so, create a histogram based on the areas of the spots. Add a
    % title and axes labels to the histogram
    histogram(spots_areas_cm2);
    title(labels(1));
    xlabel(labels(2));
    ylabel(labels(3));
end

end
