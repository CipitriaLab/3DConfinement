function [BW,S,CC] = create_CC_classic(BW,I, filter, type, voxelsize_conv)
% 1) BW is the binary image to use
% 2) I is the grayscale corresponding, images, should have same size
% 3) Filter is the radius in um of the circle that should be removed
% 4) Type is "up" or "down", meaning removing things above the filter, or below
% 5) voxelsize_conv is the constant to go from um to pixel, could be 2d or 3d,
%   but it should be calculated before this function, then voxelsize_conv is:
% 2D: voxelsizeX * voxelsizeY
% 3D: voxelsizeX * voxelsizeY * voxelsizeZ

% [BW,S,CC] = app_celltracks_F2_create_CC(BW,I, filter) % old
% Filter is the filter up, by default the min is 1 pixel
%% Create the CC and S structure, with a filtering of 1 to 80 cc
CC = bwconncomp(BW); % Black and white connective component
%% Only 2d
if isa(I,'logical')
    % only the BW is given
    if numel(size(BW)) == 2
        S = regionprops(CC,...
            'Area','Eccentricity','centroid','EquivDiameter',...
            'Image','BoundingBox');
    elseif numel(size(BW)) == 3
        S = regionprops3(CC,...
            'Volume','Centroid','Image','BoundingBox','VoxelList','SurfaceArea');
        S = table2struct(S);

    end
else
    if numel(size(BW)) == 2
        S = regionprops(CC,I,'PixelValues','MeanIntensity',...
            'Area','Eccentricity','centroid','EquivDiameter',...
            'Image','BoundingBox','PixelList');
        %% 3d
    elseif numel(size(BW)) == 3

        S = regionprops3(CC,I,'VoxelValues','MeanIntensity',...
            'Volume','Centroid',...
            'Image','BoundingBox','VoxelList','SurfaceArea');
        S = table2struct(S);
    end
end

%% Small check
% if the filtering remove everything, at least check and leave the bigger cc
%% 2019-09-13 Update,
% Check if I really need this filtering
% [maxi,~] = max([S.Area]);
% clean_top = 40;
% if ~isempty(maxi)
%     if clean_top >= maxi && maxi > 10
%         clean_top = maxi - 1 ;
%     end
% end
%% OLD 2020-09-29
% % if exist('filter','var') == true
% %     if numel(size(BW)) == 2
% %         [S,CC] = filter_by_size(S,CC,1,filter);
% %     elseif numel(size(BW)) == 3
% %         [S,CC] = filter_by_size_3d(S,CC,1,filter);
% %     end
% %     BW = ismember(labelmatrix(CC), 1:CC.NumObjects);
% % else
% %     % Do nothing
% % end
%% NEW 2020-09-29
if exist('filter','var') == 0
    % Do nothing, no filtering
else
    %% NEW
    if numel(size(BW)) == 2
        filter_um = pi * filter^2; % filter is the radius in um
        filter_px = filter_um/voxelsize_conv;
    elseif numel(size(BW)) == 3
        filter_um = (4/3) * pi * filter^3;
        filter_px = filter_um/voxelsize_conv;
    end

    if filter_px == 0
        % Basically this means no filtering!
        filter_px = 2;
    end
    if exist('type','var') == 0
        % By default when you forget tospecify, always go from down, otherwise
        % its a mess!
        type = 'down';
    else
        % Nothing
    end
    switch type
        case 'down'
            size_down = 1;
            size_up = filter_px;
        case 'up'
            size_down = filter_px;
            if numel(size(BW)) == 2
                size_up = max([S.Area]);
            elseif numel(size(BW)) == 3
                size_up = max([S.Volume]);
            end
        otherwise
            update_logs(app,'filtering not working, error');
            error('Filtering not working');
    end
    if numel(size(BW)) == 2
        [S,CC] = filter_by_size(S,CC, size_down, size_up);
    elseif numel(size(BW)) == 3
        [S,CC] = filter_by_size_3d(S,CC, size_down, size_up);
    end
    BW = ismember(labelmatrix(CC), 1:CC.NumObjects);
end

end