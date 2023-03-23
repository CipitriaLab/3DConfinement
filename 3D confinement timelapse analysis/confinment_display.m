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
    load(fullfile('/scratch/THVB-LBOX183_GNU/01 Matlab tmp',cziname),'Cells_all');
else
    load(fullfile(path_data,cziname),'Cells_all');
end


N = size(Cells_all{1,1},2);
get_out = false;
cell_nb_1 = 0;
pass_in_loop = 1;
while get_out ~= true
    
    %%% CHANGE IN CODE TO BE UPDATED ON M 2019-04-02
    if N  < 4
        cell_nb_1 = cell_nb_1 +1;
        % cell_nb_1 = 1;
        cell_nb_2 = cell_nb_1 +1 ;
        cell_nb_3 = cell_nb_2 + 1;
    else
        if pass_in_loop == 1
            cell_nb_1 = cell_nb_1 +1;
            
            cell_nb_2 = cell_nb_1 +1 ;
            cell_nb_3 = cell_nb_2 + 1;
        else
            
            cell_nb_1 = cell_nb_1 +3;
            cell_nb_2 = cell_nb_1 +1 ;
            cell_nb_3 = cell_nb_2 +1;
            if cell_nb_3 > N
                cell_nb_3 = N;
                cell_nb_2 = N-1;
                % cell_nb_1 = 1;
                cell_nb_1 = N-2 ;
                
            else
            end
        end
    end
    
    
    fig1=figure('color','white');
    MaximizeFigureWindow();
    pause(0.1);
    fig1.Position(3) = fig1.Position(3)/2;
     pause(0.1);
    s(1) = subplot(3,3,1,'parent',fig1);
    s(2) = subplot(3,3,2,'parent',fig1);
    s(3) = subplot(3,3,3,'parent',fig1);
    s(4) = subplot(3,3,4,'parent',fig1);
    s(5)= subplot(3,3,5,'parent',fig1);
    s(6) = subplot(3,3,6,'parent',fig1);
    s(7) = subplot(3,3,7,'parent',fig1);
    s(8)= subplot(3,3,8,'parent',fig1);
    s(9) = subplot(3,3,9,'parent',fig1);
    
    fig2=figure3('color','white');
    MaximizeFigureWindow();
    pause(0.1);
    fig2.Position = [fig1.Position(1)+fig1.Position(3), fig1.Position(2), fig1.Position(3),fig1.Position(4)];
    pause(0.1);
    s2(1) = subplot(1,3,1,'parent',fig2);
    title(s2(1),strcat('\textbf{Cell Nb '," ",num2str(cell_nb_1),'}'));
    s2(2) = subplot(1,3,2,'parent',fig2);
    title(s2(2),strcat('\textbf{Cell Nb '," ",num2str(cell_nb_2),'}'));
    s2(3) = subplot(1,3,3,'parent',fig2);
    title(s2(3),strcat('\textbf{Cell Nb '," ",num2str(cell_nb_3),'}'));
    hold(s2(1),'on');
    hold(s2(2),'on');
    hold(s2(3),'on');
    xlabel(s2(1),'\textbf{Time (hours)}');
    xlabel(s2(2),'\textbf{Time (hours)}');
    xlabel(s2(3),'\textbf{Time (hours)}');
    set(s2,'YLim',[0 255]);
    set(s2,'XLim',[0 90]);
    set(s2,'box','on');
    grid(s2(1),'on');
    grid(s2(2),'on');
    grid(s2(3),'on');
    % ax1 = axes('parent',fig1);
    
    %%%%%
    times=[];
    N_t = size(Cells_all,1);
    legend(s2(1),'show');
    legend(s2(2),'show');
    legend(s2(3),'show');
    
    for mm = 1 : N_t
        % time same for all
        times = [times;Cells_all{mm,1}(1).t_sec./3600];
        
        imshow(Cells_all{mm,1}(cell_nb_1).imgs.mcherry,'parent',s(1))
        title(s(1),strcat('\textbf{Cell Nb '," ",num2str(cell_nb_1),'}'));
        ylab(1) = ylabel(s(1),'\textbf{mCherry}','HorizontalAlignment','right','Rotation',0);
        
        
        
        imshow(Cells_all{mm,1}(cell_nb_2).imgs.mcherry,'parent',s(2))
        title(s(2),strcat('\textbf{Cell Nb '," ",num2str(cell_nb_2),'}'));
        
        
        imshow(Cells_all{mm,1}(cell_nb_3).imgs.mcherry,'parent',s(3))
        title(s(3),strcat('\textbf{Cell Nb '," ",num2str(cell_nb_3),'}'));
        
        set(s(1:3),'colormap',red_colormap);
        
        
        imshow(Cells_all{mm,1}(cell_nb_1).imgs.mvenus,'parent',s(4))
        ylab(2) = ylabel(s(4),'\textbf{mVenus}','HorizontalAlignment','right','Rotation',0);
        
        imshow(Cells_all{mm,1}(cell_nb_2).imgs.mvenus,'parent',s(5))
        
        imshow(Cells_all{mm,1}(cell_nb_3).imgs.mvenus,'parent',s(6))
        set(s(4:6),'colormap',green_colormap);
        
        
        imshow(Cells_all{mm,1}(cell_nb_1).imgs.phase,'parent',s(7))
        ylab(3) = ylabel(s(7),'\textbf{Phase}','HorizontalAlignment','right','Rotation',0);
        
        imshow(Cells_all{mm,1}(cell_nb_2).imgs.phase,'parent',s(8))
        
        imshow(Cells_all{mm,1}(cell_nb_3).imgs.phase,'parent',s(9))
        set(s,'Visible','off')
        final_time = Cells_all{N_t,1}(1).t_sec./3600;
        xlabel(s(8),strcat('\textbf{Time ='," ",num2str(times(mm),3),'/',num2str(final_time,3),' hours}'));
        
        set(s,'CLimMode','auto')
        
        intens_mcherry(1,mm) = mean(Cells_all{mm,1}(cell_nb_1).intensity.mcherry);
        intens_mcherry_std(1,mm) = std(double(Cells_all{mm,1}(cell_nb_1).intensity.mcherry));
        intens_mvenus(1,mm) = mean(Cells_all{mm,1}(cell_nb_1).intensity.mvenus);
        intens_mvenus_std(1,mm) = std(double(Cells_all{mm,1}(cell_nb_1).intensity.mvenus));
        %     e1(1) = errorbar(s2(1),times,intens_mcherry(1,1:mm),intens_mcherry_std(1,1:mm),'color','red','Marker','x');
        %     e1(2) = errorbar(s2(1),times,intens_mvenus(1,1:mm),intens_mvenus_std(1,1:mm),'color','green','Marker','x');
        
        p1(1) = plot(s2(1),times,intens_mcherry(1,1:mm),'color','red','Marker','.','LineStyle','-','DisplayName','mCherry');
        p1(2) = plot(s2(1),times,intens_mvenus(1,1:mm),'color','green','Marker','.','LineStyle','-','DisplayName','mVenus');
        
        ylab2(1) = ylabel(s2(1),'\textbf{Intensity}','HorizontalAlignment','right','Rotation',0);
        
        intens_mcherry(2,mm) = mean(Cells_all{mm,1}(cell_nb_2).intensity.mcherry);
        intens_mcherry_std(2,mm) = std(double(Cells_all{mm,1}(cell_nb_2).intensity.mcherry));
        intens_mvenus(2,mm) = mean(Cells_all{mm,1}(cell_nb_2).intensity.mvenus);
        intens_mvenus_std(2,mm) = std(double(Cells_all{mm,1}(cell_nb_2).intensity.mvenus));
        %     e2(1) = errorbar(s2(2),times,intens_mcherry(2,1:mm),intens_mcherry_std(2,1:mm),'color','red','Marker','x');
        %     e2(2) = errorbar(s2(2),times,intens_mvenus(2,1:mm),intens_mvenus_std(2,1:mm),'color','green','Marker','x');
        p2(1) = plot(s2(2),times,intens_mcherry(2,1:mm),'color','red','Marker','.','LineStyle','-','DisplayName','mCherry');
        p2(2) = plot(s2(2),times,intens_mvenus(2,1:mm),'color','green','Marker','.','LineStyle','-','DisplayName','mVenus');
        %     ylab2(1) = ylabel(s2(2),'\textbf{Intensity}','HorizontalAlignment','right','Rotation',0);
        
        intens_mcherry(3,mm) = mean(Cells_all{mm,1}(cell_nb_3).intensity.mcherry);
        intens_mcherry_std(3,mm) = std(double(Cells_all{mm,1}(cell_nb_3).intensity.mcherry));
        intens_mvenus(3,mm) = mean(Cells_all{mm,1}(cell_nb_3).intensity.mvenus);
        intens_mvenus_std(3,mm) = std(double(Cells_all{mm,1}(cell_nb_3).intensity.mvenus));
        %     e3(1) = errorbar(s2(3),times,intens_mcherry(3,1:mm),intens_mcherry_std(3,1:mm),'color','red','Marker','x');
        %     e3(2) = errorbar(s2(3),times,intens_mvenus(3,1:mm),intens_mvenus_std(3,1:mm),'color','green','Marker','x');
        
        p3(1) = plot(s2(3),times,intens_mcherry(3,1:mm),'color','red','Marker','.','LineStyle','-','DisplayName','mCherry');
        p3(2) = plot(s2(3),times,intens_mvenus(3,1:mm),'color','green','Marker','.','LineStyle','-','DisplayName','mVenus');
        
        %     ylab2(1) = ylabel(s2(3),'\textbf{Intensity}','HorizontalAlignment','right','Rotation',0);
        processed_path = strcat(path_data,cziname(1:end-4),'\');
        folder_imgs = strcat(processed_path,'\Cell_nb_',num2str(cell_nb_1),'-',num2str(cell_nb_3),'\');
        if ~exist(folder_imgs,'dir')
            mkdir(folder_imgs);
        end
        saveas(fig1,strcat(folder_imgs,'images_',get_digit(mm),'.png'));
        saveas(fig2,strcat(folder_imgs,'graphs_',get_digit(mm),'.png'));
        %     pause(2);
        if mm ~= N_t
            cla(s2(1))
            cla(s2(2))
            cla(s2(3))
        end
        
    end
    
    
    
    for mm = 1 : N_t
        I_left = imread(strcat(folder_imgs,'images_',get_digit(mm),'.png'));
        I_right = imread(strcat(folder_imgs,'graphs_',get_digit(mm),'.png'));
        
        I_merge = [I_left,I_right];
        folder_merged = strcat(folder_imgs,'merged\');
        if ~exist(folder_merged,'file')
            mkdir(folder_merged)
        else
        end
        imwrite(I_merge,strcat(folder_merged,'merges_',get_digit(mm),'.png'));
        
    end
    
   
   
    pass_in_loop = pass_in_loop +1;
    video_name = strcat('Cell_nb_',num2str(cell_nb_1),'-',num2str(cell_nb_3),'_Video');
    confinment_make_video(video_name,folder_merged);
     pause(3);
     if cell_nb_3 == N
        get_out = true;
    end
end



%% Show 3D intensity plots
% [xx,yy] = create_3d_intenisty_img(Cells_all{1,1}(1).BWs.mcherry);
% fig1 = figure('color','white');
% MaximizeFigureWindow();
% ax1 = axes('parent',fig1);
% colormap(red_colormap);
% fig2=figure2('color','white');
% MaximizeFigureWindow();
% ax2 = axes('parent',fig2);
% colormap(green_colormap);
% fig3=figure3('color','white');
% MaximizeFigureWindow();
% ax3 = axes('parent',fig3);
% colormap(gray);
% % ax1.Colormap = red_colormap;
% % ax2.Colormap = green_colormap;
%
% for mm = 1 : N_t
% %     for cc = 1 : 3
%     I_r = Cells_all{mm,1}(3).imgs.mcherry;
%     I_g = Cells_all{mm,1}(3).imgs.mvenus;
%     I_ph = Cells_all{mm,1}(3).imgs.phase;
%     mesh(ax1,xx,yy,I_r);
%     mesh(ax2,xx,yy,I_g);
%     mesh(ax3,xx,yy,I_ph);
% %     create_3d_intenisty_img(I_r);
% %     end
% pause(2)
% end

