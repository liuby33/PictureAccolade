%Setup hyperparameters
sizeY=90;
sizeX=160;
workSpace_Name='Database.mat';
%Setup hyperparameters complete.


vid=VideoReader('KIMINONAWA.mp4');
%Create video reader object and load KIMINONAWA.mp4. 

picPool=struct('cdata',zeros(sizeY,sizeX,3,'uint8'),'colormap',[]);
%Declare a struct that contains all the frames as RPG pictures. 

f=0;
while hasFrame(vid)
    f=f+1;
    picPool(f).cdata=imresize(readFrame(vid),[sizeY,sizeX]);
end
numTotalPictures=f;
%Read the whole movie into picPool struct and record the total number of
%frames as numTotalPictures.

save(workSpace_Name,'-V7.3');
%Save the workspace as a file.

disp('Completed reading the movie file and saving workspace.');
