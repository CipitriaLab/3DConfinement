function text_out = latex_check_text(text)
if isa(text, 'char')
     text_out = latex_check_text_single(text);
else
    % one needs to run this function but in loop
    nb_row = size(text,1);
    text_out = cell(nb_row, 1);
    for kk = 1 : nb_row
    text_out{kk,1} = latex_check_text_single(text{kk,1});
    end
end




end

function text_out = latex_check_text_single(text)
% remove the character totally 
idx_pb = find(text == '´');
if isempty(idx_pb)
else
    text(idx_pb) = [];
end
clear idx_pb;
% Put a \ before the "pb" 
idx_pb = find(text == '_' | text == '%');
if isempty(idx_pb)
    text_out = text;
else
  nb_pb = numel(idx_pb);
    switch nb_pb
        case 1
            text_out = cut_in_two(text,idx_pb(1));
        otherwise
            text_out = text;
            for pp = 1 : nb_pb 
                if pp == 1
                text_out = cut_in_two(text,idx_pb(pp));
                else
                    idx_pb(pp) =  idx_pb(pp) + pp - 1 ;
                    text_out = cut_in_two(text_out,idx_pb(pp));
                end
            end
            
    end

end

end
function out = cut_in_two(text,idx)

    %% This is the case when only idx is one number 
out = strcat(text( 1 : idx(1) - 1),'\',...
                              text(idx(1):end));
end