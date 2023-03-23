function [S,CC] = filter_by_size_3d(varargin)

%% Filtering by size of connected component.
% Firstargument is the Structure S
% Second argument is the CC
% third is the min value for filtering
% fourth is the max value
%% If only three arg, the max taken is the maximum value !

if nargin == 4
    S = varargin{1};
    CC = varargin{2};
    min_px = varargin{3} ;
    max_px = varargin{4};
elseif nargin == 3
    S = varargin{1};
    CC = varargin{2};
    min_px = varargin{3};
    max_px = max([S.Volume]);
elseif nargin == 2
    %     BW = varargin{1};
    %     min_px = varargin{2};
    %     CC = bwconncomp(BW);
    %     S = regionprops(BW,'Area');
    %     max_px = max([S.Area]);
end


% [~,index] = sortrows([S.Area].'); S = S(index(end:-1:1)); clear index
if exist('max_px','var') == true
    idx_px_to_remove = [S.Volume] >= min_px & [S.Volume] <= max_px;
    if ~isempty(idx_px_to_remove)
        S(idx_px_to_remove) = [];
        CC.PixelIdxList(idx_px_to_remove) = [];
    else
        
    end
    CC.NumObjects = numel([S.Volume]);
else
    % No filtering!
end
% for k = min_px : max_px
%     idx_px_to_remove = [S.Area] == k;
%     if ~isempty(idx_px_to_remove)
%         S(idx_px_to_remove) = [];
%         CC.PixelIdxList(idx_px_to_remove) = [];
%     else
%         continue
%     end
% end
% CC.NumObjects = numel([S.Area]);

end