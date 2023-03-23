function make_video(varargin)

%% Function to create video from reading images in a folder,
% First argument is the video name output 
% Second argument is the path of the folder where the images are 
% Third argument is the extension 
extension = 'png';
if nargin == 1
    video_name = varargin{1};
    [~,path] = get_old_folder_position([]);
elseif nargin == 2 
    video_name = varargin{1};
    path = varargin{2};
elseif nargin == 3 
    video_name = varargin{1};
    path = varargin{2};
    extension = varargin{3};
end
%% This function takes all imgs with the png extension in the folder selected
% It then create a "avi" movie with all the frames.

SrcFiles_video = dir(strcat(path,'*.',extension));

video_name = strcat(path,video_name,'.avi');
writerObj = VideoWriter(video_name,'Motion JPEG AVI');
v.Quality = 100;
writerObj.FrameRate = 1;
open(writerObj);



for ii = 1 : size(SrcFiles_video,1)
    F = im2frame(imread(strcat(path,SrcFiles_video(ii).name)));
    writeVideo(writerObj, F);  
end

% close the writer object
close(writerObj);
% implay(video_name);

end