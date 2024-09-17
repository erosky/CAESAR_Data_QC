function out = wviso_create_LRT(ref_ncfile,wviso_dir,output_ncfile)

%% If output file exists, delete to create new one
if isfile(fullfile(output_ncfile))
    % File exists
    delete(fullfile(output_ncfile));
end

%% Read reference netcdf file and get time dimensions from it
% Netcdf time given in 'seconds since YYYY-MM-DD 00:00:00 +0000' where YYYY-MM-DD corresponds to date of research flight.
ref_info = ncinfo(ref_ncfile,'LWC_CVI');
time = ncread(ref_ncfile,'Time');
time_size = size(time,1)

flightdate = ncreadatt(ref_ncfile, '/', 'FlightDate');
date = split(flightdate, "/");
ref_time = datetime(str2double(date{3}),str2double(date{1}),str2double(date{2})) + seconds(time(:,1));

ref_timetable = timetable(ref_time); % Needed to perform synchronization with WVISO times
ref_min = min(ref_time);
ref_max = max(ref_time);

%% Read raw wviso1 data files and format to fit LRT (2346)
% d18O_WVISO1
% dD_WVISO1
% H2O_WVISO1

raw_wviso1_time = [];
raw_H2O_WVISO1 = [];
raw_d18O_WVISO1 = [];
raw_dD_WVISO1 = [];

filePattern = fullfile(wviso_dir, 'HIDS2346*.dat'); % Read in all data files from the flight date
dataFiles = dir(filePattern);
for k = 1 : length(dataFiles)
    datafile = fullfile(dataFiles(k).folder, dataFiles(k).name);
    T = readtable(datafile);
    % Extract timestamps
    DateStrings = join([string(T.DATE) string(T.TIME)]); % Combine date and time variables
    raw_wviso1_time = [raw_wviso1_time; datetime(DateStrings,'InputFormat','yyyy-MM-dd HH:mm:ss.SSS')];
    % Extract variables
    raw_H2O_WVISO1 = [raw_H2O_WVISO1; T.H2O];
    raw_d18O_WVISO1 = [raw_d18O_WVISO1; T.Delta_18_16];
    raw_dD_WVISO1 = [raw_dD_WVISO1; T.Delta_D_H];
end

% Ensure WVISO times do not go outside bounds of reference times
wviso1_bounds = (raw_wviso1_time >= ref_min) & (raw_wviso1_time <= ref_max);
raw_wviso1_time = raw_wviso1_time(wviso1_bounds);
raw_H2O_WVISO1 = raw_H2O_WVISO1(wviso1_bounds);
raw_d18O_WVISO1 = raw_d18O_WVISO1(wviso1_bounds);
raw_dD_WVISO1 = raw_dD_WVISO1(wviso1_bounds);

% Convert data to 1Hz
wviso1_timetable = timetable(raw_wviso1_time, raw_H2O_WVISO1, raw_d18O_WVISO1, raw_dD_WVISO1);
wviso1_1Hz = retime(wviso1_timetable,'secondly','mean');

wviso1_time = wviso1_1Hz.raw_wviso1_time;


%% Create timeseries of variables using reference netcdf times



% Synchronize the WVISO data with the reference times
wviso1_lrt_timetable = synchronize(ref_timetable,wviso1_1Hz);

H2O_WVISO1_1Hz = wviso1_lrt_timetable.raw_H2O_WVISO1;
d18O_WVISO1_1Hz = wviso1_lrt_timetable.raw_d18O_WVISO1;
dD_WVISO1_1Hz = wviso1_lrt_timetable.raw_dD_WVISO1;


% Checks
wviso1_lrt_timetable(10000,:)

disp("original netcdf greater than wviso?")
disp(size(ref_time,1)>size(wviso1_time,1))

disp("original netcdf same size as new data?")
disp(size(dD_WVISO1_1Hz,1)==size(ref_time,1))

%% WVISO2 (2406)
% d18O_WVISO2
% dD_WVISO2
% H2O_WVISO2

raw_WVISO2_time = [];
raw_H2O_WVISO2 = [];
raw_d18O_WVISO2 = [];
raw_dD_WVISO2 = [];

filePattern = fullfile(wviso_dir, 'HIDS2406*.dat'); % Read in all data files from the flight date
dataFiles = dir(filePattern);
for k = 1 : length(dataFiles)
    datafile = fullfile(dataFiles(k).folder, dataFiles(k).name);
    T = readtable(datafile);
    % Extract timestamps
    DateStrings = join([string(T.DATE) string(T.TIME)]); % Combine date and time variables
    raw_WVISO2_time = [raw_WVISO2_time; datetime(DateStrings,'InputFormat','yyyy-MM-dd HH:mm:ss.SSS')];
    % Extract variables
    raw_H2O_WVISO2 = [raw_H2O_WVISO2; T.H2O];
    raw_d18O_WVISO2 = [raw_d18O_WVISO2; T.Delta_18_16];
    raw_dD_WVISO2 = [raw_dD_WVISO2; T.Delta_D_H];
end


% Ensure WVISO times do not go outside bounds of reference times
WVISO2_bounds = (raw_WVISO2_time >= ref_min) & (raw_WVISO2_time <= ref_max);
raw_WVISO2_time = raw_WVISO2_time(WVISO2_bounds);
raw_H2O_WVISO2 = raw_H2O_WVISO2(WVISO2_bounds);
raw_d18O_WVISO2 = raw_d18O_WVISO2(WVISO2_bounds);
raw_dD_WVISO2 = raw_dD_WVISO2(WVISO2_bounds);

% Convert data to 1Hz
WVISO2_timetable = timetable(raw_WVISO2_time, raw_H2O_WVISO2, raw_d18O_WVISO2, raw_dD_WVISO2);
WVISO2_1Hz = retime(WVISO2_timetable,'secondly','mean');

WVISO2_time = WVISO2_1Hz.raw_WVISO2_time;


%% Create timeseries of variables using reference netcdf times

% Ensure

WVISO2_lrt_timetable = synchronize(ref_timetable,WVISO2_1Hz);
size(ref_timetable)


H2O_WVISO2_1Hz = WVISO2_lrt_timetable.raw_H2O_WVISO2;
d18O_WVISO2_1Hz = WVISO2_lrt_timetable.raw_d18O_WVISO2;
dD_WVISO2_1Hz = WVISO2_lrt_timetable.raw_dD_WVISO2;


% Checks
WVISO2_lrt_timetable(10000,:)

disp("original netcdf greater than wviso?")
disp(size(ref_time,1)>size(WVISO2_time,1))

disp("original netcdf same size as new data?")
disp(size(dD_WVISO2_1Hz,1)==size(ref_time,1))

%% Write new netcdf file

nccreate(output_ncfile,"Time", "Dimensions",{"Time", time_size},"Format","classic","Datatype","int32")

nccreate(output_ncfile,"dD_WVISO1", "Dimensions",{"Time", time_size},"Format","classic","Datatype","single")
nccreate(output_ncfile,"d18O_WVISO1", "Dimensions",{"Time", time_size},"Format","classic","Datatype","single")
nccreate(output_ncfile,"H2O_WVISO1", "Dimensions",{"Time", time_size},"Format","classic","Datatype","single")

nccreate(output_ncfile,"dD_WVISO2", "Dimensions",{"Time", time_size},"Format","classic","Datatype","single")
nccreate(output_ncfile,"d18O_WVISO2", "Dimensions",{"Time", time_size},"Format","classic","Datatype","single")
nccreate(output_ncfile,"H2O_WVISO2", "Dimensions",{"Time", time_size},"Format","classic","Datatype","single")

ncwrite(output_ncfile, "Time", time)

ncwrite(output_ncfile,"dD_WVISO1",dD_WVISO1_1Hz)
ncwrite(output_ncfile,"d18O_WVISO1",d18O_WVISO1_1Hz)
ncwrite(output_ncfile,"H2O_WVISO1",H2O_WVISO1_1Hz)

ncwrite(output_ncfile,"dD_WVISO2",dD_WVISO2_1Hz)
ncwrite(output_ncfile,"d18O_WVISO2",d18O_WVISO2_1Hz)
ncwrite(output_ncfile,"H2O_WVISO2",H2O_WVISO2_1Hz)


