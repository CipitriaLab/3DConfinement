function logs_to_update = update_logs(app,msg)
date_now = strsplit(datestr(datetime('now','Format','HH:mm:ss')),' ');
date_now = date_now{2};
logs_to_update = char(strcat(date_now,':',{' '}, msg));

%% old with new text going down and we do not see it
%             app.logs.Items{1,length(app.logs.Items)+1} = logs_to_update;
%             app.logs.Value = app.logs.Items{1,length(app.logs.Items)};
%% New with text always first row
try
    if ~isempty(app)
        app.logs.Items = [logs_to_update, app.logs.Items];
        app.logs.Value = app.logs.Items{1,1};
        pause(0.001);
    else
        if isempty(app) % then it is normal to not have a log item.
        else
            disp('No logs item found, so display in the main command line');
        end
        disp(logs_to_update);
    end
catch
    if isempty(app) % then it is normal to not have a log item.
    else
        disp('No logs item found, so display in the main command line');
    end
    disp(logs_to_update);
end

end