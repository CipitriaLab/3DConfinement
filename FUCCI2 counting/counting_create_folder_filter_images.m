function filter_data_color = counting_create_folder_filter_images(color,storage)

if strfind(storage,'usr')
    filter_data_color = strcat(storage,color,'/');
else
    filter_data_color = strcat(storage,color,'\');
end
ex_filter_images = exist(filter_data_color,'dir');
switch ex_filter_images
    case 0
        mkdir(filter_data_color);
    otherwise
end

end