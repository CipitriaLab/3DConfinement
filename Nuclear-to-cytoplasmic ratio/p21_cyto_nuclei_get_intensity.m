%% Function to get the open figure and to draw inside for the inside/outside.
clear all;
addpath('M:\BM\Hubert Taieb (M)\02 PhD\07 Matlab code\04 Custom general functions\Hubert functions\');
addpath('M:\BM\Hubert Taieb (M)\02 PhD\07 Matlab code\04 Custom general functions\');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
set(groot,'defaultTextInterpreter','latex'); %trying to set the default
%% PLEASE CHANGE IF THE CHANNEL ORDER CHANGES!!!!
nucl = 'ch00';
cyto = 'ch02';
phase = 'ch01';
p21 = 'ch03';

c_nucl = 1;
c_cyto = 3;
c_phase = 2;
c_p21 = 4;

%% To change 
closing_disk = 5;
thresh_p21 = 5;
voxelsize = 0.141; % um/pixelß
voxelsize_conv = voxelsize * voxelsize;
filter = 2.5; % radius un um of things to filter 


suffixe_ch = {nucl, cyto, phase,p21};
[~, root] = get_old_folder_position();
root = path2clean(root);
sample_name = get_parent_folder_string(root,1);
SrcFiles = dir(strcat(root,'*.tif'));
names = {SrcFiles(~[SrcFiles.isdir]).name}';
folder = {SrcFiles(~[SrcFiles.isdir]).folder}';

I_all = cell(1, size(names,1));
for cc = 1 : 4 % number of chanel, cc for channel
    filename = strcat(folder{cc},'\',names{cc});
    I_tmp  = imread(filename);
    [~, name_tmp, ~] = fileparts(filename);
    idx_match = find(contains(suffixe_ch, name_tmp(end-3:end)) == 1);
    %     if size(I_tmp,3) == 3
    %         I_tmp = rgb2gray(I_tmp);
    %     end
    I_all{1,idx_match} = I_tmp;
    
end
name_tmp = name_tmp(1:end-5);
% I = h_s.CData;
app_save.I_all = I_all;
% I = uint8(I./(max(max(I)))*255);
    fig = figure2('color','white','WindowState','maximized');
    ax = axes('parent',fig);
for cc = 1 : 2
    I = I_all{1,cc};
    h_nucl = imshow(I,'parent',ax);
    set(ax,'CLimMode','auto');
    I_gray = rgb2gray(I);
    thresh = graythresh(I_gray).*255;
    if cc == 2
        thresh = thresh -5;
    end
    BW = imbinarize(I_gray,thresh/255);
    thresh_all(cc) = thresh;
    BW = imclose(BW,strel('disk', closing_disk));
    BW = imfill(BW,'holes');
    [BW,S,CC] = create_CC_classic(BW,I_gray, filter, 'down', voxelsize_conv);
            patch_s = struct('XData',[],'YData',[],...
            'FaceColor','none',...
            'EdgeColor',[1 0 1],...
            'LineWidth',1.5,...
            'FaceAlpha', 0);
    if CC.NumObjects == 1

        [path_out,~,~] = bwboundaries(BW);
        if cc == 1
            patch_s.EdgeColor = [1 1 1];
            patch_s.FaceColor = [0 0 1];
        else
            patch_s.EdgeColor = [1 1 1];
            patch_s.FaceColor = [0 1 0];
        end
        path_out = cell2mat(path_out);
        patch_s.XData = path_out(:,2);
        patch_s.YData = path_out(:,1);
        patch(ax, patch_s);
        title(ax,'\textbf{Auto seg mentation worked}');
        is_auto_seg(cc) = true;
    else
        title(ax,'\textbf{Automatic seg failed}');
        is_auto_seg(cc) = false;
    end
    ax.FontSize = 18;
    ax.FontWeight = 'bold';
    
    if is_auto_seg(cc) == false
        title(ax,'\textbf{Please segment manually}');
        im_poly = impoly(ax); 
        BW = createMask(im_poly);
        delete(im_poly);
                [path_out,~,~] = bwboundaries(BW);
        if cc == 1
            patch_s.EdgeColor = [1 1 1];
            patch_s.FaceColor = [0 0 1];
        else
            patch_s.EdgeColor = [1 1 1];
            patch_s.FaceColor = [0 1 0];
        end
        path_out = cell2mat(path_out);
        patch_s.XData = path_out(:,2);
        patch_s.YData = path_out(:,1);
        patch(ax, patch_s);
        
    else
        answer = MFquestdlg_center([],'Happy with the segmentation?','Segmentation','Yes','Manual seg','Cancel','Cancel');
        switch answer
            case 'Yes'
            case 'Manual seg'
                path_already = findobj(ax.Children,'Type','Patch');
                delete(path_already);
                 title(ax,'\textbf{Please segment manually}');
                 im_poly = impoly(ax); 
                 BW = createMask(im_poly);
                 delete(im_poly);
                         [path_out,~,~] = bwboundaries(BW);
        if cc == 1
            patch_s.EdgeColor = [1 1 1];
            patch_s.FaceColor = [0 0 1];
        else
            patch_s.EdgeColor = [1 1 1];
            patch_s.FaceColor = [0 1 0];
        end
        path_out = cell2mat(path_out);
        patch_s.XData = path_out(:,2);
        patch_s.YData = path_out(:,1);
        patch(ax, patch_s);
            case 'Cancel'
                return
            otherwise
                error('Error selection');
        end
    end
    if cc == 1
         [BW,S,CC] = create_CC_classic(BW,rgb2gray(I_all{1,4}), filter, 'down', voxelsize_conv);
%          p21_mean = S.MeanIntensity;
         p21_mean = mean(S.PixelValues(S.PixelValues > thresh_p21));
         p21_std = std(double(S.PixelValues(S.PixelValues > thresh_p21)));
         app_save.S_nucl = S;
%         app_save.im_nucl.Position = im_poly.getPosition;
        app_save.BW_nucl = BW; 
        app_save.BW_nucl_patch = patch_s;
        app_save.p21_nucl_mean = p21_mean;
        app_save.p21_nucl_std = p21_std; 
        p21_mean = round(p21_mean,0);
        p21_std = round(p21_std,0);
        str_nucl = strcat('p21 mean intensity in nuclei is:'," ",num2str(p21_mean,3),'/255'," ",char(177)," ",num2str(p21_std,2)," ",'');
        disp(name_tmp);
        disp(str_nucl);
        cla(ax);
    else
        BW(app_save.BW_nucl) = 0;
         [BW,S,CC] = create_CC_classic(BW,rgb2gray(I_all{1,4}), filter, 'down', voxelsize_conv);
         app_save.S_cyto = S;
         if isempty(S)
             error('Redo the nucleus segmentation, nothing found in the cytoplasm');
         end
         p21_mean = mean(S.PixelValues(S.PixelValues > thresh_p21));
         p21_std = std(double(S.PixelValues(S.PixelValues > thresh_p21)));
       app_save.BW_cyto_patch = patch_s;
%         app_save.im_cyto.Position = im_poly.getPosition;
        app_save.BW_cyto = BW;
        app_save.p21_cyto_mean = p21_mean;
        app_save.p21_cyto_std = p21_std;
         p21_mean = round(p21_mean,0);
        p21_std = round(p21_std,0);
        str_cyto = strcat('p21 mean intensity in cytoplasm is:'," ",num2str(p21_mean,3),'/255', " ",char(177)," ",num2str(p21_std,2)," ",'');
        disp(str_cyto);
        delete(fig);
    end
end

fig = figure('color','white');
ax = axes('parent',fig);
h_p21 = imshow(I_all{1,4},'parent',ax,'InitialMagnification',100);
set(ax, 'CLimMode','auto');
ax.FontSize = 10;
title(ax,'\textbf{Overlay of the p21 channel with the segmentation}');
patch(ax,app_save.BW_nucl_patch);
patch(ax,app_save.BW_cyto_patch);
I_overlay = getframe(ax);
imwrite(I_overlay.cdata, strcat(root,name_tmp,'_overlay segmentation.tif'));
filename = strcat(root,date_get_str('second')," ",name_tmp);
pause(2);
close all;
save(strcat(filename,'.mat'));