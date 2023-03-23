close all ; clear all

%%                          Initialization latex font
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
set(groot,'defaultTextInterpreter','latex');
cellsize_um = 50 ; % Size used after for the crop, put a value higher to capture the all cells.

%% Measuring time
% tStart = tic ;
% fprintf('Start selecting cells... \n')
% tElapsed = toc(tStart);
% fprintf('End selecting cells. Time elapsed: ');cprintf('_red','%0.3f s\n',tElapsed);
addpath('M:\BM\Hubert Taieb (M)\02 PhD\07 Matlab code\04 Custom general functions\');
addpath('M:\BM\Hubert Taieb (M)\02 PhD\07 Matlab code\04 Custom general functions\bfmatlab\');
% addpath('M:\BM\Hubert Taieb (M)\02 PhD\07 Matlab code\04 Custom general functions\bfmatlab\private\');
addpath('M:\BM\Hubert Taieb (M)\02 PhD\07 Matlab code\04 Custom general functions\Hubert functions\');
%% Select the czi files with one scene inside
answer = MFquestdlg_center([],'Please now select the folder with images for processing',...
    'Loading data','Select folder','Cancel','Select folder');
switch answer
    case 'Select folder'
        [cziname,path_data] = get_old_folder_position('czi');
        czifilename = fullfile(path_data,cziname);
    case 'Cancel'
        disp('No folder loaded');
        return
end

answer_LD = MFquestdlg_center([],'Choice of selected cells',...
    'Loading data','Live','Dead','Live');
% create the name of the tmp file for the code in case of crash
processed_path = strcat(path_data,cziname(1:end-4),'\');
if ~exist(processed_path,'dir')
    mkdir(processed_path);
end
tmp_file = strcat(processed_path,cziname(1:end-4),'_tmp_data_',answer_LD,'.mat');
% create the name of the tmp file for the code in case of crash

%% bfopen open the image no matter the size,
bfCheckJavaPath();
bfInitLogging();
data = bfopen(czifilename); % This will load all the data into Matlab, take care with big files!!
omeMeta = data{1, 4};       % This will load the metaData

%% bfGetReader only open the header and hence select only the image we want to load
reader = bfGetReader(czifilename);
% omeMeta = reader.getMetadataStore(); % this to access the OME medatada
% without loading all the data ! for big files
N_c = reader.getSizeC;
N_t = reader.getSizeT;
N_z = reader.getSizeZ;

nb_serie = reader.getSeriesCount();
if nb_serie ~= 1
    error('There are more than one scene in the czi files, please split it');
end
nImages = omeMeta.getImageCount();
nPlanes = omeMeta.getPlaneCount(0);

%% get the time from the first image taken (in seconds)
t_0 = omeMeta.getImageAcquisitionDate(0).getValue();
t_0(t_0 =='T')= ' ';
format_time = 'yyyy-MM-dd HH:mm:ss.SSS';
t_o_date = datetime(t_0,'InputFormat',format_time);
%% Then calculate the deltaT between the images
%g etPlaneDeltaT(first is the nb of "nImage" ,meaning the nb of scene, and
% second is the plane number) but here we need the index to have the time
% between time serie and not between the planes or the channels!
t1 = omeMeta.getPlaneDeltaT(0,1-1).value().doubleValue(); % The function is 0-base indexed take car !!

% reader.setSerie(nb_serie -1) is not necessary here
reader.setSeries(nb_serie - 1); % when there is only one scene inside the czi, otherwise reader.setSeries(nb_serie - 1);
%% This is just because depending on the experiment, the order of the cannels can vary
channel_name = cell(N_c,1);
for cc = 1 : N_c
    channel_name{cc,1} = char(omeMeta.getChannelFluor(0,cc-1));
end
c_mcherry = find(contains(channel_name,'mCher') == 1);
c_mvenus = find(contains(channel_name,'YFP') == 1);
c_phase = find(contains(channel_name,'Phase') == 1);
c_membrite = find(contains(channel_name,'Alexa') == 1);
% With this, the idx of channel_name is linked to one channel !
% iPlane = reader.getIndex(N_z - 1, N_c -1, N_t - 1) + 1; % with the +1 the iPlane is 1-base indexed
% I = bfGetPlane(reader, iPlane); %  bfGetPlane takes a 1-base indexed number, use this only if we do not want to load via bfopen !

%% The follow up is the initialization function to select the cells of interest in the plane GIVEN
voxelsizeX = omeMeta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROMETER).doubleValue(); % um/px
cellsize_px = round(cellsize_um/voxelsizeX); % cellsize in pixel roughly
if exist(tmp_file,'file')
    save(tmp_file,'cellsize_px','voxelsizeX','-append');
else
    save(tmp_file,'cellsize_px','voxelsizeX');
end

t_ini = 1; % first time
%% This is the implementation of the Z stacking initialization.
for ii = 1 : N_z
    iPlane(c_mvenus,ii) = reader.getIndex(ii-1,c_mvenus-1,t_ini-1)+1;
    iPlane(c_mcherry,ii) = reader.getIndex(ii-1,c_mcherry-1,t_ini-1)+1;
    iPlane(c_phase,ii) = reader.getIndex(ii-1,c_phase-1,t_ini-1)+1;
    %% IF green is chosen then it is the base for all the others images !!
    if ii  == 1
        t_ini_sec = omeMeta.getPlaneDeltaT(0,iPlane(c_mvenus,ii)-1).value().doubleValue();
    end
    I_ini_all{c_phase,ii} = from_14_2_8_bits(data{1,1}{iPlane(c_phase,ii),1});
    I_ini_all{c_mvenus,ii} = from_14_2_8_bits(data{1,1}{iPlane(c_mvenus,ii),1});
    I_ini_all{c_mcherry,ii} = from_14_2_8_bits(data{1,1}{iPlane(c_mcherry,ii),1});
    
    I_rgb_ini_all{1,ii} = uint8(zeros([size(I_ini_all{c_mvenus,ii}),3]));
    I_rgb_ini_all{1,ii} = repmat(I_ini_all{c_phase,ii},[1 1 3]);
    
    %     I_rgb_ini_all{1,ii}(:,:,1) = I_ini_all{c_mcherry,ii};
    %     I_rgb_ini_all{1,ii}(:,:,2) = I_ini_all{c_mvenus,ii};
    %     I_rgb_ini_all{1,ii}(:,:,3) = I_ini_all{c_phase,ii};
end

if exist(tmp_file,'file')
    tmp = load(tmp_file);
    if isfield(tmp,'Cells')
        load(tmp_file,'Cells');
    else
        kk= 0;
        Cells = struct('Position',[],'posrect',[],'imgs',[],'intensity',[],'focus',[],'parent',[],'BWs',[]);
        select_all = false;
        answer_ini = MFquestdlg_center([],'Use your mice to click where the interested cells are','Selection','Go','Cancel','Go');
        switch answer_ini
            case 'Go'
                %% The new version of create fig selector (2019-01-17) allows multiple plan drawing
                % It gives S as output, which contains the points to be
                % sorted and then used tocreate the struct Cells.
                confinment_create_fig_selector(I_rgb_ini_all);
                axdrag();
            otherwise
                error('You stop the program, please try again');
        end
        for aa = 1 : N_z
            ax_tmp = S.ax(aa).all;
            if numel(ax_tmp.Children) > 1 % meaning that there is not only just the image
                points = findobj(ax_tmp,'type','Line');
                for pp = 1 : 2 : numel(points) % because each "line" that represents t he points are two marker, one cercle and one cross
                    kk = kk + 1;
                    x = round(points(pp).XData);
                    y = round(points(pp).YData);
                    Cells(kk).Position = [x,y];
                    Cells(kk).parent.phase = iPlane(c_phase,aa);
                    Cells(kk).parent.mcherry= iPlane(c_mcherry,aa);
                    Cells(kk).parent.mvenus = iPlane(c_mvenus,aa);
                    Cells(kk).parent.Zplane = aa;
                    
                end
                clear ax_tmp;
            else
                fprintf('The image %d did not get any points :( \n',aa);
            end
            
        end
        clear kk
        save(tmp_file,'Cells','S','-append');
    end
end

Nb_cells = size(Cells,2);
Cells_all = cell(N_t,1);
tStart = tic ;
fprintf('Start processing through time lapse... \n')

for tt = 1 : N_t
    %% For the first time point, the assumption is that the user selected
    % the good focus plane so there is no search function for this time.
    if tt == 1
        for cc = 1 : Nb_cells
            imgs(cc).I_r = I_ini_all{c_mcherry,Cells(cc).parent.Zplane};
            imgs(cc).I_g = I_ini_all{c_mvenus,Cells(cc).parent.Zplane};
            imgs(cc).I_ph = I_ini_all{c_phase,Cells(cc).parent.Zplane};
            
            Cells_local = confinment_update_all_field(imgs(cc),Cells(cc),cc,tmp_file,tt);
            Cells_local.t_sec = t_ini_sec;
            Cells_tt(cc) = Cells_local;
            tmp_old_position{cc,3} = fmeasure(imgs(cc).I_ph,'LAPD',Cells_tt(cc).posrect);
            tmp_old_position{cc,1} = Cells_tt(cc).Position;
            tmp_old_position{cc,2} = Cells_tt(cc).radii;
        end
        clear Cells;
        Cells = Cells_tt;
        if exist(tmp_file,'file')
            save(tmp_file,'Cells','-append');
        else
            save(tmp_file,'Cells');
        end
        
        Cells_all{tt,1} = Cells_tt;
        imgs_all{tt,1} = imgs;
        clear Cells_tt imgs_all;
    else
        for cc = 1 : Nb_cells
            %             Cells_tt =[];
            for zz = 1 : N_z
                %              iPlane_green = reader.getIndex(zz-1,c_mvenus-1,tt-1)+1;
                iPlane_phase = reader.getIndex(zz-1,c_phase-1,tt-1)+1;
                I_ph = from_14_2_8_bits(data{1,1}{iPlane_phase,1});
                %              I_g = from_16_2_8_bits(data{1,1}{iPlane_green,1});
                x = tmp_old_position{cc,1}(1,1);
                y = tmp_old_position{cc,1}(1,2);
                posrect_local_focus = [x - cellsize_px/2, ...
                    y - cellsize_px/2, ...
                    cellsize_px,cellsize_px];
                Cells(cc).focus_ph(zz,1) = fmeasure(I_ph,'LAPD',posrect_local_focus);
                %              focus_g(zz) = fmeasure(I_g,'LAPD',Cells(1).posrect);
            end
            %%%%% TAKE OVER FROM HERE , PROBLEM WITH CC AND TT !!
            %% First idea was to go through Z and find "best" focus
            % But it fails at some point
            %             [maxi_value,idx_maxi(cc)] = max(Cells(cc).focus_ph);
            %% Second idea is to get the similar focus at the first image
            % This is supposing that the user find the best plane in the
            % first place
            dist_focus = abs(Cells(cc).focus_ph - tmp_old_position{cc,3});
            [~,idx_maxi(cc)] = min(dist_focus);
            if isempty(idx_maxi(cc))
                error('No maximum found for the focus, you may have lost the cell');
            else
                Cells(cc).idx_sharp = idx_maxi(cc);
                iPlane_red_sharp = reader.getIndex(idx_maxi(cc)-1,c_mcherry - 1, tt - 1) + 1;
                iPlane_green_sharp = reader.getIndex(idx_maxi(cc)-1,c_mvenus - 1, tt - 1) + 1;
                iPlane_phase_sharp = reader.getIndex(idx_maxi(cc)-1,c_phase - 1, tt - 1) + 1;
                
                %                 Cells(cc).t_sec = omeMeta.getPlaneDeltaT(0,iPlane_green_sharp-1).value().doubleValue();
                
                imgs(cc).I_r = from_14_2_8_bits(data{1,1}{iPlane_red_sharp,1});
                imgs(cc).I_g = from_14_2_8_bits(data{1,1}{iPlane_green_sharp,1});
                imgs(cc).I_ph = from_14_2_8_bits(data{1,1}{iPlane_phase_sharp,1});
                Cells_local = struct('Position',[],'posrect',[],'imgs',[],'intensity',[],'focus',[]);
                Cells_tt(cc) = confinment_update_all_field(imgs(cc),Cells_local,cc,tmp_file,tt,tmp_old_position);
                Cells_tt(cc).idx_sharp = idx_maxi(cc);
                Cells_tt(cc).focus.ph= Cells(cc).focus_ph;
                Cells_tt(cc).t_sec = omeMeta.getPlaneDeltaT(0,iPlane_green_sharp-1).value().doubleValue();
                
                %                 to_add_t_sec(cc) = omeMeta.getPlaneDeltaT(0,iPlane_green_sharp-1).value().doubleValue();
                %                 to_add_idx_sharp(cc) = idx_maxi(cc);
            end
            tmp_old_position{cc,1} = Cells_tt(cc).Position;
            tmp_old_position{cc,2} = Cells_tt(cc).radii;
        end
        
        clear idx_maxi % this will reboot the idx maxi at each time point
        Cells_all{tt,1} = Cells_tt;
        imgs_all{tt,1} = imgs;
    end
    %     data_fig.x = [imgs.t_all_sec]';
    %     data_fig.y = Cells_all(1:tt,1);
end

tElapsed = toc(tStart);
fprintf('End processing through time lapse. Time elapsed: ');cprintf('_red','%0.3f s\n',tElapsed);
save(tmp_file,'Cells_all','-append');



% I_8_all{k} = I;
%
% stackSizeZ = omeMeta.getPixelsSizeZ(0).getValue();
% in �m
% voxelSizeXdouble = voxelSizeX.doubleValue();                                  % The numeric value represented by this object after conversion to type double
% voxelSizeY = omeMeta.getPixelsPhysicalSizeY(0).value(ome.units.UNITS.MICROMETER); % in �m
% voxelSizeYdouble = voxelSizeY.doubleValue();                                  % The numeric value represented by this object after conversion to type double
% voxelSizeZ = omeMeta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROMETER); % in �m
% voxelSizeZdouble = voxelSizeZ.doubleValue();
%
% % The numeric value represented by this object after conversion to type double

