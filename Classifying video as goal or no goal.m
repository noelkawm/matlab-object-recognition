clear all;
close all;
clc;

videoObj = VideoReader("nogoal.mp4");% VideoReader to read frames of video
newVideo = VideoWriter("C:/Users/theno/Downloads/Image processing/taskGvideoNoGoal", 'MPEG-4');
%VideoWriter for saving created frames of a video
open(newVideo);%Openning VideoWriter object for wrtiting

frameRate = videoObj.FrameRate;

scale = 1/videoObj.Width;

oldCenters = [];
%Array saving previous Center of a ball

interval = [1 0 1;0 1 0;1 0 1];%hitandmiss matrix

positionsY = [-1 -1];%array to save markers X positions
positionsX = [-1 -1];%array to save markers Y positions

goalFlag = 0;%Variable that says if a goal happend

while hasFrame(videoObj)
    vidFrame = readFrame(videoObj, "native");
    %Capture new frame of video in native resolution

    treshFrame = vidFrame(:,:,1) > 90 & ...
        vidFrame(:,:,2) > 90 & vidFrame(:,:,3) < 50;
    %Thresholding frame to leave only ball pixels on

    se = strel('disk',30);
    closeBW = imclose(treshFrame,se);
    %Doing morphological closing on thresholding

    [centersBright, radiiBright] = imfindcircles(closeBW,[20 1000] , ...
        'ObjectPolarity','bright', "Sensitivity",0.9);
    %Finding a centre of a ball
    
    haveCircles = isempty(centersBright);
    %Checking if there's a circles on current frame

    if positionsX(1) == -1

        treshFrame1 = vidFrame;
    
        treshFrame1(:,1:size(treshFrame1,2:2)/4 * 3,:) = 255;
    
        treshFrame1 = treshFrame1(:,:,1) < 50 & ...
            treshFrame1(:,:,2) < 50 & treshFrame1(:,:,3) < 50;
        %Thresholding the image to find markers

        se = strel('disk',1);
        closeBW1 = imclose(treshFrame1,se);
        %Doing morphological closing on threshloded frame
    
        bw = bwhitmiss(closeBW1,interval);
        %Doing hit and miss operation to find positions that could be
        %center of a marker
    
        [rows, col] = max(bw,[],2);%Finding first one in every row 
    
        positionsX = find(rows);%Finding actual X positions of marker
        positionsY = col(positionsX);%Finding actual Y positions of marker

        positionsY = [positionsY(1) positionsY(end)];
        %Taking 1 Y position of each marker
        positionsX = [positionsX(1) positionsX(end)];
        %Taking 1 X position of each marker
    end
    %end if

    if haveCircles == 0
        centersBright = round(centersBright(1:1,:)); 
        radiiBright = round(radiiBright(1:1));
        goalFlag = checkTheGoal(positionsX,positionsY,centersBright);
        %Checking if we got a Goal

        vidFrame = insertShape(vidFrame,"circle",[centersBright(1) ...
            centersBright(2) round(radiiBright(1))],...
            LineWidth=5,ShapeColor=["red"]);
        %If there's a circle we creating a marker around it

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
    end
    %end if

    if goalFlag == 1
        vidFrame = insertText(vidFrame, [300 20], "GOAL!!!", ...
            'FontSize', 50, 'TextColor', 'red', 'BoxColor', 'white');
        %Adding a GOAL!!! information onto a frame
    end
    %end if

    velocityText = ['Speed: ', num2str(velocity, '%.2f'), ' cm/s'];
    vidFrame = insertText(vidFrame, [20 20], velocityText, ...
        'FontSize', 14, 'TextColor', 'red', 'BoxColor', 'green');
    %Adding a speed information onto a frame

    imshow(vidFrame,[]);

    line(positionsY, positionsX,'Color','red','LineStyle','--','LineWidth', 3);
    %Drawing a line on axis between markers
    
    axscreenshot = frame2im(getframe(gca));%Getting a screenshot on axis
    writeVideo(newVideo,axscreenshot);%Adding image to video
end
%end while

clear videoObj;%Clearing Video Reader object
close(newVideo);%Closing VideoWriter object for writing


function answer = checkTheGoal(positionX,positionY,center)
    answer = (positionX(1) < center(2)) & (positionX(2) > center(2)) ...
        & (positionY(1) < center(1)) & (positionY(2) < center(1));
end
%end function