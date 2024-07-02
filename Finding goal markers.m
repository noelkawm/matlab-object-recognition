clear all;
close all;
clc;

videoObj = VideoReader("taskDvideoNoGoal.mp4");% VideoReader to read frames of video
newVideo = VideoWriter("C:/Users/theno/Downloads/Image processing/taskEvideoNoGoal", 'MPEG-4');
%VideoWriter for saving created frames of a video
open(newVideo);%Openning VideoWriter object for wrtiting

interval = [1 0 1;0 1 0;1 0 1];%hitandmiss matrix

positionsY = [-1 -1];%array to save markers X positions
positionsX = [-1 -1];%array to save markers Y positions

while hasFrame(videoObj)
    vidFrame = readFrame(videoObj, "native");
    %Capture new frame of video in native resolution

    if positionsX(1) == -1

        treshFrame = vidFrame;
    
        treshFrame(:,1:size(treshFrame,2:2)/4 * 3,:) = 255;
    
        treshFrame = treshFrame(:,:,1) < 50 & ...
            treshFrame(:,:,2) < 50 & treshFrame(:,:,3) < 50;
        %Thresholding the image to find markers

        se = strel('disk',1);
        closeBW = imclose(treshFrame,se);
        %Doing morphological closing on threshloded frame
    
        bw = bwhitmiss(closeBW,interval);
        %Doing hit and miss operation to find positions that could be
        %center of a marker
    
        [rows, col] = max(bw,[],2);
        %Finding first one in every row 
    
        positionsX = find(rows);%Finding actual X positions of marker
        positionsY = col(positionsX);%Finding actual Y positions of marker

        positionsY = [positionsY(1) positionsY(end)];
        %Taking 1 Y position of each marker
        positionsX = [positionsX(1) positionsX(end)];
        %Taking 1 X position of each marker
    end
    %end if
    
    hold on;
    imshow(vidFrame);
    line(positionsY, positionsX,'Color','red','LineStyle','--','LineWidth', 3);
    %Drawing a line on axis between markers

    axscreenshot = frame2im(getframe(gca));%Getting a screenshot on axis
    writeVideo(newVideo,axscreenshot);%Adding image to video


    hold off;
end
%end while

clear videoObj;%Clearing Video Reader object
close(newVideo);%Closing VideoWriter object for writing