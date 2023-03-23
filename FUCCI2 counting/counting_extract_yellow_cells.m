function nb_yellow = counting_extract_yellow_cells(S_g,S_r)

S_g_cell = struct2cell(S_g)';
position_g = floor(cell2mat(S_g_cell(:,2)));

S_r_cell = struct2cell(S_r)';
position_r = floor(cell2mat(S_r_cell(:,2)));
N = min(length(position_g),length(position_r));
idx_match = zeros(N,1);

if length(position_g)>length(position_r)
    for k = 1 : N
        if k>size(position_g,1)
            break
        end
        if ismember(position_r(k,1),position_g(:,1))...
                || ismember(position_r(k,1)-1,position_g(:,1)) || ismember(position_r(k,1)+1,position_g(:,1))||...
                ismember(position_r(k,1)-2,position_g(:,1)) || ismember(position_r(k,1)+2,position_g(:,1))
            idx_x_match = find(abs(position_r(k,1)-position_g(:,1))<3);
            if isempty(idx_x_match)
                continue
            else
                
                if ~(ismember(position_r(k,2),position_g(idx_x_match,2))...
                        || ismember(position_r(k,2)-1,position_g(idx_x_match,2)) || ismember(position_r(k,2)+1,position_g(idx_x_match,2))||...
                        ismember(position_r(k,2)-2,position_g(idx_x_match,2)) || ismember(position_r(k,2)+2,position_g(idx_x_match,2)))
                    continue
                else
                    idx_match(k) = 1 ;
                end
            end
        else
            continue
        end
    end
else
    for k = 1 : N
        if k>size(position_g,1)
            break
        end
        if ismember(position_g(k,1),position_r(:,1))...
                || ismember(position_g(k,1)-1,position_r(:,1)) || ismember(position_g(k,1)+1,position_r(:,1))||...
                ismember(position_g(k,1)-2,position_r(:,1)) || ismember(position_g(k,1)+2,position_r(:,1))
            idx_x_match = find(abs(position_g(k,1)-position_r(:,1))<3);
            if isempty(idx_x_match)
                continue
            else
                if ~(ismember(position_g(k,2),position_r(idx_x_match,2))...
                        || ismember(position_g(k,2)-1,position_r(idx_x_match,2)) || ismember(position_g(k,2)+1,position_r(idx_x_match,2))||...
                        ismember(position_g(k,2)-2,position_r(idx_x_match,2)) || ismember(position_g(k,2)+2,position_r(idx_x_match,2)))
                    continue
                else
                    idx_match(k) = 1 ;
                end
            end
        else
            continue
        end
    end
end

nb_yellow = numel(find(idx_match==1));

end