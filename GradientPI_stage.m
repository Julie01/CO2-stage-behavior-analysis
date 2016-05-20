figure('visible','on')
directory=dir('*RIB*His*');
clearvars -except directory
home=cd;
genotypes=cell(1,8);
genotypes(1:8)={''};

CI2=NaN(16,length(directory));
cc=1;
for dd=1:length(directory)
    clearvars -except dd cc home directory genotypes CI2 H
    cd(directory(dd,1).name)
    sd=dir('*analysis*');
    cd(sd(1).name)
    for cond=1%:2
        
    
%     if mod(cc,2)==0
%          cd('gradient')
%     else
%         cd('control')
%        
%     end
    

    
    % average over e experiments for t timebins:
    file=dir('HMnorm_batch*');
    load(file(1).name);
    % clearvars -except directory home dd HMnorm_batch SpeedM_batch angSpeedM_batch cc genotypes
    c=1;
    
    timebin=10; % How many time points???
    
    for t=1:(length(HMnorm_batch{1,1})/timebin)-1
        % it starts with a structure containing the normalized (percentage of
    % animals at a given timepoint in a givenbin of the arena)
    mHM=NaN(size(HMnorm_batch{1,1}(:,:,1)));
    
    for e= 1:length(HMnorm_batch)
        mHM1=squeeze(nanmean(HMnorm_batch{1,e}(:,:,c:c+timebin),3)); %averaging over 100 sec
        if size(mHM(:,:,1))==size (mHM1)
            mHM(:,:,e)=mHM1;
        else
            if length (mHM(:,:,1))<size (mHM1)
                mHM(:,:,e)=mHM1(1:size(mHM,1),1:size(mHM,2));
            elseif length (mHM(:,:,1))>size (mHM1)
                mHM(1:size(mHM1,1),1:size(mHM1,2),e)=mHM1;
            end
            
        end
    end
    disp(['last bin: ' num2str(length(HMnorm_batch{1})-c) '...length of stack:' num2str(length(HMnorm_batch{1}))])
    %each cell: averaged data for e experiments and one timebin
    HMoE{t}=mHM;
    c=c+timebin;
end

%% plot mean ocupancy for sectors over 4 time bins
J=jet(length(HMoE));
 nd=(cd);
 d= strfind(cd, '\');
name=nd(d(end)+1:end-9)
title (name)
% legend('sem','1-7.5','','7.5-15','','15-22.5','','22.5-30');
% saveas(gcf, strcat('distribution_',name))


%% plot Gradient Index:
J=jet(4);
jj=1;
for i=1:2:length(HMoE)%length(HMoE)=timebins, in each cell 3rd dimension is experiments, so each i is one timepoint
sHM=squeeze(nansum(HMoE{i},1)); %summing up all animals along the short axis of arena, keeping n experiments
F1=nansum(sHM(13:26,:),1);%this vector has length of number of experiments
F2=nansum(sHM(1:13,:),1);
CI(jj,1:size(sHM,2))=(F1-F2)./(F2+F1);
jj=jj+1;
end

mCI=nanmean(CI,2);
sem=nanstd(CI')/sqrt(e);
subplot(1,2,1)
hold on
H{cc}=shadedErrorBar2([1:(30/length(mCI)):30],mCI,sem,{'-or','Color',J(cc,:)},0);
xlabel(' time (min)')
ylabel ('PI')
% boxplot(PI');
hold on
genotypes{cc+1}= (name);
cc=cc+1;
CI2(1:length(CI(end,:)),cc-1)=CI(end-3,:);
save CI CI

cd ..\

    end

cd(home)


end

plot([0 30],[0.0 0.0],'--k')
try
h=[H{1}.mainLine H{2}.mainLine H{3}.mainLine];
catch
 h=[H{1}.mainLine H{2}.mainLine];   
end
legend(h(1:3),directory(1).name,directory(2).name,directory(3).name);
ylim([-0.85 0.6])
% title('CI over time')
%%
subplot(1,2,2)
cla
%notBoxplot(CI2,[]'whisker',1,'labels',{'N2 ctrl','N2 gradient','flp-1,nlp12 ctrl',' flp-1,nlp12 grad'})
notBoxPlot(CI2(:,1:cc-1))
try
set(gca,'Xticklabel',{directory(1).name(1:15),directory(2).name(1:15),directory(3).name(1:12)},'FontSize',8)
catch
set(gca,'Xticklabel',{directory(1).name(1:15),directory(2).name(1:15)},'FontSize',8)
end
ylim([-1 0.5])

for i=1:2
    try
    a=CI2(:,i);
    a(isnan(a))=[];
    b=CI2(:,i+1);
    b=b(~isnan(b));
[h(i) p(i)]=ttest2JR(a,b)
text(i+0.2,0.15,['p=' num2str(round(p(i)*100000)/100000)])
    end
end


