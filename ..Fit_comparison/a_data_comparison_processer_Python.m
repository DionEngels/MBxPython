clear all
%% setup

load data_generation_info_v4

positions = saved.positions;

mic_pixelsize = saved.pixelsize;
number_y = 10;

n_frames = 1000;
%% load in data
load v4/Localizations_Dion_v2

%% fit checker setup
x_column = 4; %what column has x-pos in the return data
y_column = 3; %what column has y-pos in the return data

sigma_check = 1;
if sigma_check == 1
    sigma_x_column = 6;
    sigma_y_column = 7;
end

%% fit checker %% clear test
clear res_precision res_accuracy

data = Localizations;
data(:,x_column) = (data(:, x_column))*mic_pixelsize; % convert to nm, compensate for pixel offset MATLAB
data(:,y_column) = (data(:, y_column))*mic_pixelsize; % convert to nm, compensate for pixel offset MATLAB
data = data(data(:,x_column)>0,:);

total_fits = 0;

for i=1:size(positions,1)
    
    pos_x = positions(i,1);
    pos_y = positions(i,2);
    row = floor((i-1)/10)+1;
    y_val = mod(i,number_y);
    if y_val == 0
        y_val = y_val + number_y;
    end
    column = y_val;
    
    temp = data((data(:,x_column) > pos_x-10*mic_pixelsize) & (data(:,x_column) < pos_x+10*mic_pixelsize) & (data(:,y_column) > pos_y-10*mic_pixelsize) & (data(:,y_column) < pos_y+10*mic_pixelsize),:);
    
    fit_x = temp(:,x_column);
    fit_y = temp(:,y_column);
    
    if sigma_check == 1
        sigma_x = temp(:,sigma_x_column)*mic_pixelsize; % convert to nm
        sigma_y = temp(:,sigma_y_column)*mic_pixelsize; % convert to nm
        
        sigma_x_mean = mean(sigma_x);
        sigma_y_mean = mean(sigma_y);
        
        sigma_x_std = sum((sigma_x - sigma_x_mean).^2)/(size(sigma_x,1)-1);
        sigma_y_std = sum((sigma_y - sigma_y_mean).^2)/(size(sigma_y,1)-1);
        
        sigma_mean = mean([sigma_x_mean sigma_y_mean]);
        res_sigma_precision(row,column) = sqrt(sigma_x_std^2 + sigma_y_std^2);
        res_sigma_accuracy(row,column) = sigma_mean - mic_pixelsize;
    end
    
    
    
    
    fit_x_mean = mean(fit_x);
    fit_y_mean = mean(fit_y);
    
    fit_x_std = sum((fit_x - fit_x_mean).^2)/(size(fit_x,1)-1);
    fit_y_std = sum((fit_y - fit_y_mean).^2)/(size(fit_y,1)-1);
    res_precision(row,column) = sqrt(fit_x_std^2 + fit_y_std^2);
    res_accuracy(row,column) = norm([pos_x pos_y] - [fit_x_mean fit_y_mean]);
    
    %     figure
    %     scatter(fit_x, fit_y)
    %     hold on
    %     scatter(pos_x(i),  pos_y(j), 'x','r', 'LineWidth',5)
    %     total_fits = total_fits + size(fit_x,1);
    
end

res_mean_precision = nanmean(res_precision,2);
res_mean_accuracy = nanmean(res_accuracy,2);
if sigma_check == 1
    res_mean_sigma_precision = nanmean(res_sigma_precision,2);
    res_mean_sigma_accuracy = nanmean(res_sigma_accuracy,2);
end
%% clear test
%clear res_precision res_accuracy res_mean