function out = read_wviso_data(dataFolder)

wviso_time = [];
wviso_h2O = [];

filePattern = fullfile(dataFolder, '*.dat'); % Change to whatever pattern you need.
dataFiles = dir(filePattern);
for k = 1 : length(dataFiles)
    baseFileName = dataFiles(k).name;
    datafile = fullfile(dataFiles(k).folder, baseFileName);
    fprintf('Now processing %s\n', datafile);

    T = readtable(datafile)
    DateStrings = join([string(T.DATE) string(T.TIME)]);
    wviso_time = [wviso_time; datetime(DateStrings,'InputFormat','yyyy-MM-dd HH:mm:ss.SSS')];
    wviso_h2O = [wviso_h2O; T.H2O];
end

wviso_timetable = timetable(wviso_time,wviso_h2O);
wviso_1hz = retime(wviso_timetable,'secondly','mean');

time = wviso_1hz.wviso_time
h2o = wviso_1hz.wviso_h2O

end