function varargout = display_progress(stop,step,current,func_name)


k = current ;
start  = 1 ;
N = stop ;
check_is_member = ismember(step,[2 3 4]);
switch check_is_member
    case 1
    otherwise
        error('Problem:display_progress:The step is not 2,3 or 4');
end

switch step 
    case 2
        if k == floor((stop-start+1)/2) || k == stop-start+1 
            date_now = strsplit(datestr(datetime('now','Format','HH:mm:ss')),' ');
            date_now = date_now{2};
            msg = [func_name num2str(k/N*100,2) '%'];
            progress = char(strcat(date_now,':',{' '}, msg));
            disp(progress);
        else
           return
        end
    case 3
        if k == floor((stop-start+1)/3) || k == floor((stop-start+1)*2/3) || k == stop-start+1 
            date_now = strsplit(datestr(datetime('now','Format','HH:mm:ss')),' ');
            date_now = date_now{2};
            msg = [func_name num2str(k/N*100,2) '%'];
            progress = char(strcat(date_now,':',{' '}, msg));
            disp(progress);
        else
           return
        end
    case 4
       
        if k == floor((stop-start+1)/4) || k == floor((stop-start+1)/2) || k == floor((stop-start+1)*3/4) || k == stop-start+1 
            date_now = strsplit(datestr(datetime('now','Format','HH:mm:ss')),' ');
            date_now = date_now{2};
            msg = [func_name num2str(k/N*100,3) '%'];
            progress = char(strcat(date_now,':',{' '}, msg));
            disp(progress);
        else
           return
        end
end

varargout{1} = progress;

end