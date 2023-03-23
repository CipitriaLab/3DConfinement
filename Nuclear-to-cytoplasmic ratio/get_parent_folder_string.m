function path_out = get_parent_folder_string(path_to_check,generation)
n = numel(generation);
path_to_check = path2clean(path_to_check);
C = strsplit(path_to_check ,'/');
nb_element = size(C,2);
if nb_element - generation < 1
    error('You are trying to get too far away in the tree, lower the generation input');
end
if n == 1
    path_out =  C{1,nb_element - generation};
else
    
end
% idx_sep = find(path_to_check == '/');
% % for ii = 1 : 2 : numel(idx_sep)
% path_out = path_to_check(idx_sep(end - generation) +1 : idx_sep(end-generation +1) - 1);
% end



end