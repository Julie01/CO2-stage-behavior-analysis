%% speed binned by bearing 
% uses on runinfo files
clear
home=cd;

%plot?
plotting=1;

if plotting==1
fig=figure;
end

speed_correctf=1%0.026/0.0155;
% for GT =1:2 % if you have 2 folders with control and gradient data
%     tic
%     if GT==1
%         cd('control')
%         
%     elseif GT==2
%         cd('gradient')
%     end

files =dir('*runinfo*');

%parameters:
first=1;
last=179;
binsize=10;

% for each experiment: put all run data into one vector:
mB= NaN(2,2);
mT= NaN(2,2);
mS= NaN(2,2);
c=0;

for batch=1:length(files)
    
    load(files(batch).name);
    disp(files(batch).name);
   

for F=1:length(bearing)
    
    if ~isempty(bearing{F})
    
    c=c+1;
    bearingAll=[];
    dBearingAll=[];
    SpeedAll=[];

    
    for i=1:size(bearing{F},1)
        if ~isempty(dBearing{F}{i,1})
            for rr=1:size(bearing{F}(i,:),2)
                bv=bearing{F}{i,rr};
                tr=dBearing{F}{i,rr};
                sp=speed_ctr{F}{i,rr};
                if F<5
                sp=speed_ctr{F}{i,rr}*speed_correctf;
                end
               
                bearingAll=cat(2,bearingAll,bv);
                dBearingAll=cat(2,dBearingAll,tr);
                SpeedAll=cat(2,SpeedAll,sp);

            end
        end
    end
    
    
    bv=round(bearingAll*10)/10;
    tr=round(dBearingAll*10)/10;
    sp=round(SpeedAll*100)/100;

    %kill extremely high turning rates (short reversals etc)
    
    bi=find(tr>19 | tr<-19);
    bi2= find(bv>last| bv<first);
    bi=[bi,bi2];
    tr(bi)=NaN;
    bv(bi)=NaN;
    sp(bi)=NaN;
    
if ~isempty(bv)
    
    [X,v]=hist(bv,10);
    X1(c,:)=X./sum(X);
    cc=1;
    %bin -->for what?
    
    for i=first:binsize:last
        bin_idx= bv>i & bv<=i+binsize;
        pb1=bv(bin_idx);
        pt=tr(bin_idx);
        st=sp(bin_idx);

        mB(c,cc)=nanmean(pb1);
        mT(c,cc)=nanmean(pt);
        mS(c,cc)=nanmean(st);

        cc=cc+1;
    end
    
end
    end
end

end % end files loop

save mS mS
nd=(cd);
d= strfind(cd, '\');
name=nd(d(end)+1:end);


%% plot:(1) speed binned by bearing
if plotting==1
set(0,'DefaultTextInterpreter','none');
figure(fig)
CM=(winter(2)/1.5);
sem=nanstd(mS,1)/sqrt(c);
hold on
plot(nanmean(mS,1),'linewidth', 2, 'color' ,CM(1,:));
%plot(nanmean(mS,1),'linewidth', 2, 'color' ,CM(GT,:));
errorb(nanmean(mS,1),sem)
set(gca,'XTick',[1:length(mB)])
set(gca,'XTickLabel',round(nanmean(mB,1)));
xlabel('bearing')
ylabel('speed (mm/sec)')
ylim([0.09 0.19]);
title (['speed:' name])

end

legend(name)
plotdir=dir('*plots*');
if isempty(plotdir)
    mkdir([name ' plots'])
    plotdir=dir('*plots*');
end
%%
cd(plotdir(1).name)
% saveas(gca, 'weathervaning_pooled_olddata.fig')
  saveas(gca, 'speed modulation.fig')

cd ..\

cd(home)




%% (2) bearing  binned by turning rate


