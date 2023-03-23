function [RGB,S,S_m] = counting_find_color_cell_new(I,BW,color,mode)


I_full = uint8(zeros([size(I),3]));

CC= bwconncomp(BW); % Black and white connective component 
S = regionprops(CC,'Area','PixelIdxList','PixelList','centroid','EquivDiameter','Image','BoundingBox');
[S,CC] = filter_by_size(S,CC,1,150);
BW1 = ismember(labelmatrix(CC), 1:CC.NumObjects);
switch color
    case 'red'
        switch mode
            case 'bin'
                I_full(:,:,1) = uint8(imadjust(I,stretchlim(I),[]).*uint8(BW1));
            case 'overlay'
                I_full(:,:,1) = uint8(imadjust(I,stretchlim(I),[]));
                I_full = uint8(imoverlay(I_full,BW1,'black'));
        end
    case 'green'
        switch mode
            case 'bin'
                I_full(:,:,2) = uint8(imadjust(I,stretchlim(I),[]).*uint8(BW1));
            case 'overlay'
                I_full(:,:,2) = uint8(imadjust(I,stretchlim(I),[]));
                I_full = uint16(imoverlay(I_full,BW1,'black'));
        end
end

% figure;imshowpair(BW1,I,'montage');
% figure;imshowpair(BW1,I);
% figure;imshow(imoverlay(I,BW1,'red'));
if isempty(S)
    RGB =I_full;
    S_cell=0;
    S_m=0;
else
    
    S_cell = struct2cell(S)';
    %% Need computer system vision for position
    position = cell2mat(S_cell(:,2));
    S_m = regionprops(CC,I,'PixelValues','MeanIntensity','MaxIntensity','MinIntensity');
    
    %% Need computer system vision for S_m_cell;
    % IF NOT COMPUTER THEN 
    RGB = I_full;
%     S_m_cell = struct2cell(S_m)';
%     [S(:).PixelValues] = S_m.PixelValues;
%     [S(:).MeanIntensity] = S_m.MeanIntensity;
%     
%     
%     
    %% Need computer system vision !!
%     if CC.NumObjects == 0  
%         RGB = I_full;
%     elseif CC.NumObjects < 200 
%         for kk = 1 : length(S_m_cell)
%             if kk ==1
%                 RGB = insertText(I_full,position(kk,:),floor(S_m_cell{kk,2}),'TextColor',color(1),'BoxOpacity',0);
%             else
%                 RGB = insertText(RGB,position(kk,:),floor(S_m_cell{kk,2}),'TextColor',color(1),'BoxOpacity',0);
%             end
%         end
%     else
%         RGB = I_full;
%     end
%     
%         RGB= I_full;
end
end

