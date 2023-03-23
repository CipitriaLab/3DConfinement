function FigHandle = figure2(varargin)
% if isgnu()
%      FigHandle = figure(varargin{:});
%      return
% end
if nargin == 1
    tmp_h = varargin{1};
    if ishghandle(tmp_h,'figure') == true
        % then just bring the focus and nothing else
        figure(varargin{:});
        return;
    end
end
MP = get(0, 'MonitorPositions');
if size(MP, 1) == 1  % Single monitor
    FigH = figure(varargin{:});
elseif size(MP, 1) == 2       % Multiple monitors
    % Catch creation of figure with disabled visibility:
    indexVisible = find(strncmpi(varargin(1:end), 'Vis', 3));
    if ~isempty(indexVisible)
        paramVisible = varargin(indexVisible(end) + 1);
        if strcmp(paramVisible,'on') || strcmp(paramVisible, 'off')
            % then everything is fine, otherwise set default
        else
            paramVisible = get(0, 'DefaultFigureVisible');
        end
        if isa(paramVisible, 'cell')
            paramVisible = char(paramVisible);
        end
    else
        paramVisible = get(0, 'DefaultFigureVisible');
    end
    %
    Shift    = MP(2, 1:2);
    if logical(sum(Shift == [1, 1]))
        % then screen are configured differently and it is not going to work
        % This happen when the second screen is set as"main screen"
        Shift = MP(1, 1:2);
    end
    FigH     = figure(varargin{:}, 'Visible', 'off');
    set(FigH, 'Units', 'pixels');
    pos      = get(FigH, 'Position');
    set(FigH, 'Position', [pos(1:2) + Shift, pos(3:4)], ...
        'Visible', paramVisible);
    %% 2021-01-29 Addition forGNU/Linux computer
    % If the two screen do not have the same  width, one more tst is needed.
    pos      = get(FigH, 'Position'); % [left, bottom, .. , ..];
    new_pos = pos;
    top_c = pos(2) + pos(4);
    top_c_screen = MP(2,4);
    if top_c > top_c_screen
        new_pos(2) = new_pos(2) - 100; % 100 pixels down
    end
    set(FigH, 'Position', new_pos);
else
    % problem somehow
    FigH     = figure(varargin{:});
end
if nargout ~= 0
    FigHandle = FigH;
end