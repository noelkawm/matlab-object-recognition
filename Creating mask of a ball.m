clear all;
close all;
clc;

videoObj = VideoReader("nogoal.mp4");% VideoReader to read frames of video
newVideo = VideoWriter("C:/Users/theno/Downloads/Image processing/taskDvideoNoGoal", 'MPEG-4');
%VideoWriter for saving created frames of a video
open(newVideo);%Openning VideoWriter object for wrtiting

while hasFrame(videoObj)
    vidFrame = readFrame(videoObj, "native");
    %Capture new frame of video in native resolution

    treshFrame = vidFrame(:,:,1) > 90 & ...
        vidFrame(:,:,2) > 90 & vidFrame(:,:,3) < 50;
    %Creating binary thresholded frame 

    se = strel('disk',30);
    closeBW = imclose(treshFrame,se);
    %Doing morphological closing on thresholded frame

    [centersBright, radiiBright] = imfindcircles(closeBW,[20 1000], ...
        'ObjectPolarity','bright', "Sensitivity",0.9);
    %Finding all circels in the image
    
    haveCircles = isempty(centersBright);
    %Checking if there's a circles on current frame

    if haveCircles == 0 
        centersBright = centersBright(1:1,:); 
        radiiBright = radiiBright(1:1);
        vidFrame = insertShape(vidFrame,"circle",[centersBright(1)...
            centersBright(2) round(radiiBright(1))],...
            LineWidth=5,ShapeColor=["red"]);
        %If there's a circle we creating a marker around it
    end
    %end if

    imshow(vidFrame,[]);

    writeVideo(newVideo,vidFrame);
    %Adding frame into a video
end
%end while

clear videoObj;%Clearing Video Reader object
close(newVideo);%Closing VideoWriter object for writing