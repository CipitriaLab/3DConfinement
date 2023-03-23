function date_out = date_get_str(limits, varargin)
% date_out = date_get_str(limits, varargin)
% Example: date_get_str('day', datevec(new_day));
% limits are 'year'
%            'month'
%            'day'
%            'hour'
%            'minute'
%            'second'
if isempty(varargin)
    c = clock; % get the timer from computer;
else
    c = varargin{1};
end
switch limits
    case 'year'
        n_lim = 1;
    case 'month'
        n_lim = 2;
    case 'day'
        n_lim = 3;
    case 'hour'
        n_lim = 4;
    case 'minute'
        n_lim = 5;
    case 'second'
        n_lim = 6;
end
date_out = [];
for kk = 1 : n_lim
    if kk == 1
        date_out = strcat(num2str(c(kk)));
        
    elseif kk == 5
        tmp_to_add = num2str(c(kk));
        if numel(tmp_to_add) == 1
            tmp_to_add = ['0', tmp_to_add];
        end
        date_out = strcat(date_out, 'h',tmp_to_add);
    elseif kk == 6
        tmp_to_add = num2str(c(kk));
        if numel(tmp_to_add) == 1
            tmp_to_add = ['0', tmp_to_add];
        end
        date_out = strcat(date_out, 'min',tmp_to_add);
    else
        tmp_to_add = num2str(c(kk));
        if numel(tmp_to_add) == 1
            tmp_to_add = ['0', tmp_to_add];
        end
        if kk == 4
            date_out = char(strcat(date_out," ",tmp_to_add));
        else
            date_out = strcat(date_out, '-',tmp_to_add);
        end
    end
    
end
% date_out = strcat(num2str(c(1)),'-',num2str(c(2)),'-',num2str(c(3)),'-',num2str(c(4)),'h',num2str(c(5)));



end