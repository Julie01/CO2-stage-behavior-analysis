
%assigns behavioral parameters or number of animals to binned positions in
%the gradient arena and saves
%it

 clearvars -except rois avis files folders fo

% ---for any avi movies:---
home=cd;
als_folder=dir('*analysis*');
avis=dir('*.avi');


%%%%things to edit:%%%
dim=[1600 1600]%input('Video dimensions XY?');
binsize=62; % how many pixels per bin (64 = 1 mm in HR movies)
frame_number=18000;
timebin1=10; %video frmae rate--> 1 s bins
timebin2=5; % total time bin in sec


for Movie=1:length(avis)
    Movie
    display( strcat('...current file...',avis(Movie).name))  
    
    %find and load als file

    files= dir('*JR_als.mat');
    load (files(Movie).name);
    
    %% ---(1)get all XY positions and behavior events for X frames
    clearvars -except folders home als_folder fname Tracks roi oroi rois binsize HMnorm_batch HM_batch SpeedM_batch ...
        angSpeedM_batch Movie files avis index timebin1 timebin2 frame_number dim
    cc=1;
    display ('...gather paths of worms')
    for frame=1:timebin1:frame_number %  nr of frames in the video
        XYpos1=NaN(1,2);
        XYspeed1=NaN(1,1);
        XYangSpeed1=NaN(1,1);
        c=1;
        for i=1:length(Tracks)
            sf = ismember(Tracks(1,i).Frames, frame);
            if sum(sf)>0;
                gf=find(sf>0);
                XYpos1(c,1:2)=round(Tracks(1,i).Path(gf,:)*10)/10;
                XYspeed1(c,1)=Tracks(1,i).Speed(gf);
                c=c+1;
                if gf<= length(abs(Tracks(1,i).AngSpeed))
                XYangSpeed1(c,1)=abs(Tracks(1,i).AngSpeed(gf));
                end

                
            end
        end
        XYpos{cc}=XYpos1;
        XYspeed{cc}=XYspeed1;
        XYangSpeed{cc}=XYangSpeed1;
        cc=cc+1;
        
        if mod(frame,1+timebin1*10)==0
            disp(['frame..' num2str(frame)])
        end
    end
    
    %% ---put them into bins----
    display ('...bin')
   
    c=0;
    for kk=1:timebin2:length(XYpos)
        
        c=c+1;
        XYbin=[];
        XYspeedbin=[];
        XYangSpeedbin=[];
        XYbinC=[];
        for k=kk:kk+timebin2-1
            clear XYbin1
            XY=(XYpos{1,k});
            XYs=(XYspeed{1,k});
            XYas=(XYangSpeed{1,k});
            XY=XY/binsize;
            XYbin1=ceil(XY);
            XYbin=vertcat(XYbin,XYbin1);
            XYspeedbin=vertcat(XYspeedbin,XYs);
            XYangSpeedbin=vertcat(XYangSpeedbin,XYas);
        end
        
        M=zeros([ceil(dim(1)/62),ceil(dim(2)/62)]);
        m=zeros(1,length(XYbinC));
        for a=1:ceil(dim(1)/62)
            for b=1:ceil(dim(2)/62)
                
                m=find(XYbin(:,1)==a & XYbin(:,2)==b);
                M(b,a)=length(m);
                SpeedM(b,a)=sum(XYspeedbin(m))/length(m);
                try
                angSpeedM(b,a)=sum(XYangSpeedbin(m))/length(m);
                end
            end
        end
       M_norm=M/sum(sum(M)/100);
        HM_all(:,:,c)=M;
        HMnorm_all(:,:,c)=M_norm;
        SpeedM_all(:,:,c)=SpeedM;
        angSpeedM_all(:,:,c)=angSpeedM;
        
    end
    HM_batch{Movie}=HM_all;
    HMnorm_batch{Movie}=HMnorm_all;
    SpeedM_batch{Movie}=SpeedM_all;
    angSpeedM_batch{Movie}=angSpeedM_all;
    
  cd(home)  
    
end

%% put all data into analysis folder:
d= strfind(cd, '\');
nd=(cd);
name=nd(d(end)+1:end);
mkdir(strcat(name,'_profile_analysis'));
cd(strcat(name,'_profile_analysis'));
display('...save')
save HM_batch HM_batch
save HMnorm_batch HMnorm_batch
save SpeedM_batch SpeedM_batch
save angSpeedM_batch angSpeedM_batch






