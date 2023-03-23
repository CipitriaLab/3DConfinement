function counting_generate_graph(storage,sample_name,N,nb_red,nb_green,nb_yellow)


set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
set(groot,'defaultTextInterpreter','latex'); %trying to set the default

%%%%%%%%%%%%%%%%%%%%
%%% Nargin Check %%%
%%%%%%%%%%%%%%%%%%%%
if nargout>0
    error('Too much output arguments');
end
if nargin==0
    storage = [];
    sample_name = [];
    N = [];
    nb_red = [];
    nb_green = [];
    nb_yellow = [];
    % root = 'M:\BM\Hubert Taieb (M)\Sadra\Sadra_TimeLaps\';
    root= 'G:\02 MPI-3A\Sadra_TimeLaps\';
    %% The job files in each folder\processed_data_adapt\ contains the data interesting
    scenes = {'2D_HeLa1','2D_HeLa2','2D_MDA1','2D_MDA2','TCP_HeLa1','TCP_HeLa2','TCP_MDA1','TCP_MDA2'};
    
    %% CHANGE THE SAMPLE NAME TO LOAD OTHER DATA FROM OTHER SAMPLES
    answer = bttnChoiseDialog(scenes,'Chose sample',scenes{1},...
        'Please choose the sample name to plot the data from',[1 8]);
    sample_name = scenes{answer};
    %%%%%%%%%%%%%%%%%%%%%%%%%
    folder_data = strcat(root,sample_name,'\processed_data_adapt','\job-',sample_name,'.mat');
    if exist(folder_data,'file')==0
        error('The mat file is not found, please run the job file');
    end
    load(folder_data,'sample_name','N','nb_red','nb_green','nb_yellow');
    storage = strcat(root,sample_name,'\processed_data_adapt\');
else
    
end
idx=strfind(sample_name,'_');
sample_name_text = [sample_name(1:idx-1),'\_',sample_name(idx+1:end)];
text_title = strcat('\textbf{Repartition of cells as a function of time at: ',{' '},sample_name_text,'}');
fig1=figure('color','white','Units','centimeters');
ax1 = axes('parent',fig1);


name_fig1 = strcat(sample_name,'-cell_vs_time_line');
x = 0:15:15*(N-1);
x=(x./60)'; % In hours
% subplot(1,2,1)
% nb_red = nb_red;
% nb_green = nb_green - nb_yellow;
plot(x,nb_red,'r','Marker','none','LineStyle','-','LineWidth',2);
hold on;
plot(x,nb_green,'g','Marker','none','LineStyle','-','LineWidth',2);
plot(x,nb_yellow,'color',[1 1 0],'Marker','none','LineStyle','-','LineWidth',2);

% title(text_title);
% xlabel('\textbf{Time (hours)}')

% subplot(1,2,2)
% plot(x,nb_red_area,'r');hold on;plot(x,nb_green_area,'g');
% title(text_title);
% xlabel('\textbf{Time (hours)}')
% ylabel('\textbf{Area (pixels)}');
ax1.FontSize = 20;
ylabel('\textbf{Nb of cells (-)}');
legend('mCherry','mVenus','mCherry and mVenus','Location','best','Interpreter','latex');
ax1.Box = 'off';
ax1.Legend.Box = 'off';
ax1.XTick = [0 24 48];
ax1.XLim = [0 48];
ax1.XTickLabel = {'Start','Day 1','Day 2'};
ax1.XTickLabelRotation = 60;
ax1.LineWidth = 2;
ax1.Legend.Location = 'best';
ax1 = make_ticks_latex_bold(ax1);
ax1.Legend.Location = 'best';



answer = MFquestdlg_center([],'Please move the legend before saving','moving legend','Done','Abort','Done');
switch answer
    case 'Done'
        tStart=tic;
        fprintf('Start saving figure... \n');
        saveas(fig1,strcat(storage,name_fig1,'.svg'));
        saveas(fig1,strcat(storage,name_fig1,'.png'));
        tElapsed = toc(tStart);
        fprintf('Saving figure in png and svg done. Time elapsed: ');cprintf('_red','%0.3f s\n',tElapsed);
    case 'Abort'
        error('Stop program');
end
delete(fig1)

to_export = table(x,nb_red,nb_green,nb_yellow);
tStart=tic;
fprintf('Start saving data... \n');
writetable(to_export,strcat(storage,'job-',sample_name,'.xlsx'));
tElapsed = toc(tStart);
fprintf('Saving data in excel done. Time elapsed: ');cprintf('_red','%0.3f s\n',tElapsed);

fig=figure('color','white','Units','centimeters');
name_fig = strcat(sample_name,'-cell_vs_time');
ax=axes('parent',fig);
fig.Visible='on';
% subplot(1,2,1)
% start = 1;
% middle = floor(N/2);
% stop = N ;
%% This is working for MDA TCP 1
start = 1;
middle = 73;
stop = 184;
y_bar = [nb_red(start:middle:stop),nb_yellow(start:middle:stop),nb_green(start:middle:stop)];
b=bar(y_bar,'stacked','FaceColor','flat');
set(b(1),'FaceColor',[1 0 0]);
set(b(2),'FaceColor',[1 1 0]);
set(b(3),'FaceColor',[0 1 0]);
set(b,'LineWidth',2)
ax1.XLim = [-1 4];
set(ax,'XTick',[1:3])
set(ax,'XTickLabel',{'Start','Day 1','Day 2'});
ax.FontSize = 20;
ylabel('\textbf{Number of cells (-)}');
legend('mCherry','mCherry and mVenus','mVenus','Location','best','Interpreter','latex');
ax.Box = 'off';
ax1.Legend.Box = 'off';
ax1.YLim = [0 600];
ax.XTickLabelRotation = 60;
ax.LineWidth = 2;
ax.Legend.Location = 'best';
ax.Legend.Box = 'off';
ax = make_ticks_latex_bold(ax);


% plot(x,nb_red,'r','Marker','.','LineStyle','-');hold on;plot(x,nb_green,'g','Marker','.','LineStyle','-');plot(x,nb_yellow,'color',[1 1 0],'Marker','.','LineStyle','-');
title(text_title);
% xlabel('\textbf{Time (hours)}')
ylabel('\textbf{Nb of cells (-)}');
answer = MFquestdlg_center([],'Please move the legend before saving','moving legend','Done','Abort','Done');
switch answer
    case 'Done'
        tStart=tic;
        fprintf('Start saving figure... \n');
        saveas(fig,strcat(storage,name_fig,'.svg'));
        saveas(fig,strcat(storage,name_fig,'.png'));
        tElapsed = toc(tStart);
        fprintf('Saving figure in png and svg done. Time elapsed: ');cprintf('_red','%0.3f s\n',tElapsed);
    case 'Abort'
end
delete(fig)
end