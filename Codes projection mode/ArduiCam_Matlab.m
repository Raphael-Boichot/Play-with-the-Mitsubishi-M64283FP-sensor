% Raphael BOICHOT 30/01/2023
% for any question : raphael.boichot@gmail.com

clear
clc
close all
disp('-----------------------------------------------------')
disp('|Beware, this code is for Matlab ONLY !!!           |')
disp('|You can break the code with Ctrl+C on Editor Window|')
disp('-----------------------------------------------------')
% pkg load image
% pkg load instrument-control
arduinoObj = serialport("COM6",2000000); %set the Arduino com port here
%set(arduinoObj, 'timeout',-1);
flag=0;
image_counter=0;
image_display=[];
title_reg='Empty';
mkdir ./image
counter=0;
width_output=256;
while flag==0 %infinite loop
    data = readline(arduinoObj);
    if not(length(char(data))>100)
        disp(data);
    end
    if not(isempty(strfind(data,'Exposure')));
        str=char(data);
        title_reg=(str(end-4:end));
    end
    if strlength(data)>64 %This is an image coming
        data=(char(data));
        offset=1; %First byte is always junk (do not know why, probably a Println LF)
        im=[];
        %if length(data)>=16385
        for j=1:1:128
            try
                im(j,1)=hex2dec(data(offset:offset+1));
            catch
                im(j,1)=im(j-1,1);
            end
            offset=offset+3;
        end
        raw=im(2:end); %first line is black output
        image_display=[image_display,raw];
        
        image_counter=image_counter+1;
        [heigth, rows]=size(image_display);
        counter=counter+1;
        if rem(counter, width_output+1)==0
            image_counter=image_counter+1;
            frame=image_display(:,end-width_output:end);
            maximum=max(max(frame));
            minimum=min(min(frame));
            image_storage=uint8(frame-minimum)*(255/(maximum-minimum));
            image_storage=imresize(image_storage,4,"nearest");
            imwrite(image_storage,['./image/output_',num2str(image_counter),'.gif'],'gif');
        end
        if rows<=width_output
            imagesc(image_display)
        else
            imagesc(image_display(:,end-width_output:end))
        end
        title(['Exp. register:', title_reg])
        colormap gray
        drawnow
    end
end
