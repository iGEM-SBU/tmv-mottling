## Stony Brook iGEM 2019

## Requirements
MATLAB R2018a or later
MATLAB Image Processing Toolbox

## Downloaded Files
Plant_Mottling_Analysis.fig: This is the figure file for the GUI\
Plant_Mottling_Analysis.m: This is the code for the GUI (to be used with the figure file above). BOTH of these are neceesary to run.\
tmv_mottling.m: This is a function that performs the same algorithm as the GUI\
tmv_mottling_bulk.m: This is a script for performing this algorithm on a folder of images. This REQUIRES the function tmv_mottling.m to run.

## How to use
For individual photos, the files Plant_Mottling_Analysis.fig and Plant_Mottling_Analysis.m can be used. When you run the program, a figure box will be displayed. First, upload an image by pressing the "upload image" button. Then, the image is binarized and analzyed by hitting the corresponding buttons. The calcualtions will then be displayed to the user.

For multiple photos, the files tmv_mottling.m and tmv_mottling_bulk.m can be used. When you run the bulk script, select a folder of images, and input the area of the standard in the photo if there is one. The program will then automatically run and output the calculations. Alternatively, the function tmv_mottling can be used in other programs. Parameters to input in the function are commented in the code.
