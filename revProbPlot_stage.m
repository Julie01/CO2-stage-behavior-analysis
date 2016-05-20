%% weathervaning hist
% use on runinfo files
%  figure
clear
warning off;
CC=1;
CM= jet(30);
bintype=1; % bin for dC/dT(2) or bearing(1)

for delay=9

%plot?
plotting=1;
files =dir('*revinfo*');

%parameters:
if bintype==1
    first=0;
    last=180;
    binsize=20;
else
    first=-0.13;
    last=0.13;
    binsize=0.02;
end


% for each experiment: put all run data into one vector:
mB= NaN(55,40);
mC= NaN(55,40);
mT= NaN(55,40);
revN= NaN(55,40);
revNnorm=NaN(55,40);
c=0;

for batch=1%:length(files)
  
    
    load(files(batch).name);
    disp(files(batch).name);
  
    
   

for F=1:length(bearing)
    
    if ~isempty(bearing{F})
    
    c=c+1;
    bearingAll=[];
    dCdtAll=[];
    SpeedAll=[];
    revAll=[];

    
    for i=1:length(bearing{F})
        if ~isempty(dBearing{F}{i})            
                bv=bearing{F}{i};    
%                 cp=sensPath{F}{i};
%                 dC=[NaN NaN NaN cp(4:end)-cp(1:end-3) ];
                sp=speed_ctr{F}{i};
                rev=reversals{F}{i};
               
                bearingAll=cat(2,bearingAll,bv);
%                 dCdtAll=cat(2,dCdtAll,dC);
                SpeedAll=cat(2,SpeedAll,sp); 
                revAll=cat(2,revAll,rev); 
        end
    end
    
    
    bv=round(bearingAll*10)/10;

%     if batch<3 
%     dCdtAll=dCdtAll*((1/batch)+1);
%     else
%         dCdtAll=dCdtAll*1;
%     end
%    
%     %normalize for speed:
%     dCdtAlln=dCdtAll./(sp*67);
%     gi=find(isinf(dCdtAlln));
% dCdtAlln(gi)=NaN;
%%%%%bin: 
cc=1;
if ~isempty(bv)
       
    for i=first :binsize:(last-binsize)
        
        if bintype==1
        bin_idx= find(bv>i & bv<=i+binsize);
        else
            bin_idx= find(dCdtAll>i & dCdtAll<=i+binsize);
        end   
        bin_idx(bin_idx>length(bv)-delay)=[];
    
        if ~isempty(bin_idx)
%         dC=dCdtAll(bin_idx);
        revV=revAll(bin_idx+delay);
        binB=bv(bin_idx);
%         binS=SpeedAll(bin_idx);
        %remove reversals which happen at very low speed episodes:
%         bi=find(binS(find(revV))<0.02);
%         ri=(find(revV));
%         revV(ri(bi))=0;
        
        mB(c,cc)=nanmean(binB);
%         mC(c,cc)=nanmean(dC);
        revN(c,cc)=nansum(revV);
        revNnorm(c,cc)=nansum(revV)/length(bin_idx);
        end
        
        cc=cc+1;
                
    end
    
end
    end
end

end % end files loop

revNnorm=revNnorm(1:c,1:cc-1);
% mC=mC(1:c,1:cc-1);
revN=revN(1:c,1:cc-1);
mB=mB(1:c,1:cc-1);

%% plot:(1) reversal rate binned by bearing
name=dirname2(cd);

if plotting==1
%figure    
sem=nanstd(revNnorm*3,1)/sqrt(c);
hold on
h(CC)=plot(nanmean(revNnorm*3,1),'color',CM(delay,:));
errorb(nanmean(revNnorm*3,1),sem);
if bintype==1
    set(gca,'XTick',[1:length(mB)])
    set(gca,'XTickLabel',round(nanmedian(mB,1)*1)/1);
    xlabel('bearing')
else
    set(gca,'XTick',[1:length(mC)])
    set(gca,'XTickLabel',round(nanmeanJ(mC,1)*1000)/1000);
    xlabel('dC/dT')
end
ylabel('reversal frequency (rev/s)')
%ylim([0.012 0.025])
title ([name ])

end
leg{CC}=[num2str(round(delay*10/3)/10) 's'];
CC=CC+1;
end

ylim([0.01 0.04])
%%
saveas(gca, ['reversal_freq_modulation.fig'])

% save turningbias mT
y=chirp(1:0.001:1.5,30);
sound(y)

legend(h,leg);



