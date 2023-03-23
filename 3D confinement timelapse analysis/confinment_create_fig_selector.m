function confinment_create_fig_selector(I_rgb_ini_all)

N_z = size(I_rgb_ini_all,2);
str_ini_fig = 'Initialization';
S.fig1 = figure('color','white','NumberTitle','off','Name',str_ini_fig);
S.fig1.NextPlot = 'add'; % This is to be sure that the 2017 version of matlab works, otherwise it replace the plot and delete the previous axis
for aa = 1 : N_z
    ax_tmp = axes('parent',S.fig1,'Visible','off');
    %% This is to create variables with naming incrementing, but I did not find solution to put that into a struct with the good S.ax1, S.ax2 naming
    % So  I create the S.ax.all, with the axes insides, and the idx refer
    % to the ax number
    %     ax_name = strcat('ax',num2str(aa));
    %     assignin('base',ax_name,ax_tmp); % Create the ax with the progressive names
    %     clear ax_tmp;
    %     S.ax(aa).all = evalin('base',ax_tmp);
    S.ax(aa).all = ax_tmp;
    imshow(I_rgb_ini_all{1,aa},'parent',S.ax(aa).all);
    set(S.ax(aa).all,'CLimMode','auto')
    S.fig1.NextPlot = 'add';
    S.ax(aa).all.Title.String = strcat('\textbf{Z = '," ",num2str(aa),'}');
    S.ax(aa).all.Visible = 'off';
    S.ax(aa).actif = true;
    if aa ~= 1
        set(S.ax(aa).all.Children,'Visible','off');
        set(S.ax(aa).all.Title,'Visible','off');
        S.ax(aa).actif = false;
    end
end
clear aa
%% Button when it is done 
S.ax_sizing = S.ax(1).all;
width_butt = S.ax_sizing.Position(3)/4;
x_butt = S.ax_sizing.Position(1)+S.ax_sizing.Position(3)/2 - width_butt/2;
height_butt = S.ax_sizing.Position(4)/15;
y_butt = S.ax_sizing.Position(2) - 3*height_butt/2;

%%  Button to start drawing in each ax
width_start = S.ax_sizing.Position(3)/5;
x_start = S.ax_sizing.Position(1);
height_start = S.ax_sizing.Position(4)/15;
y_start = S.ax_sizing.Position(2) - 3*height_butt/2;
%% Button to go one Z up, based on the position of the "DONE" button, only the x_up changed ! and the width
width_up = S.ax_sizing.Position(3)/10;
x_up = S.ax_sizing.Position(1)+S.ax_sizing.Position(3)/2 - width_up/2 + 4*width_up;
height_up = S.ax_sizing.Position(4)/15;
y_up = S.ax_sizing.Position(2) + +S.ax_sizing.Position(4);

%% Button to go one Z down, based on the position of the "DONE" button, only the x_down changed  and the width
width_down = S.ax_sizing.Position(3)/10;
x_down = S.ax_sizing.Position(1)+S.ax_sizing.Position(3)/2 - width_down/2 + 3*width_down;
height_down = S.ax_sizing.Position(4)/15;
y_down = S.ax_sizing.Position(2) + S.ax_sizing.Position(4);

%% Creation of button
S.done_buttun = uicontrol('style','push',...
    'units','normalized',...
    'position',[x_butt, y_butt,width_butt,height_butt],...
    'HorizontalAlign','left',...
    'string','Done',...
    'fontsize',14,'fontweight','bold',...
    'callback',{@done,S});


S.start_buttun = uicontrol('style','push',...
    'units','normalized',...
    'position',[x_start, y_start,width_start,height_start],...
    'HorizontalAlign','left',...
    'string','Draw',...
    'fontsize',14,'fontweight','bold',...
    'callback',{@start_draw,S});

S.nav(1)= uicontrol('style','push',...
    'units','normalized',...
    'position',[x_up, y_up,width_up,height_up],...
    'HorizontalAlignment','left',...
    'string','+1',...
    'fontsize',14);

S.nav(2) = uicontrol('style','push',...
    'units','normalized',...
    'position',[x_down, y_down,width_down,height_down],...
    'HorizontalAlignment','left',...
    'string','-1',...
    'fontsize',14);
set(S.nav(:),{'callback'},{{@navigate_img_plus,S};{@navigate_img_minus,S}})




function S = navigate_img_plus(varargin)
N = numel(varargin);
S = varargin{N};
curr = find([S.ax.actif] == 1);
if curr == size([S.ax.all],2)
else
    S.ax(curr).actif = false;
    S.ax(curr+1).actif = true;
    update_viewer_z_stack(S,'plus');
    %
end
% Now we need to make sure that the new value is available for all buttun !
set(S.nav(:),{'callback'},{{@navigate_img_plus,S};{@navigate_img_minus,S}});
set(S.start_buttun,'callback',{@start_draw,S});
set(S.done_buttun,'callback',{@done,S});
assignin('base','S',S);
% assignin('base','S',S);

function S = navigate_img_minus(varargin)
N = numel(varargin);
S = varargin{N};
curr = find([S.ax.actif] == 1);
if curr == 1
else
    S.ax(curr).actif = false;
    S.ax(curr-1).actif = true; % that is the difference between minus and plus
    update_viewer_z_stack(S,'minus');
    %
end
% Now we need to make sure that the new value is available for all buttun !
set(S.nav(:),{'callback'},{{@navigate_img_plus,S};{@navigate_img_minus,S}});
set(S.start_buttun,'callback',{@start_draw,S});
set(S.done_buttun,'callback',{@done,S});
assignin('base','S',S);


function update_viewer_z_stack(S,nav_dir)
% One should update the title, the ax and the ax.image !
to_change = find([S.ax.actif] == 1);
switch nav_dir
    case 'plus'
        for aa = 1 : to_change - 1
            set(S.ax(aa).all.Children,'Visible','off');
            set(S.ax(aa).all.Title,'Visible','off');    
        end
        set(S.ax(to_change).all.Children,'Visible','on');
        set(S.ax(to_change).all.Title,'Visible','on');
    case 'minus'
        for aa = size([S.ax.all],2) :-1: to_change + 1
            set(S.ax(aa).all.Children,'Visible','off');
            set(S.ax(aa).all.Title,'Visible','off');
        end
        set(S.ax(to_change).all.Children,'Visible','on');
        set(S.ax(to_change).all.Title,'Visible','on');
end

function [] = start_draw(varargin)
N = numel(varargin);
S = varargin{N};
curr = find([S.ax.actif] == 1);
impoint(S.ax(curr).all);


function [] = done(varargin)
S = varargin{3};
select_all = true;
S.select_all = true;
assignin('base','select_all',select_all);
assignin('base','S',S);
% delete(S.fig1);
