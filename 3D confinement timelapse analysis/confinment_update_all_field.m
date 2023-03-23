function Cells = confinment_update_all_field(imgs,Cells,cell_nb,tmp_file,tt,tmp_old_position)
%%%%%%%%%%%%%%%%%%% TAKE CARE %%%%%%%%%%%%%%%%%%%%%%%%%%
% I changed the function
% In this version Hubert 2019-01-07, the input argument "Cells" will only be one row, with the corresponding cells
% and the function will be called for each cells.

I_r = imgs.I_r;
I_g = imgs.I_g;
I_ph = imgs.I_ph;
load(tmp_file,'cellsize_px','voxelsizeX');

if isempty(Cells(1).Position)
    Cells_ini = load(tmp_file,'Cells');
end

N_cells = size(Cells,2); % 2019-01-07 This will always be one for this version !
if N_cells ~= 1
    error('The function should only by called with a one row Cells structure');
end

for kk = 1 : N_cells
    if tt~=1
        x = tmp_old_position{cell_nb,1}(1,1);
        y = tmp_old_position{cell_nb,1}(1,2);
        posrect_local = [x - cellsize_px/2, ...
            y - cellsize_px/2, ...
            cellsize_px,cellsize_px];
        radii_local = tmp_old_position{cell_nb,2};
    elseif isempty(Cells(1).Position)
        posrect_local = Cells_ini.Cells(cell_nb).posrect;
        radii_local = NaN; % DOes not matter because this is the ini, it should see the cells
        % and will not go into the no cells found case where radii_local is
        % used
    else
        posrect_local = round([Cells(kk).Position(1)-cellsize_px/2,...
            Cells(kk).Position(2)-cellsize_px/2,...
            cellsize_px,...
            cellsize_px]);
        radii_local = NaN; % SAme here
    end
    
    
    [Cells(kk).Position,Cells(kk).posrect,Cell_radii] = adjust_position(posrect_local,imgs,radii_local,tt);
    
    Cells(kk).imgs.mcherry = imcrop(I_r,Cells(kk).posrect);
    Cells(kk).imgs.mvenus = imcrop(I_g,Cells(kk).posrect);
    Cells(kk).imgs.phase = imcrop(I_ph,Cells(kk).posrect);
    %% Debug test
    
%     imshowpair(imcrop(I_ph,posrect_local),Cells(kk).imgs.phase,'montage');
%     pause(0.05);
    %     gray_threshold = graythresh(Cells(kk).imgs.mcherry)
    Cells(kk).BWs.mcherry = imbinarize(Cells(kk).imgs.mcherry);
    Cells(kk).BWs.mvenus = imbinarize(Cells(kk).imgs.mvenus);
    %% Test debug
    %     figure;
    %     imshowpair(Cells(kk).BWs.mcherry,Cells(kk).BWs.mvenus,'montage');
    
    CC_r = bwconncomp(Cells(kk).BWs.mcherry);
    S_r = regionprops(CC_r,Cells(kk).imgs.mcherry,'PixelValues','PixelIdxList');
    
    CC_g = bwconncomp(Cells(kk).BWs.mvenus);
    S_g = regionprops(CC_g,Cells(kk).imgs.mvenus,'PixelValues','PixelIdxList');
    
    Cells(kk).intensity.mcherry = S_r.PixelValues;
    Cells(kk).intensity.mvenus = S_g.PixelValues;
    Cells(kk).focus.mcherry = fmeasure(I_r,'GLLV',Cells(kk).posrect);
    Cells(kk).focus.mvenus = fmeasure(I_g,'GLLV',Cells(kk).posrect);
    Cells(kk).t_sec=[];
    Cells(kk).idx_sharp = [];
    Cells(kk).radii = Cell_radii;
end


end

%% Test of the function with imfindcircle on the phase contrast images
function [position_adjusted,posrect_adjusted,radii_cell] = adjust_position(posrect_local,imgs,radii_local,tt)
I_phase = imcrop(imgs.I_ph,posrect_local);
I_mcherry = imcrop(imgs.I_r,posrect_local);
I_mvenus = imcrop(imgs.I_g,posrect_local);
x_center = size(I_phase,1)/2;
y_center = size(I_phase,2)/2; % they should be the same !
if x_center ~= y_center % This can happen if the selected cell is too much on one edge, to be improved
    disp('The crop image is not square');
end
% voxelsize is um/px
R_min = 5;
R_max = 30 ;

[centers,radii,metrics] = imfindcircles(edge(I_phase,'Canny'),[R_min,R_max],'Sensitivity',0.89,'ObjectPolarity','bright');

%         [centers,radii,metrics] = imfindcircles(I_phase,[R_min,R_max],'Sensitivity',0.92);
%% Debug mode to follow what is happening.
% imshow(I_phase);
% viscircles(centers,radii);

if ~isempty(radii) && numel(radii) == 1
    % By taking the first of the centers, one take he one with the
    % higher metric although it may not be the one in the center...
    % to be improved because it fails. Use of previous radii ?
    idx_good_circle = 1;
    %             imshowpair(I_phase,imcrop(imgs.I_ph,posrect_adjusted));viscircles(centers(1,1:2),radii(1,1));
elseif ~isempty(radii) && numel(radii) > 1
    if tt == 1
        idx_good_circle = 1;
        
    else
        %% Compare intensity in the middle and take the darder
        %                 for rr = 1 : numel(radii)
        %                     intens_middle(rr,1) = I_phase(round(centers(rr,2)),round(centers(rr,1)));
        %                 end
        %                 [min_intens, idx_good_circle] = min(intens_middle);
        %% Other way with radius but fails sometimes
        %                 dist_radd = abs(radii - radii_local);
        %                [min_dist,idx_good_circle] = min(dist_radd);
        %% two previous way are not robust, use fluorescence
        BW_r = imbinarize(I_mcherry);
        CC_r = bwconncomp(BW_r);
        S_r = regionprops(CC_r,BW_r,'Centroid','PixelValues','PixelIdxList','Area');
        BW_g = imbinarize(I_mvenus);
        CC_g = bwconncomp(BW_g);
        S_g = regionprops(CC_g,BW_g,'Centroid','PixelValues','PixelIdxList','Area');
        % First if the cell is mCherry
        if CC_r.NumObjects == 1 && ...
                ~isempty(CC_g) && ...
                CC_g.NumObjects ~= 1
            dist_center = sqrt((S_r.Centroid(1,1)-centers(:,1)).^2 + ...
                (S_r.Centroid(1,2) - centers(:,2)).^2);
            [~,idx_good_circle ] = min(dist_center);
            % Then use the mVenus which is always sure to be there
            % I sort by max area and take the biggest, hoping the nulcei
            % lays here
        elseif size(S_g,1) > 5 && size(S_r,1) > 5 
            % if it is really noisy 
            % Then count on green channel to spot the nuclei, always there
%             [centers_r,radii_r] = imfindcircles(imbinarize(I_mcherry),[R_min,R_max],'Sensitivity',0.9,'ObjectPolarity','bright');
            [centers_g,radii_g] = imfindcircles(imbinarize(I_mvenus),[R_min,R_max],'Sensitivity',0.90,'ObjectPolarity','bright');
            if numel(radii_g) > 1 || isempty(radii_g)  % At this point I dont know how to solve the problem..
                idx_good_circle = 1 ;
            else
            dist_center = sqrt((centers_g(:,1)-centers(:,1)).^2 + ...
                (centers_g(:,2) - centers(:,2)).^2);
            [~,idx_good_circle ] = min(dist_center);
            end
        else
            [~,index] = sortrows([S_g.Area].'); S_g = S_g(index(end:-1:1)); clear index
            dist_center = sqrt((S_g(1,1).Centroid(1,1)-centers(:,1)).^2 + ...
                (S_g(1,1).Centroid(1,2) - centers(:,2)).^2);
            [~,idx_good_circle ] = min(dist_center);
        end
                    
    end
    
else
    idx_good_circle = 1;
    centers = [x_center y_center];
    radii = 0;
    disp('Cells not found');
    
end
shift_x = round(centers(idx_good_circle,1) - x_center);
shift_y = round(centers(idx_good_circle,2) - y_center);
posrect_adjusted = posrect_local;
posrect_adjusted(1) = posrect_adjusted(1) + shift_x;
posrect_adjusted(2) = posrect_adjusted(2) + shift_y;
posrect_adjusted(posrect_adjusted == 0) = 1;
position_adjusted = posrect_adjusted(1,1:2)+posrect_local(3)/2;
radii_cell = radii(idx_good_circle);
end

%% This function fails when the Fucci signal decreases !! 2019-01-17
% function [position_adjusted,posrect_adjusted] = adjust_position(posrect_local,imgs)
%         I_r = imgs.I_r;
%         I_g = imgs.I_g;
%         BW_r_c = imbinarize(imcrop(I_r,posrect_local));
%         BW_g_c = imbinarize(imcrop(I_g,posrect_local));
%         x_center = size(BW_r_c,1)/2;
%         y_center = size(BW_r_c,2)/2; % they should be the same !
%         if x_center ~= y_center
%             error('The crop image is not square');
%         end
%         CC_r_local = bwconncomp(BW_r_c);
%         CC_g_local = bwconncomp(BW_g_c);
%         S_r_local = regionprops(CC_r_local,BW_r_c,'WeightedCentroid','Area');
%         S_g_local= regionprops(CC_g_local,BW_g_c,'WeightedCentroid','Area');
%         [S_r_local,CC_r_local] = filter_by_size(S_r_local,CC_r_local,1,max([S_r_local.Area])-1);
%         [S_g_local,CC_g_local] = filter_by_size(S_g_local,CC_g_local,1,max([S_g_local.Area])-1);
%         if ~isempty([S_r_local.Area]) || ~isempty([S_g_local.Area])
%             %% TAKE CARE: because if there is not much signal, the BW will give something bad and hence the criteria of area is not good !
%             % Indeed, all the image will be full with white pixel, but it
%             % is just noise and not cells !
%             % Suggestion : if area ~ 70 % nb total pixel, take the other
%             % channel ? at 2019-01-17 it is not corrected
%             if max([S_r_local.Area]) > max([S_g_local.Area])
%                 shift_x = round(S_r_local.WeightedCentroid(1) - x_center);
%                 shift_y = round(S_r_local.WeightedCentroid(2) - y_center);
%             else
%                 shift_x = round(S_g_local.WeightedCentroid(1) - x_center);
%                 shift_y = round(S_g_local.WeightedCentroid(2) - y_center);
%             end
%             posrect_local(1) = posrect_local(1) + shift_x;
%             posrect_local(2) = posrect_local(2) + shift_y;
%             posrect_adjusted = posrect_local;
%             position_adjusted = posrect_local(1,1:2)+posrect_local(3)/2;
%
%         else
%             error('Cells not found');
%         end
%
%     end