
%gradient profile wrapper:
folders=dir('*His*')

for fo=2:length(folders)
    cd(folders(fo).name)
    disp(folders(fo).name)
WeatherVaning_10hz_stage_timeslot
clearvars -except fo folders
cd ..\
end
disp('done')