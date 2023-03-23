% function confinment_create_excel_out()
close all ; clear all
%% DO CHECK NEXT TIME 
%     xlswrite(out_excel,B,sheet_name{1,idx_live}(26:end));
% NAME OF EXCEL SHEET CANNOT BE BIGGER THAN 31 !!!!!, SO CHANGE THE RANGE
% !! 
%%%%%%%%%
%%                          Initialization latex font
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
set(groot,'defaultTextInterpreter','latex');
addpath('M:\BM\Hubert Taieb (M)\02 PhD\07 Matlab code\04 Custom general functions\');
addpath('M:\BM\Hubert Taieb (M)\02 PhD\07 Matlab code\04 Custom general functions\bfmatlab\');
% addpath('M:\BM\Hubert Taieb (M)\02 PhD\07 Matlab code\04 Custom general functions\bfmatlab\private\');
addpath('M:\BM\Hubert Taieb (M)\02 PhD\07 Matlab code\04 Custom general functions\Hubert functions\');
%% LOAD DATA
load('colormaps.mat');
answer = MFquestdlg_center([],'Please now select the folder with images for processing',...
    'Loading data','Select folder','Cancel','Select folder');
switch answer
    case 'Select folder'
        [~,path_data] = get_old_folder_position();
        SrcFiles = dir(strcat(path_data,'\**/*'));
        path_data = strcat(path_data,'\');
        %         czifilename = fullfile(path_data,cziname);
    case 'Cancel'
        error('The user stop the folder selection');
end
idx_sep = find(path_data == '\');
sample_name = path_data(idx_sep(end-1) + 1 : idx_sep(end) - 1);

out_excel = char(strcat(path_data,'Output',{' '},sample_name,'.xlsx'));

names = {SrcFiles(~[SrcFiles.isdir]).name}';
folder = {SrcFiles(~[SrcFiles.isdir]).folder}';
ismat = contains(names,'.mat');
names(~ismat) = [];
folder(~ismat) = [];
N_f = size(names,1);

col_avg_g=2;
col_avg_r=4;
col_std_g=3;
col_std_r=5;
col_time=1;


shift_cell = 0; % =  number of timepoint + 3, to calculte each iterations
shift_LD = 7;
idx_to_do =[];
for ff = 1 : N_f
    row_head = 7;
    matfilename = fullfile(folder{ff,1}, names{ff,1});
%     idx_scene = strfind(folder{ff,1},'Scene');
%     scene_nb_str = folder{ff,1}(idx_scene(1):end);
%     to_cut = strsplit(scene_nb_str);
%     scene_nb = to_cut{2};
    
    idx_tmp = strfind(names{ff,1},'_tmp_data') - 1;
    scene_nb_str = names{ff,1}(1:idx_tmp(1));
    sheet_name{1,ff} = scene_nb_str;
    load(matfilename,'Cells_all');
    try
    N_c = size(Cells_all{1,1},2);
    N_t = size(Cells_all,1);
    shift_cell = N_t + 5;
    B{1,1} = 'Data from';
    B{1,2} = strcat(sample_name," ",scene_nb_str);
    B{3,2} = 'Live cell' ;
    B{3,9} = 'Dead cell';
    if contains(matfilename,'Live')
        idx_to_do = [idx_to_do, ff];
        clear B; clear Cells_all;
        continue;
    elseif contains(matfilename,'Dead')
        col_avg_g=2 + shift_LD;
        col_avg_r=4+ shift_LD;
        col_std_g=3+ shift_LD;
        col_std_r=5+ shift_LD;
        col_time=1+ shift_LD;
    end
    for cc = 1 : N_c
        B{row_head-2, col_time} = strcat('Cell N° ',num2str(cc));
        B{row_head,col_avg_g} = 'mVenus';
        B{row_head,col_avg_r} = 'mCherry';
        B{row_head + 1,col_avg_g} = 'Mean';
        B{row_head + 1,col_std_g} = 'Std';
        B{row_head + 1,col_avg_r} = 'Mean';
        B{row_head + 1,col_std_r} = 'Std';
        B{row_head + 1 , col_time} = 'Time (hours)';
        times = NaN(N_t,1);
        mean_g = NaN(N_t,1);
        std_g = NaN(N_t,1);
        
        mean_r = NaN(N_t,1);
        std_r = NaN(N_t,1);
        for tt = 1 : N_t
            cell_l = Cells_all{tt,1}(1,cc);
            times(tt,1) = cell_l.t_sec/(60*60);
            mean_g(tt,1) = mean(double(cell_l.intensity.mvenus));
            std_g(tt,1) = std(double(cell_l.intensity.mvenus));
            mean_r(tt,1) = mean(double(cell_l.intensity.mcherry));
            std_r(tt,1) = std(double(cell_l.intensity.mcherry));
            B{row_head + 1 + tt,col_time} =  times(tt,1);
            B{row_head + 1+tt,col_avg_g} = mean_g(tt,1);
            B{row_head + 1+tt,col_std_g} = std_g(tt,1);
            B{row_head + 1+tt,col_avg_r} = mean_r(tt,1);
            B{row_head + 1+tt,col_std_r} = std_r(tt,1);
        end
        row_head = row_head + shift_cell;
    end
    xlswrite(out_excel,B,sheet_name{1,ff});
    %     xls_delete_sheets(out_excel,'Sheet1');
    catch
        fprintf('The file %s has a problem with dead \n',matfilename);
    end
    clear Cells_all;
    clear B;
end

N_live = numel(idx_to_do);

col_avg_g=2;
col_avg_r=4;
col_std_g=3;
col_std_r=5;
col_time=1;
for ff = 1 : N_live
    idx_live = idx_to_do(1,ff);
    row_head = 7;
    matfilename = fullfile(folder{idx_live,1}, names{idx_live,1});
%     idx_scene = strfind(folder{idx_live,1},'Scene');
%     scene_nb_str = folder{idx_live,1}(idx_scene(1):end);
%     to_cut = strsplit(scene_nb_str);
%     scene_nb = to_cut{2};
    
    
    idx_tmp = strfind(names{idx_live,1},'_tmp_data') - 1;
    scene_nb_str = names{idx_live,1}(1:idx_tmp(1));
    sheet_name{1,idx_live} = scene_nb_str;
    load(matfilename,'Cells_all');
    try
    N_c = size(Cells_all{1,1},2);
    N_t = size(Cells_all,1);
    shift_cell = N_t + 5;
    B{1,1} = 'Data from';
    B{1,2} = strcat(sample_name," ",scene_nb_str);
    B{3,2} = 'Live cell' ;
%     B{3,9} = 'Dead cell';
    if contains(matfilename,'Live')
        for cc = 1 : N_c
            B{row_head-2, col_time} = strcat('Cell N° ',num2str(cc));
            B{row_head,col_avg_g} = 'mVenus';
            B{row_head,col_avg_r} = 'mCherry';
            B{row_head + 1,col_avg_g} = 'Mean';
            B{row_head + 1,col_std_g} = 'Std';
            B{row_head + 1,col_avg_r} = 'Mean';
            B{row_head + 1,col_std_r} = 'Std';
            B{row_head + 1 , col_time} = 'Time (hours)';
            times = NaN(N_t,1);
            mean_g = NaN(N_t,1);
            std_g = NaN(N_t,1);
            
            mean_r = NaN(N_t,1);
            std_r = NaN(N_t,1);
            for tt = 1 : N_t
                cell_l = Cells_all{tt,1}(1,cc);
                times(tt,1) = cell_l.t_sec/(60*60);
                mean_g(tt,1) = mean(double(cell_l.intensity.mvenus));
                std_g(tt,1) = std(double(cell_l.intensity.mvenus));
                mean_r(tt,1) = mean(double(cell_l.intensity.mcherry));
                std_r(tt,1) = std(double(cell_l.intensity.mcherry));
                B{row_head + 1 + tt,col_time} =  times(tt,1);
                B{row_head + 1+tt,col_avg_g} = mean_g(tt,1);
                B{row_head + 1+tt,col_std_g} = std_g(tt,1);
                B{row_head + 1+tt,col_avg_r} = mean_r(tt,1);
                B{row_head + 1+tt,col_std_r} = std_r(tt,1);
            end
            row_head = row_head + shift_cell;
        end
        try
        xlswrite(out_excel,B,sheet_name{1,idx_live}(26:end));
        catch
            fprintf('The file %s has a problem with live and excel \n',matfilename);
        end
    end
    catch
         fprintf('The file %s has a problem with live \n',matfilename);
    end
        clear B; clear Cells_all;
  
end
xls_delete_sheets(out_excel,'Sheet1');

