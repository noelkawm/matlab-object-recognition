clear all;
close all;
clc;

videoObj = VideoReader("taskEvideoNoGoal.mp4");% VideoReader to read frames of video
newVideo = VideoWriter("taskFvideoNoGoal", 'MPEG-4');
%VideoWriter for saving created frames of a video
open(newVideo);%Openning VideoWriter object for wrtiting

frameRate = videoObj.FrameRate;

scale = 1/videoObj.Width;

oldCenters = [];
%Array saving previous Center of a ball

while hasFrame(videoObj)
    vidFrame = readFrame(videoObj, "native");
    %Capture new frame of video in native resolution

    treshFrame = vidFrame(:,:,1) > 90 & ...
        vidFrame(:,:,2) > 90 & vidFrame(:,:,3) < 50;
    %Thresholding frame to leave only ball pixels on

    se = strel('disk',30);
    closeBW = imclose(treshFrame,se);
    %Doing morphological closing on thresholding

    [centersBright, radiiBright] = imfindcircles(closeBW,[20 1000], ...
        'ObjectPolarity','bright', "Sensitivity",0.9);
    %Finding a centre of a ball
    
    haveCircles = isempty(centersBright);
    %Checking if there's a circles on current frame

    if haveCircles == 0

        centersBright = centersBright(1:1,:); 
        radiiBright = radiiBright(1:1);

        if ~isempty(oldCenters)
            velocityPixel = sqrt(sum((centersBright-oldCenters).^2));
            velocity = velocityPixel * frameRate * scale * 10;
        else
            velocityPixel = 0;
            velocity = 0;
        end
        %end if
        %If there is a previous information about ball centre calculating
        %velocity

        oldCenters = centersBright;
        %updating ball centres

    else
        velocity = 0;
        %If there's no ball information putting velocity to 0
    end
    %end if

    velocityText = ['Speed: ', num2str(velocity, '%.2f'), ' cm/s'];
    vidFrame = insertText(vidFrame, [20 20], velocityText, ...
        'FontSize', 14, 'TextColor', 'red', 'BoxColor', 'green');
    %Adding a speed information onto a frame

    imshow(vidFrame,[]);

    writeVideo(newVideo,vidFrame);
    %Adding frame into a video
end
%end while

clear videoObj;%Clearing Video Reader object
close(newVideo);%Closing VideoWriter object for writing
