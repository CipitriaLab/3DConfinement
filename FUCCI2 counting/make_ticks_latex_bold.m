function ax = make_ticks_latex_bold(ax)
%% Two \ are required, because at first sprintf is applied and then the LaTeX interpreter.
% from https://www.mathworks.com/matlabcentral/answers/406685-ticklabelinterpreter-axis-ticks-bold
% axesH.XAxis.TickLabelFormat      = '\\textbf{%g}';

% if ~isgnu()
% ax.Parent.Renderer = 'painter';
% end
fig = ax.Parent;
%% To have not the exponent format, dont know how tu put it bold at the moment

if isa(ax,'matlab.ui.control.UIAxes')
    ax.TickLabelInterpreter ='tex';
    ax.FontName ='Georgia';
    ax.FontSize = 20;
else
    if ax.YRuler.Exponent ~= 0
        ax.YRuler.Exponent = 0;
    end
    %% Put the line to real black
    ax.XRuler.Color = [0 0 0];
    ax.YRuler.Color = [0 0 0];
    % sometime when plotting certain type of data, the interpreter is changed,
    % so the two first lines ensures it is not happening.
    ax.XAxis.TickLabelInterpreter = 'latex';
    ax.YAxis.TickLabelInterpreter = 'latex';
    % ------------------- OLD --------------------%
    % Does not work when the tick has a number and a letter !
    %% WARNING if categorial is used
    if isa(ax.XAxis, 'matlab.graphics.axis.decorator.CategoricalRuler')
        ax = manual_bold_ticks(ax.XAxis);
        ax = manual_bold_ticks(ax.YAxis);
        %         ax.YAxis.TickLabelFormat  = '\\textbf{%g}';
    else
        
        ax.XAxis.TickLabelFormat  = '\\textbf{%g}';
        ax.YAxis.TickLabelFormat  = '\\textbf{%g}';
        % ------------------- OLD --------------------%
        % ------------------- NEW --------------------% 2019-10-31
        % Not always working because the
        fig = ax.Parent;
        try
            test_bf = ax.XAxis.TickLabels(1);
        catch
            test_bf = '';
        end
        if ~contains(test_bf,'\textbf') && ~contains(test_bf,'\mathbf')
            %     if contains(fig.Name,'Montage')
            if isempty(ax.XAxis.TickLabel)
            else
                tick_cell = cellstr(ax.XAxis.TickLabel);
                ax.XAxis.TickLabel = string(ax.XAxis.TickLabel);
                for tt = 1 : size(ax.XAxis.TickLabel,1)
                    tick_tmp = tick_cell{tt,1};
                    idx_letter = find(isletter(tick_tmp));
                    if isempty(idx_letter) || contains(tick_tmp,'\textbf')
                        continue
                    else
                        % meaning one letter is found in the tick
                        try
                            %                         if iscell(ax.XAxis.TickLabel(tt))
                            %                             str_old = ax.XAxis.TickLabel{tt};
                            %                         end
                            %                         str_new = create_bold_subscript(str_old)
                            ax.XAxis.TickLabel(tt) = cellstr(strcat('\textbf{',tick_cell{tt,1},'}'));
                            %                          ax.XAxis.TickLabel{tt} = str_new;
                        catch
                            ax.XAxis.TickLabel = [];
                            ax.XAxis.TickLabel(tt,:) = char(strcat('\textbf{',tick_cell{tt,1},'}'));
                        end
                    end
                end
            end
        end
        %% To run only with text in y ticks, otherwise it messed up..
        test_bf = ax.YAxis.TickLabels(1);
        if ~contains(test_bf,'\textbf') && ~contains(test_bf,'\mathbf')
            %     if contains(fig.Name,'Montage')
            if isempty(ax.YAxis.TickLabel)
            else
                tick_cell = cellstr(ax.YAxis.TickLabel);
                ax.YAxis.TickLabel = string(ax.YAxis.TickLabel);
                for tt = 1 : size(ax.YAxis.TickLabel,1)
                    tick_tmp = tick_cell{tt,1};
                    idx_letter = find(isletter(tick_tmp));
                    if isempty(idx_letter) || contains(tick_tmp,'\textbf')
                        continue
                    else
                        % meaning one letter is found in the tick
                        if ischar(ax.YAxis.TickLabel)
                            ax.YAxis.TickLabel(tt,:) = [];
                            ax.YAxis.TickLabel(tt,:) = char(strcat('\textbf{',tick_cell{tt,1},'}'));
                        elseif iscell(ax.YAxis.TickLabel)
                            ax.YAxis.TickLabel(tt) = cellstr(strcat('\textbf{',tick_cell{tt,1},'}'));
                        end
                        
                    end
                end
            end
            %------------------- NEW --------------------%
        else
        end
        
    end
    %% Legend
    try
        leg = ax.Legend.String;
        N_l = size(leg,2);
        for ll = 1 : N_l
            old = leg{1,ll};
            if contains(old,'$')
                % Bug in matlab with subscript, so I have to go in math mode
                % But then when putting the mathbf, it remove the italic so
                % perfect !
                idx_find = find(old=='$');
                ax.Legend.String{1,ll} = strcat('$\mathbf{',old(idx_find(1)+1:idx_find(end)-1),'}$');
            else
                ax.Legend.String{1,ll} = strcat('\textbf{',old,'}');
            end
        end
    catch
        %         disp('no legend');
    end
    %% label
    %% X label
    try
        old = ax.XLabel.String;
        if iscell(old)
            for ll = 1 : size(old,1)
                str_new = create_bold_subscript(old{ll,1});
                %                 ax.YLabel.String{ll,1} = strcat('\textbf{',old_y{ll,1},'}');
                ax.XLabel.String{ll,1} = str_new;
            end
        elseif ~isempty(old)
            ax.XLabel.String = create_bold_subscript(old);
        end
        %% Ylabel
        old_y = ax.YLabel.String;
        if iscell(old_y)
            for ll = 1 : size(old_y,1)
                str_new = create_bold_subscript(old_y{ll,1});
                %                 ax.YLabel.String{ll,1} = strcat('\textbf{',old_y{ll,1},'}');
                ax.YLabel.String{ll,1} = str_new;
            end
        elseif ~isempty(old_y)
            %             ax.YLabel.String = strcat('\textbf{',old_y,'}');
            ax.YLabel.String = create_bold_subscript(old_y);
        end
    catch
        disp('no x-y label');
    end
    
    try
        old = ax.Title.String;
        if contains(old, '$')
            % Bug in matlab with subscript, so I have to go in math mode
            % But then when putting the mathbf, it remove the italic so
            % perfect !
            idx_find = find(old=='$');
            ax.Title.String = strcat('$\mathbf{',old(idx_find(1)+1:idx_find(end)-1),'}$');
        else
            if contains(old,'textbf')
                % then dont do anything
            else
                ax.Title.String = strcat('\textbf{',old,'}');
            end
        end
    catch
        disp('no title');
    end
    %% Colorbar
    if ~isempty(findobj(fig,'Tag','Colorbar'))
        hc = findobj(fig,'Tag','Colorbar');
        % could be several colorbar
        nb_color = numel(hc);
        for cc = 1 : nb_color % cc for colorbar
            old = hc(cc).TickLabels;
            nb_ticks = size(old,1);
            new = cell(nb_ticks,1);
            for ll = 1 : nb_ticks
                if contains(old, 'textbf')
                    new{ll,1} = old{ll,1};
                    continue
                else
                    new{ll,1} = strcat('\textbf{',old{ll,1},'}');
                end
            end
            hc(cc).TickLabels = new;
        end
    end
    %% All text in general
    text_all = findobj(fig, 'Type','Text');
    set(text_all, 'Interpreter','latex');
    for kk = 1 : numel(text_all)
        old = text_all(kk).String;
        text_all(kk).String = strcat('\textbf{', latex_check_text(old),'}');
    end
    
    
end
end

function str_new = create_bold_subscript(str)
if contains(str,'$')
    % Bug in matlab with subscript, so I have to go in math mode
    % But then when putting the mathbf, it remove the italic so
    % perfect !
    idx_find = find(str=='$');
    % watch out if there is math and no math together
    %     if idx_find(1) ~= 1
    %         str_new = strcat(str(1:idx_find(1)-1)
    %     else
    str_new = strcat('$\mathbf{',str(idx_find(1)+1:idx_find(end)-1),'}$');
else
    str_new = strcat('\textbf{',str,'}');
end

end

function ax = manual_bold_ticks(ruler)

tick_cell = cellstr(ruler.TickLabel);
for tt = 1 : size(ruler.TickLabel,1)
    tick_tmp = tick_cell{tt,1};
    idx_letter = find(isletter(tick_tmp));
    if contains(tick_tmp,'\textbf')
        continue
    else
        % meaning one letter is found in the tick
        try
            ruler.TickLabel(tt) = cellstr(strcat('\textbf{',tick_cell{tt,1},'}'));
        catch
            ruler.TickLabel = [];
            ruler.TickLabel(tt,:) = char(strcat('\textbf{',tick_cell{tt,1},'}'));
        end
    end
end
ax = ruler.Parent;

end
