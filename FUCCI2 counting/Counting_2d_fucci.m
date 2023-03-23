close all ; clear all
tStart_glob = tic;
%%                          Initialization latex font
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
set(groot,'defaultTextInterpreter','latex');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Selection of th
answer = MFquestdlg_center([],'Please now select the folder with images for processing',...
    'Loading data','Select folder','Cancel','Select folder');
switch answer
    case 'Select folder'
        [~,path_images] = get_old_folder_position();
    case 'Cancel'
        return
end

answer = MFquestdlg_center([],'Please now select the method wanted','treshold method',...
    'Default','Adaptative','Default');
switch answer
    case 'Default'
        tresh_method = 'default';
    case 'Adaptative'
        tresh_method = 'adapt';
end


%% Windows version
% idx = strfind(path_images,'\');
% sample_name = path_images(idx(end-1)+1:idx(end)-1); clear idx 

%% GNU/Linux version
if isgnu()
else
    path_images(path_images=='\')='/';
end
path_images(end+1)='/';
idx = strfind(path_images,'/'); 
% idx_end = strfind(path_images,'\');
sample_name = path_images(idx(end-1)+1:idx(end)-1); clear idx 
% sample_name = path_images(idx(end)+1:idx_end-1); clear idx % GNU/Linux


tmp_data = strcat(path_images,'tmp 8 bits-',sample_name,'-',tresh_method,'.mat');

if exist(tmp_data,'file')== 0
    SrcFiles_all = dir(strcat(path_images,'*.tif'));
    names = {SrcFiles_all(~[SrcFiles_all.isdir]).name}';
       
    idx_match_mcherry = contains(names,'mCherry');
    idx_match_YFP = contains(names,'YFP');
    idx_match_phase = contains(names,'Phase');
    data_green = counting_create_folder_filter_images('YPF-green',path_images) ;
    data_red = counting_create_folder_filter_images('mCherry-red',path_images);
    data_phase = couting_create_folder_filter_images('phase_10x',path_images);
    
    I_r_all = cell(length(idx_match_mcherry),1);
    I_g_all = cell(length(idx_match_YFP),1);
    I_phase_all = cell(length(idx_match_phase),1);
    
    tStart = tic ;
    fprintf('Start moving files and loading images... \n')
    parfor k = 1 : length(SrcFiles_all)
        imfilename = fullfile(path_images,SrcFiles_all(k).name);
        if idx_match_mcherry(k)
            I = double(imread(imfilename))./2^16;
            I_8bits = uint8(I.*255);
            I_r_all{k} = I_8bits;
            movefile(imfilename,data_red);
        elseif idx_match_YFP(k)
            I = double(imread(imfilename))./2^16;
            I_8bits = uint8(I.*255);
            I_g_all{k} = I_8bits;
            movefile(imfilename,data_green);
        elseif idx_match_phase(k)
            I = double(imread(imfilename))./2^16;
            I_8bits = uint8(I.*255);
            I_phase_all{k} = I_8bits;
            movefile(imfilename,data_phase);
            
        end
    end
    removing_done = true;
    tElapsed = toc(tStart);
    fprintf('Removing and Loading done. Time elapsed: ');cprintf('_red','%0.3f s\n',tElapsed); % Display function the time to exectute the loop
    
    I_r_all(cellfun('isempty', I_r_all)) = [];
    I_g_all(cellfun('isempty',I_g_all)) = [];
    I_phase_all(cellfun('isempty',I_phase_all)) = [];
    
    %%%% END OF LOADING THE DATA
    tStart = tic ;
    fprintf('Start saving images in tmp... \n')
    save(tmp_data,'I_r_all','I_g_all','I_phase_all','path_images','sample_name','tresh_method','removing_done','-v7.3');
    tElapsed = toc(tStart);
    fprintf('Saving images in tmp done. Time elapsed: ');cprintf('_red','%0.3f s\n',tElapsed); % Display function the time to exectute the loop
    
else
    load(tmp_data,'I_g_all','I_phase_all','I_r_all','removing_done');
end
%% Beginning the processing here
%% Get the treshold for all images
tStart = tic;
fprintf('Start thresholding the images...\n');
[BW_r_all,BW_g_all,BW_phase_all] = counting_treshold_images(path_images,sample_name,I_r_all,I_g_all,I_phase_all,tresh_method);
tElapsed = toc(tStart);
fprintf('Tresholding done. Time elapsed: ');cprintf('_red','%0.3f s\n',tElapsed);

storage = strcat(path_images,'processed_data_',tresh_method,'\');
N = length(I_r_all); % N is the number of frames not black

%% Creation of the folder for the filtered images
filter_data_green = counting_create_folder_filter_images('green',storage) ;
filter_data_red = counting_create_folder_filter_images('red',storage);
filter_data_merge = counting_create_folder_filter_images('merge',storage);
filter_data_phase = counting_create_folder_filter_images('phase_10x',storage);

red_filter_all = cell(N,1);
green_filter_all = cell(N,1);

tStart = tic;
fprintf('Start filtering/cleaning and counting FL cells... \n');
for k = 1 : N
    digit = get_digit(k);
    name = strcat(sample_name,'-',digit);
    %% Processing the images to find the centroids and intensity
    [red_filter,S_r,S_r_m] = counting_find_color_cell_new(I_r_all{k},BW_r_all{k},'red','bin');
    [green_filter,S_g,S_g_m] = counting_find_color_cell_new(I_g_all{k},BW_g_all{k},'green','bin');
    %% TMP SOLUTION FOR PHASE CONTRAST
%     CC= bwconncomp(BW_phase_all{k}); % Black and white connective component
%     S = regionprops(CC,'Area','PixelIdxList','PixelList','centroid','EquivDiameter','Image','BoundingBox');
%     [S,CC] = filter_by_size(S,CC,1,40);
%     BW1 = ismember(labelmatrix(CC), 1:CC.NumObjects);
%     phase_filter = uint8(repmat(BW1,[1 1 3]).*255);
%     merge_total = imadd(repmat(I_phase_all{k},[1 1 3]),phase_filter);
    %% Merge the phase with green and red fucci
    merge_total = imadd(repmat(I_phase_all{k},[1 1 3]),red_filter);
    merge_total_all{k} = imadd(merge_total,green_filter);
   
    %% Saving the results
    red_filter_all{k} = red_filter;
    green_filter_all{k} = green_filter;
    nb_yellow(k,1) = counting_extract_yellow_cells(S_g,S_r);
    nb_red(k,1) = length(S_r) - nb_yellow(k,1);
    nb_green(k,1) = length(S_g) - nb_yellow(k,1);
    nb_red_area(k,1) = sum([S_r.Area]);
    nb_green_area(k,1) = sum([S_g.Area]);
    just_text = imabsdiff(red_filter,green_filter);
    %% Check  the system computer toolbow for merge_filter = I + just_text;
    merge_filter = imadd(red_filter,green_filter); %% TEMPORARY SOLUTION
    %% data_storage
    S_r_all{k} = S_r;
    S_r_m_all{k} = S_r_m;
    S_g_all{k} = S_g;
    S_g_m_all{k} = S_g_m;
    %% Writing process
    %     imwrite(red_filter,strcat(filter_data_red,name,'.tif'));
    %     imwrite(green_filter,strcat(filter_data_green,name,'.tif'));
    output_img = strcat(filter_data_merge,name,'.tif');
    if ~exist(output_img,'file')
        imwrite(merge_total_all{k},output_img);
    else
        continue
    end
end
% nb_yellow = nb_yellow';
tElapsed = toc(tStart);
fprintf('Filtering/counting done. Time elapsed: ');cprintf('_red','%0.3f s\n',tElapsed);
clear BW_r_all BW_g_all I_r_all  I_g_all I_phase_all 
fprintf('Start saving job... \n');
% save(strcat(storage,'\job-',sample_name,'.mat'),'-v7.3');
%% TMP FOR THE CORRECTION WITH YELLOW GREEN AND RED COUNTING 
save(strcat(storage,'\job-',sample_name,'.mat'),'nb_green','nb_red','nb_yellow','-append');
fprintf('Job successfully saved ');
% make_video_SO(filter_data_red,sample_name,2);
% make_video_SO(filter_data_green,sample_name,2);

counting_generate_graph(storage,sample_name,N,nb_red,nb_green,nb_yellow);
counting_make_video_SO(filter_data_merge,merge_total_all,sample_name,2);

tElapsed_glob = toc(tStart_glob);
fprintf('Total program done. Time elapsed: ');cprintf('_red','%0.3f s\n',tElapsed_glob);
% create_movie_overlay(I_r_all,I_g_all,filter_data_merge,sample_name,2);
% create_movie_overlay_phase(I_r_all,I_g_all,data_phase,sample_name,fps)


