% Nic Hendley
clear, clc, close all

% Load image and convert to grayscale
Im = imread('testImage.jpg');
Ig = rgb2gray(Im);
E = Im;
figure;

%% Find centers of circles in image
[centers, radii] = imfindcircles(Ig, [10 50], ObjectPolarity="dark",Sensitivity=0.85);
marbles = strings(size(centers,1),1);

%% Calculating Size of Marbles

% Limit processing to corner of image
E(round(size(E,1)*.25):end,:,:) = [];
E(:,round(size(E,2)*.25):end,:) = [];
E = rgb2hsv(E);

[rows, cols, z] = size(E);
for i = 1:rows-1
    for j = 1:cols-2
        if (E(i,j,1) >= 180) && (E(i,j,1) <= 225)
            E(i,j,3) = 0;
        end
    end
end

E = rgb2gray(hsv2rgb(E));

% E = localcontrast(E, 0.5, 0.25);
corners = detectHarrisFeatures(E,"MinQuality",.275);
scale = sqrt(((corners.Location(1,1)-corners.Location(2,1))^2 ...
    +((corners.Location(1,2)-corners.Location(2,1))^2)));

Dia = (radii/scale);
%% Determine the color of each marble
offset = mean(radii)/3;
c = zeros(size(centers,1),4,3);
color = zeros(size(centers,1),1,3);

% Find mean RGB value for each circle
for i = 1:size(centers,1)
    c(i,1,:) = Im(round(centers(i,2) - offset),round(centers(i,1)),:); % Down
    c(i,2,:) = Im(round(centers(i,2) + offset),round(centers(i,1)),:); % Up
    c(i,3,:) = Im(round(centers(i,2)),round(centers(i,1) + offset),:); % Right
    c(i,4,:) = Im(round(centers(i,2)),round(centers(i,1) - offset),:); % Left
    color(i,1,1) = mean(c(i,:,1));
    color(i,1,2) = mean(c(i,:,2));
    color(i,1,3) = mean(c(i,:,3));
end

% Convert RGB to HSV for easier color ID
hsv = rgb2hsv(color);
hsv(:,1,1) = hsv(:,1,1)*360;

% Classify each marble based on HSV range
for i = 1:size(color,1)
    if (hsv(i,1,1) >= 190) && (hsv(i,1,1) <= 225)
        marbles(i,1) = "Blue";
    elseif (hsv(i,1,1) >= 330) && (hsv(i,1,1) <= 360)
        marbles(i,1) = "Red";
    elseif (hsv(i,1,1) >= 15) && (hsv(i,1,1) <= 28)
        marbles(i,1) = "Orange";
    elseif (hsv(i,1,1) >= 29) && (hsv(i,1,1) <= 65)
        marbles(i,1) = "Yellow";
    end
end

%% Display Results
% Display circle outlines on original image
imshow(Im);
hold on
viscircles(centers, radii,'EdgeColor','r');

% print table of results
out = array2table(cat(2,marbles,Dia),'VariableNames',{'Color','Size [cm]'});
display(out);