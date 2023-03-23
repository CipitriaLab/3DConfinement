function counting_make_video_SO(path,merge_total_all,sample_name,fps)

% From a folder wich contains tif images, creater a video with a banner
% with the time 
%% TIME STEP 15 minute here 
disp('Take care, the default time step is 15 minutes in this function');
x = 0:15:15*length(merge_total_all);
x=x./60; % In hours

video_files = path;
SrcFiles_video = dir(strcat(video_files,'*.tif'));
if isempty(SrcFiles_video)
    error('There was no images to create a movie from');
end
video_name = strcat(path,sample_name,'.avi');
writerObj = VideoWriter(video_name);
writerObj.FrameRate = fps;
open(writerObj);

width_to_add = 80;
size_frame = [width_to_add,size(merge_total_all{1},2),3];
framed_sup = ones(size_frame).*255;
dim = [width_to_add, size_frame(2)];
tStart = tic;
fprintf('Creating video...\n');
for ii = 1 : size(SrcFiles_video,1)
    %% If computer system toolbox not here 
    F = im2frame(merge_total_all{ii});
    writeVideo(writerObj, F);
    
    %% ELSE
%     counter = strcat('T = ',{' '},num2str(x(ii)),' h');
%     RGB = insertText(framed_sup,[0.5*dim(2),0.5*dim(1)],...
%     {sample_name},'FontSize',width_to_add-5,'BoxColor',[1 1 1],'BoxOpacity',0,...
%     'AnchorPoint','Center');
%     RGB = insertText(RGB,[1*dim(2),0.5*dim(1)],...
%     counter,'FontSize',width_to_add-5,'BoxColor',[1 1 1],'BoxOpacity',0,...
%     'AnchorPoint','RightCenter');
%     I_framed = [RGB;merge_total_all{ii}];
%     F = im2frame(I_framed);
%     writeVideo(writerObj, F);
    
end
tElapsed = toc(tStart);
fprintf('Creation video done. Time elapsed: ');cprintf('_red','%0.3f s\n',tElapsed);

% close the writer object
close(writerObj);
% implay(video_name);

end

