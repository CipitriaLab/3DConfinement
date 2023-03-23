close all ; clear all

%%                          Initialization latex font
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
set(groot,'defaultTextInterpreter','latex');

%% LOAD DATA
load('colormaps.mat');
answer = MFquestdlg_center([],'Please now select the folder with images for processing',...
    'Loading data','Select folder','Cancel','Select folder');
switch answer
    case 'Select folder'
        [cziname,path_data] = get_old_folder_position('mat');
        czifilename = fullfile(path_data,cziname);
    case 'Cancel'
        error('The user stop the folder selection');
end
if isgnu()
    copyfile(fullfile(path_data,cziname),fullfile('/scratch/THVB-LBOX183_GNU/01 Matlab tmp',cziname));
    load(fullfile('/scratch/THVB-LBOX183_GNU/01 Matlab tmp',cziname),'Cells_all','voxelsizeX');
else
    load(fullfile(path_data,cziname),'Cells_all','voxelsizeX');
end
% voxelsize is um/px

N = size(Cells_all{1,1},2);
N_t = size(Cells_all,1);
which_cell = 10;
%% The goal of this function is to recreate a 1 x timepoint with only the cells that we are interested in
single_cell_by_time =[];
for tt = 1 : N_t
    if tt == 1
        cell_without_parent = rmfield(Cells_all{tt, 1}(1,which_cell), 'parent');
        % Only the first has the "parent", so need to be remove to
        % concatenate
        single_cell_by_time = [single_cell_by_time,cell_without_parent];
    else
        single_cell_by_time = [single_cell_by_time,Cells_all{tt,1}(1,which_cell)];
    end
    
end

%% Display of single cell over time
fig1 = figure('color','white');
ax1 = axes('parent',fig1);

for tt = 1 : 2: N_t
    %% Display overlay
    %     I_r = uint8(zeros([size(single_cell_by_time(tt).imgs.mcherry),3]));
    %     I_r(:,:,1) = imadjust(single_cell_by_time(tt).imgs.mcherry,stretchlim(single_cell_by_time(tt).imgs.mcherry),[]);
    %     I_phase = repmat(single_cell_by_time(tt).imgs.phase,[1 1 3]);
    %     I_sup = imadd(I_phase,I_r);
    %     I_over = imoverlay(I_sup,single_cell_by_time(tt).BWs.mcherry);
    %       imshow(I_over,'parent',ax1);
    %     imshow(I_sup,'parent',ax1);
    %     imshow(imoverlay(single_cell_by_time(tt).imgs.phase,single_cell_by_time(tt).BWs.mcherry),'parent',ax1)
    
        %%%%%%%%%%%%%%%%%%%%%%%

    
    %% Load images 
    I_r  = single_cell_by_time(tt).imgs.mcherry;
    I_g  = single_cell_by_time(tt).imgs.mvenus;
    BW_r = single_cell_by_time(tt).BWs.mcherry;
    BW_g = single_cell_by_time(tt).BWs.mvenus;
    
    %% Get data and errorbar for intensity
    [y_g(tt,1),y_g_std(tt,1)] = confinment_get_intensity(I_g,BW_g);
    [y_r(tt,1),y_r_std(tt,1)] = confinment_get_intensity(I_r,BW_r);
    x_r(tt,1) = single_cell_by_time(tt).t_sec/3600; % in hours
    x_g(tt,1) = single_cell_by_time(tt).t_sec/3600; % in hours, x_g and x_r are the same
     %% Superpose images , scale bar and colorbar
    if tt == 1
        %% Position and length of the patch for the scalebar
        dim = size(I_r);
        display_um = 10;
        length_pix_scale_bar = round(voxelsizeX*display_um);
        x_beg = 0.6;
        y_beg = 0.9;
        height_box = 1 ;
        width_box = length_pix_scale_bar;
        position_box = [x_beg*dim(2), y_beg*dim(1),width_box,height_box];
        %% Calculate the vertices of the patch for the scale bar
        x_scale = [position_box(1);position_box(1);position_box(1)+position_box(3);position_box(1)+position_box(3)];
        y_scale = [position_box(2);position_box(2)+position_box(4);position_box(2)+position_box(4);position_box(2)];
    end
    %% For the dead it is I_g and live it is I_r
    if contains(cziname,'Live')
        live_or_dead = 'Live';
        imshow(I_r.*2,'parent',ax1);
    else
        live_or_dead = 'Dead';
    imshow(I_g.*2,'parent',ax1);
    end
   
    %% Displaty images , need to ask Amaia how she likes it
    c = colorbar('peer',ax1,'north','Color',[1 1 1]);
    if contains(cziname,'Live')
        
    ax1.Colormap = red_colormap;
    else 
        ax1.Colormap = green_colormap;
    end
    % c.Limits = [15 133]; % Based on the last image
    % ax1.CLimMode = 'auto';
    ax1.Visible = 'off';
    patch(x_scale',y_scale','white','EdgeColor','none');
    saveas(fig1,strcat(path_data,'single_cell_#_',num2str(which_cell),'_',live_or_dead,'_T=',num2str(round(x_r(tt,1),1)),'_hours','.svg'))
end

%% my own display method
% error_sup_r = y_r + y_r_std;
% error_inf_r = y_r - y_r_std;
%
% error_sup_g = y_g + y_g_std;
% error_inf_g = y_g - y_g_std;
%
% fig2=figure('color','white');
% ax2 = axes('parent',fig2);
% hold(ax2,'on'); % this is hold on basically
% plot(ax2,x_r,y_r,'.-','color','red');
% a = jbfill(x_r',error_sup_r',error_inf_r',[1 0 0],[1 1 1]);
% ax2.NextPlot = 'add';
% ax2.Layer = 'top';
% plot(ax2,x_g,y_g,'.-','Color','green')x²
% b = jbfill(x_g',error_sup_g',error_inf_g',[0 1 0],[1 1 1]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [intens_mean,intens_std] = confinment_get_intensity(I,BW)
I = double(I);
I_intens = I;
I_intens(~BW) = NaN;
I_intens = reshape(I_intens,[numel(I_intens),1]);
intens_mean = mean(I_intens,'omitnan');
intens_std= std(I_intens,'omitnan');
end





