%% weathervaning hist
%plot?
plots=1;
files =dir('*runinfo*');
fig=figure;


for batch=1%:2% :length(files)

    load(files(batch).name);
    disp(files(batch).name);
   % for each experiment: put all run data into one vector:
mB= NaN(length(bearing),18);
mT= NaN(length(bearing),18);
mS= NaN(length(bearing),18);
c=0;

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
               
                bearingAll=cat(2,bearingAll,bv);
                dBearingAll=cat(2,dBearingAll,tr);
                SpeedAll=cat(2,SpeedAll,sp);

            end
        end
    end
    
    
    bv=(bearingAll);
    tr=(dBearingAll);
    sp=(SpeedAll);

    %kill extremely high turning rates (short reversals etc)
    
    bi=tr>19 | tr<-19;
    tr(bi)=NaN;
    bv(bi)=NaN;
    sp(bi)=NaN;
    tnorm=tr./(sp*67);
    bi=tnorm>10 | tnorm<-10;
    tnorm(bi)=NaN;
    tnorm=tnorm/0.8552;  % 0.8552= conversion from deg/pix-->rad/mm 1/(67*(360/(2*pi)))
  
%      figure(fig2)
%      try
%      subplot(1,5,F)
%      hist(bv,20)
%      end
     
if ~isempty(bv)
    
    [X,v]=hist(bv,10);
    X1(c,:)=X./sum(X);
    cc=1;
    %bin -->for what?
    a=10;
    for i=10 :a:165
        bin_idx= bv>i & bv<=i+a;
        pb1=bv(bin_idx);
        pt=tnorm(bin_idx);
        st=sp(bin_idx);

        mB(c,cc)=nanmean(pb1);
        mT(c,cc)=nanmean(round(pt*10)/10);
        mS(c,cc)=nanmean(st);

        cc=cc+1;
    end
    
end
    end
end


%% plot:(1) turning rate binned by bearing
if plots==1

figure(fig)
subplot(1,length(files),batch)
title(files(batch).name(9:end-11))
sem=nanstd(mT*3,1)/sqrt(c);
hold on
bar(nanmean(mT*3,1));
errorb(nanmean(mT*3,1),sem)
set(gca,'XTick',[1:length(mB)])
set(gca,'XTickLabel',round(nanmedian(mB,1)));
xlabel('bearing')
ylabel('turning rate (rad/mm)')
ylim([-0.2 0.1])

end % end files loop


nd=(cd);
d= strfind(cd, '\');
name=nd(d(end)+1:end);

% saveas(gca, 'weathervaning.jpg')


% figure
% sem=nanstd(X1,1)/sqrt(c);
% bar(nanmean(X1,1))
% hold on
% errorb(mean(X1,1),sem)
% set(gca,'XTick',[1:length(X)])
% set(gca,'XTickLabel',floor(v(1:end)));
% ylim([0 0.15]);
% title (strcat(name, '..n=',num2str(F)))
% xlabel('bearing')
% title (['all bearing hist:' name])
% 
% %saveas(gca, 'all bearing distribution.fig')
% % saveas(gca, 'all bearing distribution.jpg')
% 
% % speed:
% figure
% sem=nanstd(mS,1)/sqrt(c);
% hold on
% bar(nanmean(mS,1))
% errorb(nanmean(mS,1),sem)
% set(gca,'XTick',[1:length(mB)])
% set(gca,'XTickLabel',round(nanmean(mB,1)));
% xlabel('bearing')
% ylabel('speed (mm/min)')
% ylim([0 0.25]);
% title (['speed:' name])

%saveas(gca, 'speed.fig')

end

suptitle([name(1:end) ': speed normalized'])
saveas(gca, 'weathervaning_sp_norm.fig')
%% (2) bearing  binned by turning rate


