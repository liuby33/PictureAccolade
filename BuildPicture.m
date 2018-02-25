load('Database.mat');

%Setup hyperparameters
roughness=120; %Determines how detailed the output is desired to be.
m=1080/roughness; %Determined by the target image's original size. If the target image is 1920x1080, it should be 1080 here.
n=1920/roughness; %Determined by the target image's original size. If the target image is 1920x1080, it should be 1920 here.
%The target image should be resized to (x*y) where x:y=16:9 and roughness must be chosen such that m and n are integers.
sizeY=2160/roughness; %Determined by the result image's desired size. If the result is desired to be 3840x2160, put 2160 here.
sizeX=3840/roughness; %Determined by the result image's desired size. If the result is desired to be 3840x2160, put 3840 here.
targetLocation='19201080TargetImage.jpg';
resultingPic_Name='tempRP.jpg';
%Setup hyperparameters complete.

target=imread(targetLocation);
%Read target picture.

picPool_compressed=struct('cdata',zeros(m,n,3,'uint8'),'colormap',[]);
%Declare struct for storing compressed frames for comparison.
for i=1:numTotalPictures
    picPool_compressed(i).cdata=imresize(picPool(i).cdata,[m,n]);
    if ~rem(i,1000)
        disp(i);
    end
end


targetPic=struct('cdata',zeros(m,n,3,'uint8'),'colormap',[]);
for i=1:roughness
    for j=1:roughness
        targetPic(i,j).cdata=target(((i-1)*m+1):(i*m),((j-1)*n+1):(j*n),:);
        %Reconstruct the target picture into roughness*roughness matrix of
        %m*n*3 pictures.
    end
end

disp('Target picture dissection completed.');

k_temp=zeros(roughness,roughness);

pic1=zeros(m,n,3,numTotalPictures);
for k=1:numTotalPictures
    pic1(:,:,:,k)=picPool_compressed(k).cdata;
    %Reconstruct all compressed frames into one matrix with dimension m by 
    %n by 3 by numTotalPictures.
end
pic1=double(pic1);

diff_temp=zeros((roughness*roughness),1);
for i=1:roughness
    for j=1:roughness
        a=(i-1)*roughness+j;
        tic;
        pic2=repmat(targetPic(i,j).cdata,[1 1 1 numTotalPictures]);
        %Repeat pic 2 by numTotalPictures times and the resulting matrix is
        %m by n by 3 by numTotalPictures.
        pic2=double(pic2);
        diff=sum(sum(sum(((pic1-pic2).^2),1),2),3); %This vectorization allows the computation
        %of total squared error in one run, with output as a
        %numTotalPictures dimension vector. 
        t=toc;
        [diff_temp(a), minLoc]=min(diff);
        %Find minimum total squared error and record the frame ID.
        k_temp(i,j)=minLoc;
        ttemp=t;
        t=t*(roughness*roughness-a)/3600;
        b=strcat(num2str(a),' out of ',num2str(roughness*roughness),' segments finished, spent ',num2str(ttemp),' seconds, still need ',num2str(t),' hours.');
        disp(b);
    end
end

disp('pictures chosen');

mm=sizeY*roughness;
nn=sizeX*roughness;

resultingPic=zeros([mm,nn,3],'uint8');

for i=1:roughness
    for j=1:roughness
        resultingPic((((i-1)*sizeY+1):i*sizeY),((j-1)*sizeX+1):(j*sizeX),:) ...
            =imresize(picPool(k_temp(i,j)).cdata,[sizeY,sizeX]);
    end
end

imwrite(resultingPic,resultingPic_Name);

disp('All operations completed');