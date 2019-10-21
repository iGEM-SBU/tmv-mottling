function varargout = Plant_Mottling_Analysis(varargin)
% PLANT_MOTTLING_ANALYSIS MATLAB code for Plant_Mottling_Analysis.fig
%      PLANT_MOTTLING_ANALYSIS, by itself, creates a new PLANT_MOTTLING_ANALYSIS or raises the existing
%      singleton*.
%
%      H = PLANT_MOTTLING_ANALYSIS returns the handle to a new PLANT_MOTTLING_ANALYSIS or the handle to
%      the existing singleton*.
%
%      PLANT_MOTTLING_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLANT_MOTTLING_ANALYSIS.M with the given input arguments.
%
%      PLANT_MOTTLING_ANALYSIS('Property','Value',...) creates a new PLANT_MOTTLING_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Plant_Mottling_Analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Plant_Mottling_Analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Plant_Mottling_Analysis

% Last Modified by GUIDE v2.5 08-Jul-2019 13:45:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Plant_Mottling_Analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @Plant_Mottling_Analysis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Plant_Mottling_Analysis is made visible.
function Plant_Mottling_Analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Plant_Mottling_Analysis (see VARARGIN)

% Choose default command line output for Plant_Mottling_Analysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Plant_Mottling_Analysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Plant_Mottling_Analysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in download_button.
function download_button_Callback(hObject, eventdata, handles)
% hObject    handle to download_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLABse_sop
% handles    structure with handles and user data (see GUIDATA)

% Check to make sure the image was analyzed
if ~isfield(handles, 'spots_areas_cm2')
    % If not, display an error message, and stop the callback function
    msgbox('Please analyze an image first');
    return
end

% Tabulate the raw spot data from the spot analysis
tabulated_raw_data = table([handles.spots_areas_cm2]', 'VariableNames', {'Area_cm2'});

% Tabulate the summary data from the spot analysis
tabulated_summary_data = table(handles.total_area_leaf, handles.total_area_infected,...
    handles.percent_infected, handles.number_spots, handles.average_area_spots,...
    handles.std_spots, handles.se_spots, 'VariableNames', {'Total_Area_Leaf_cm2',...
    'Total_Area_Infected_cm2', 'Percent_Infected', 'Number_Spots', 'Average_Area_Spots_cm2',...
    'Standard_Deviation_Areas_cm2', 'Standard_Error_Areas_cm2'});

% Create cell array of tables
tables = {tabulated_raw_data, tabulated_summary_data};

% Initialize the dialogue options for prompting the user to save
dialogue_options = {'raw data?', 'summary data?', 'Save Raw Data As', 'Save Summary Data As'};

% Loop through the two saving conditions: saving the raw data, and saving
% the summary data
for v = 1:2
    % Ask the user if they would like to save
    answer = questdlg(['Would you like to save the ', dialogue_options{v}]);
    switch answer
        case 'Yes'
            % If yes, use function "uiputfile" to get the path name and
            % file name for where the user wants to save the table
            [save_file_name, save_path_name] = uiputfile('*.xlsx', dialogue_options{v+2});
            
            % Check to make sure user chose a file
            if save_file_name == 0
                % If not, continue to the next iteration
                continue
            end
            
            % Use "fullfile" function to combine path name and file name
            save_pathfile = fullfile(save_path_name, save_file_name);
            
            % Write the data to the selected file
            writetable(tables{v}, save_pathfile);
            
        case 'No'
            % If no, continue to the next iteration
            continue
        otherwise
            % Otherwise, break the loop
            return
    end
end


% --- Executes on button press in load_button.
function load_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Alert users on specific requirements for pictures to be loaded so that
% they can be properly analyzed
waitfor(msgbox('Make sure the image has a white background, there is a square standard, and that only the leaf and standard are in the image.'));

% Use "uigetfile" function to get the filename and filepath
[picture_filename, picture_pathname] = uigetfile('*.jpg;*.tiff;*.png;*.bmp', 'Select Picture');

% Check to make sure user chose a file
if picture_filename == 0
    % If not, stop the callback function
    return
end

% Use "fullfile" function to combine pathname and filename
picture_pathfile = fullfile(picture_pathname, picture_filename);

% Use "imread" function to read the image file
original_photo_data = imread(picture_pathfile);

% Load the image data onto the axes, and get rid of tick marks
image(original_photo_data, 'Parent', handles.Original_Photo);
set(handles.Original_Photo, 'XTick', []);
set(handles.Original_Photo, 'YTick', []);

% Store the original picture data handle in the GUI
handles.original_photo_data = original_photo_data;
guidata(hObject, handles);


% --- Executes on button press in binarize_button.
function binarize_button_Callback(hObject, eventdata, handles)
% hObject    handle to binarize_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check to make sure an image is loaded in the axes
if ~isfield(handles, 'original_photo_data')
    % If not, display an error message, and stop the callback function
    msgbox('Please upload an image first');
    return
end

% Convert RGB to grey-scale using the weighted formula
grey_scale_data = 0.3 .* handles.original_photo_data(:,:,1) + ...
    0.59 .* handles.original_photo_data(:,:,2) + ...
    0.11 .* handles.original_photo_data(:,:,3);

% Initialize the processed image data (grey scale)
processed_image_data = handles.original_photo_data;

% Assign this intensity to each pixel in a new image data. Since each pixel
% will have the same intensity, it will appear as a shade of grey. Lighter
% areas (spots) will appear light, while darker areas (leaf) will appear
% dark
processed_image_data(:,:,1) = grey_scale_data;
processed_image_data(:,:,2) = grey_scale_data;
processed_image_data(:,:,3) = grey_scale_data;

% Binarize the image using the function "imbinarize"
binary_image_data = imbinarize(processed_image_data);

% Save this image data to the GUI. Use only one channel
handles.binary_image_data = binary_image_data(:,:,1);
guidata(hObject, handles);

% Load this image data onto the axes, and get rid of tick marks
imshow(handles.binary_image_data, 'Parent', handles.Binary_Image);
set(handles.Binary_Image, 'XTick', []);
set(handles.Binary_Image, 'XTick', []);


% --- Executes on button press in clear_button.
function clear_button_Callback(hObject, eventdata, handles)
% hObject    handle to clear_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Initialize arrays for all handles created during processing (except for 
% selection handles for dialogue boxes), all axes, all static text boxes,
% and initial strings for text boxes
processed_handles = {'original_photo_data', 'binary_image_data', 'total_area_leaf', 'total_area_infected','percent_infected',...
    'number_spots','average_area_spots','std_spots','se_spots', 'spots_areas_cm2'};
axes_handles = {handles.Original_Photo, handles.Binary_Image,...
    handles.Full_Leaf_Standard_Image, handles.Only_Spots_Image, handles.Histogram_Image};
static_text_handles = {handles.area_standard_text, handles.total_area_leaf_text, ...
    handles.total_area_infected_text, handles.percent_infected_text, handles.number_spots_text,...
    handles.average_area_spots_text, handles.standard_deviation_text, handles.standard_error_text};
static_text_initials = {'Area of Standard (cm^2) = ', 'Total Area of Leaf (cm^2) = ',...
    'Total Area Infected (cm^2) = ', 'Percent Infected = ', 'Number of Spots = ',...
    'Average Area of Spots (cm^2) = ', 'Standard Deviation of Areas (cm^2) = ',...
    'Standard Error of Areas (cm^2) = '};

% Loop through the processed handles array
for ii = 1:length(processed_handles)
    % If the field exists, delete it
    if isfield(handles, processed_handles{ii})
        handles = rmfield(handles, processed_handles{ii});
    end
end

% Save all handles to the GUI
guidata(hObject, handles);

% Loop through the axes handle array
for ii = 1:length(axes_handles)
    % Clear the axes
    cla(axes_handles{ii});
    % Reload the axes
    image([], 'Parent', axes_handles{ii});
    set(axes_handles{ii}, 'XTick', []);
    set(axes_handles{ii}, 'YTick', []);
end

% Loop through the static text arrays
for ii = 1:length(static_text_handles)
    % Reset static text
    set(static_text_handles{ii}, 'String', static_text_initials{ii});
end


% --- Executes on button press in analyze_button.
function analyze_button_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% INITIALIZATION

% Check to make sure an image was binarized
if ~isfield(handles, 'binary_image_data')
    % If not, display an error message, and stop the callback function
    msgbox('Please binarize an image first');
    return
end

% FINDING AREA OF STANDARD IN CM^2

% Initialize the dialogue options for the message boxes, the interpeter
% setting, and the initial selections
dialogue = {'area', 'side length', 'cm^{2}', 'cm', 'an area of 4 cm^{2}).',...
    'a side length of 4 cm).'};
opts.Interpreter = 'tex';
if ~isfield(handles, 'style_selection')
    handles.style_selection = 1;
    guidata(hObject, handles);
end
if ~isfield(handles, 'area_input')
    handles.area_input = {''};
    guidata(hObject, handles);
end

% Prompt the user for the selection style of the area input
[selection, ~] = listdlg('PromptString', 'Choose what you are going to input:',...
    'ListString', {'Area', 'Side Length'}, 'SelectionMode',...
    'single', 'InitialValue', handles.style_selection, 'ListSize', [180 30]);

% Check to make sure the user chose an input
if isempty(selection)
    % If not, stop the callback function
    return
end

% Save selection so that user can reselect the same the option next time
% they open the dialogue box
handles.style_selection = selection;
guidata(hObject, handles);

% Prompt the user to input the value, as specified by their selection
prompt = ['Please input the ', dialogue{selection}, ' in ', dialogue{selection + 2},...
    ' (For example, an input of "4" will be interpreted as ', dialogue{selection + 4}];
area_input = inputdlg(prompt, 'Input Value', [1 45], handles.area_input, opts);

% Check to make sure the user inputted any answer
if isempty(area_input)
    % If not, stop the callback function
    return
end

% Check to make sure the user inputted a numerical answer
area_input = str2num(area_input{1});
if isempty(area_input)
    % If not, display an error message, and stop the callback function
    msgbox('Please input a valid number');
    return
end

% Save input so that user can reselect the same option next time they open
% the dialogue box
handles.area_input = {num2str(area_input)};
guidata(hObject, handles);

% Initialize the scaling array, an array of scaling factors for the
% possible inputs
scaling_array = [1 area_input];

% Scale the input appropriately to get the area of the standard in cm^2
area_standard_cm2 = area_input * scaling_array(selection);

% FINDING TOTAL AREA OF LEAF AND STANDARD IN PIXELS

% Complement the image. This will make the background and spots black, and
% the leaf and standard white
full_leaf_standard_data = imcomplement(handles.binary_image_data);

% Use "imfill" function to fill in the holes in the leaf
full_leaf_standard_data = imfill(full_leaf_standard_data, 'holes');

% Load this image onto the axes, get rid of tick marks, and save the image
imshow(full_leaf_standard_data, 'Parent', handles.Full_Leaf_Standard_Image);
set(handles.Full_Leaf_Standard_Image, 'XTick', []);
set(handles.Full_Leaf_Standard_Image, 'YTick', []);
hold(handles.Full_Leaf_Standard_Image, 'on');
handles.full_leaf_standard_data = full_leaf_standard_data;
guidata(hObject, handles);

% Use "bwconncomp" function to find connected components in image, which
% should be just the full leaf and the standard
leaf_standard = bwconncomp(full_leaf_standard_data);

% Use "regionprops" to get the eccentricity and area of the two objects.
% Save these values to arrays for easier processing
leaf_standard_stats = regionprops(leaf_standard, 'Eccentricity', 'Area');
eccentricity = [leaf_standard_stats.Eccentricity];
areas = [leaf_standard_stats.Area];

% Use function "bwboundaries" to find the boundaries of all objects
[boundaries, label] = bwboundaries(full_leaf_standard_data, 'noholes');

% Sort the areas in descending order, and save the sorting index
[~, sort_index] = sort(areas, 'descend');

% Compare the eccentricities of the two objects with the largest areas
if eccentricity(sort_index(1)) > eccentricity(sort_index(2))
    % If the eccentricity of the first object is larger, it is the leaf.
    % Therefore, the second object is the standard. Save the index
    leaf_index = sort_index(1);
    standard_index = sort_index(2);
else
    % Otherwise, the eccentricity of the second object is larger, so it is
    % the leaf. Therefore, the first object is the standard. Save the index
    leaf_index = sort_index(2);
    standard_index = sort_index(1);
end

% Note: it is assumed the above is true based on data carried out by the
% script "tmv_mottling_program_eccentricity_analysis" on 6/24/19

% Change the label matrix, so the leaf is marked as a "1", and everything
% else is marked as a "0"
label(label ~= leaf_index) = 0;
label(label == leaf_index) = 1;

% Save the area of the leaf and the standard
area_leaf_pixels = areas(leaf_index);
area_standard_pixels = areas(standard_index);

% Plot the boundary of the standard in magenta, and the leaf in green
border_leaf = boundaries{leaf_index};
border_standard = boundaries{standard_index};
plot(handles.Full_Leaf_Standard_Image, border_leaf(:,2), border_leaf(:,1), 'g', 'Linewidth', 2);
plot(handles.Full_Leaf_Standard_Image, border_standard(:,2), border_standard(:,1), 'm', 'Linewidth', 2);
hold(handles.Full_Leaf_Standard_Image, 'off');

% FINDING AREA OF SPOTS IN PIXELS

% Clear the border of the binarized image. This will leave only the spots
% in the image as white
only_spots_data = imclearborder(handles.binary_image_data);

% Use the label matrix to only analyze the spots on the leaf
only_spots_data = only_spots_data & label;

% Load this image onto the axes, and get rid of tick marks
imshow(only_spots_data, 'Parent', handles.Only_Spots_Image);
set(handles.Only_Spots_Image, 'XTick', []);
set(handles.Only_Spots_Image, 'YTick', []);

% Use "bwconncomp" to find all the spots in the image
spots = bwconncomp(only_spots_data);

% Use "regionprops" to get area of each spot. Save this in an array for
% easier processing
spots_data = regionprops(spots, 'Area');
spots_areas = [spots_data.Area];

% CALCULATING DATA

% Calculate the area per pixel based on the standard
area_per_pixel = area_standard_cm2 / area_standard_pixels;

% Convert the total leaf area and the area of each spot to cm^2 based on
% the area per pixel
total_area_leaf = area_leaf_pixels * area_per_pixel;
spots_areas_cm2 = spots_areas .* area_per_pixel;

% Calculate the total area infected by summing the areas of each spot
total_area_infected = sum(spots_areas_cm2);

% Calculate the percent infected
percent_infected = (total_area_infected / total_area_leaf) * 100;

% Calculate the average, standard deviation, and standard error of the
% areas of each spot
average_area_spots = mean(spots_areas_cm2);
std_spots = std(spots_areas_cm2);
se_spots = std_spots / sqrt(spots.NumObjects);

% DISPLAYING DATA TO GUI

% Initialize the arrays with handles of all static text boxes, the initials
% of the static text, the data to be displayed, and the handles for saved
% data
static_text_handles = {handles.area_standard_text, handles.total_area_leaf_text, ...
    handles.total_area_infected_text, handles.percent_infected_text, handles.number_spots_text,...
    handles.average_area_spots_text, handles.standard_deviation_text, handles.standard_error_text};
static_text_initials = {'Area of Standard (cm^2) = ', 'Total Area of Leaf (cm^2) = ',...
    'Total Area Infected (cm^2) = ', 'Percent Infected = ', 'Number of Spots = ',...
    'Average Area of Spots (cm^2) = ', 'Standard Deviation of Areas (cm^2) = ',...
    'Standard Error of Areas (cm^2) = '};
data_displayed = [area_standard_cm2, total_area_leaf, total_area_infected,...
    percent_infected, spots.NumObjects, average_area_spots, std_spots, se_spots];

% Loop through the data displayed array
for ii = 1:length(data_displayed)
    % Update the static text to reflect thes values
    set(static_text_handles{ii}, 'String', [static_text_initials{ii},...
        num2str(data_displayed(ii))]);
end

% Display a message box so the user knows the proper tracing
msgbox('If the program ran correctly, the standard should be traced in magenta, and the leaf should be traced in green');

% SAVING DATA

% Save the data to the corresponding handle, and save it to the GUI
handles.total_area_leaf = total_area_leaf;
handles.total_area_infected = total_area_infected;
handles.percent_infected = percent_infected;
handles.number_spots = spots.NumObjects;
handles.average_area_spots = average_area_spots;
handles.std_spots = std_spots;
handles.se_spots = se_spots;
handles.spots_areas_cm2 = spots_areas_cm2;
handles.leaf_index = leaf_index;
handles.standard_index = standard_index;
guidata(hObject, handles)


% --- Executes on button press in histogram_button.
function histogram_button_Callback(hObject, eventdata, handles)
% hObject    handle to histogram_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check to make sure the user analyzed an image
if ~isfield(handles, 'spots_areas_cm2')
    % If not, display an error message, and stop the callback function
    msgbox('Please analyze an image first');
    return
end

% Create a histogram based on the average areas of all the spots
histogram(handles.Histogram_Image, handles.spots_areas_cm2);


% --- Executes on button press in switch_button.
function switch_button_Callback(hObject, eventdata, handles)
% hObject    handle to switch_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check to make sure the user analyzed an image
if ~isfield(handles, 'leaf_index')
    % If not, display an error message, and stop the callback function
    msgbox('Please analyze an image first');
    return
end

% Switch the leaf index and standard index
temp_index = handles.leaf_index;
handles.leaf_index = handles.standard_index;
handles.standard_index = temp_index;

% RECALCULATING AREAS BASED ON THE SWITCH

% % Use "bwconncomp" function to find connected components in image, which
% should be just the full leaf and the standard
leaf_standard = bwconncomp(handles.full_leaf_standard_data);

% Use "regionprops" to get the area of the two objects
leaf_standard_stats = regionprops(leaf_standard, 'Area');
areas = [leaf_standard_stats.Area];

% Use function "bwboundaries" to find the boundaries of all objects
[boundaries, label] = bwboundaries(handles.full_leaf_standard_data, 'noholes');

% Change the label matrix, so the leaf is marked as a "1", and everything
% else is marked as a "0"
label(label ~= handles.leaf_index) = 0;
label(label == handles.leaf_index) = 1;

% Find the area of the leaf and the area of the standard
area_leaf_pixels = areas(handles.leaf_index);
area_standard_pixels = areas(handles.standard_index);

% Plot the boundary of the standard in magenta, and the boundary of the
% leaf in green
imshow(handles.full_leaf_standard_data, 'Parent', handles.Full_Leaf_Standard_Image);
hold(handles.Full_Leaf_Standard_Image, 'on');
border_leaf = boundaries{handles.leaf_index};
border_standard = boundaries{handles.standard_index};
plot(handles.Full_Leaf_Standard_Image, border_leaf(:,2), border_leaf(:,1), 'g', 'Linewidth', 2);
plot(handles.Full_Leaf_Standard_Image, border_standard(:,2), border_standard(:,1), 'm', 'Linewidth', 2);
hold(handles.Full_Leaf_Standard_Image, 'off');

% Clear the border of the binarized image. This will leave only the spots
% in the image as white
only_spots_data = imclearborder(handles.binary_image_data);

% Use the label matrix to only analyze the spots on the leaf
only_spots_data = only_spots_data & label;

% Load this image onto the axes, and get rid of tick marks
imshow(only_spots_data, 'Parent', handles.Only_Spots_Image);
set(handles.Only_Spots_Image, 'XTick', []);
set(handles.Only_Spots_Image, 'YTick', []);

% Use the label matrix to only get the spots in the area of the leaf
only_spots_data = only_spots_data & label;

% Use "bwconncomp" to find all the spots in the image
spots = bwconncomp(only_spots_data);

% Use "regionprops" to get area of each spot. Save this in an array for
% easier processing
spots_data = regionprops(spots, 'Area');
spots_areas = [spots_data.Area];

% Read the area of the standard in cm^2 from the static text
area_standard_cm2 = get(handles.area_standard_text, 'String');
% Loop through the static text string backwards
for ii = length(area_standard_cm2):-1:1
    % Look for the = sign
    if area_standard_cm2(ii) == '='
        % If so, take the value two spaces from the equal sign to the end
        area_standard_cm2 = area_standard_cm2(ii+2:length(area_standard_cm2));
        break
    end
end
% Convert from a string to a numerical value
area_standard_cm2 = str2num(area_standard_cm2);

% Calculate the area per pixel based on the standard
area_per_pixel = area_standard_cm2 / area_standard_pixels;

% Convert the total leaf area and the area of each spot to cm^2 based on
% the area per pixel
total_area_leaf = area_leaf_pixels * area_per_pixel;
spots_areas_cm2 = spots_areas .* area_per_pixel;

% Calculate the total area infected by summing the areas of each spot
total_area_infected = sum(spots_areas_cm2);

% Calculate the percent infected
percent_infected = (total_area_infected / total_area_leaf) * 100;

% Calculate the average, standard deviation, and standard error of the
% areas of each spot
average_area_spots = mean(spots_areas_cm2);
std_spots = std(spots_areas_cm2);
se_spots = std_spots / sqrt(spots.NumObjects);

% DISPLAYING DATA TO GUI

% Initialize the arrays with handles of all static text boxes, the initials
% of the static text, the data to be displayed, and the handles for saved
% data
static_text_handles = {handles.area_standard_text, handles.total_area_leaf_text, ...
    handles.total_area_infected_text, handles.percent_infected_text, handles.number_spots_text,...
    handles.average_area_spots_text, handles.standard_deviation_text, handles.standard_error_text};
static_text_initials = {'Area of Standard (cm^2) = ', 'Total Area of Leaf (cm^2) = ',...
    'Total Area Infected (cm^2) = ', 'Percent Infected = ', 'Number of Spots = ',...
    'Average Area of Spots (cm^2) = ', 'Standard Deviation of Areas (cm^2) = ',...
    'Standard Error of Areas (cm^2) = '};
data_displayed = [area_standard_cm2, total_area_leaf, total_area_infected,...
    percent_infected, spots.NumObjects, average_area_spots, std_spots, se_spots];

% Loop through the data displayed array
for ii = 1:length(data_displayed)
    % Update the static text to reflect thes values
    set(static_text_handles{ii}, 'String', [static_text_initials{ii},...
        num2str(data_displayed(ii))]);
end

% Display a message box so the user knows the proper tracing
msgbox('If the switch ran correctly, the standard should be traced in magenta, and the leaf should be traced in green');

% SAVING DATA

% Save the data to the corresponding handle, and save it to the GUI
handles.total_area_leaf = total_area_leaf;
handles.total_area_infected = total_area_infected;
handles.percent_infected = percent_infected;
handles.number_spots = spots.NumObjects;
handles.average_area_spots = average_area_spots;
handles.std_spots = std_spots;
handles.se_spots = se_spots;
handles.spots_areas_cm2 = spots_areas_cm2;
guidata(hObject, handles)