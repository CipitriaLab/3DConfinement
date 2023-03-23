function [BW_r_all,BW_g_all,BW_phase_all] = counting_treshold_images(path_images,sample_name,I_r_all,I_g_all,I_phase_all,tresh_method)

N_r = length(I_r_all);
N_g = length(I_g_all);
BW_r_all = cell(size(I_r_all)); % Black and White treshold images
BW_g_all = cell(size(I_g_all));
BW_phase_all = cell(size(I_g_all));

if N_r~=N_g
    error('The channels red and green does not have the same length, check data please');
end
data_tresh_name = strcat(path_images,sample_name,'-data_and_tresh-',tresh_method,'.mat');
ex_data_tresh = exist(data_tresh_name,'file');
idx_to_remove=[];

switch ex_data_tresh
    case 0
        switch tresh_method
            case 'default'
                tresh_r = NaN(length(I_r_all),1);
                tresh_g = NaN(length(I_g_all),1);
                for k = 1 : N_r
                    BW_r_all{k} = imbinarize(I_r_all{k}); % Binarize with tresh_r value
                    BW_g_all{k} = imbinarize(I_g_all{k}); % Binarize with tresh_g value
                    tresh_r(k)=graythresh(I_r_all{k});
                    tresh_g(k)=graythresh(I_g_all{k});
                    if tresh_r(k)==0
                        idx_to_remove = [idx_to_remove, k];
                    end
                end
                
                
            case 'adapt'
                tresh_r = cell(length(I_r_all),1);
                tresh_g = cell(length(I_g_all),1);
                tresh_phase = cell(length(I_phase_all),1);
                for k = 1 : N_r
                    
                    tresh_r{k}=adaptthresh(I_r_all{k},0.4);
                    tresh_g{k}=adaptthresh(I_g_all{k},0.4);
                    tresh_phase{k} = adaptthresh(I_phase_all{k},0.4);
                    BW_r_all{k} = imbinarize(I_r_all{k},tresh_r{k});
                    BW_g_all{k} = imbinarize(I_g_all{k},tresh_g{k});
                    BW_phase_all{k} = imbinarize(I_phase_all{k},tresh_phase{k});
                    
                    if all(tresh_r{k}(:)==0)
                        idx_to_remove = [idx_to_remove,k];
                    end
                end
                
                
        end
        tresh_r(idx_to_remove)=[];
        tresh_g(idx_to_remove)=[];
        tresh_phase(idx_to_remove)=[];
        BW_r_all(idx_to_remove)=[];
        BW_g_all(idx_to_remove)=[];
        BW_phase_all(idx_to_remove)=[];
        tStart = tic;
        fprintf('Starting saving the tresholed images... \n');
        save(data_tresh_name,'BW_r_all','BW_g_all','BW_phase_all','-v7.3');
        tElapsed = toc(tStart);
        fprintf('Saving threshold images done. Time elapsed: ');cprintf('_red','%0.3f s\n',tElapsed);
        
    otherwise
        load(data_tresh_name,'BW_r_all','BW_g_all','BW_phase_all');
        
end
end