function out = VXL_WVISO_agreement(ncfile)
    %Plot a time series of CDP DSDs from SPICULE
    datetime.setDefaultFormats('default','HH:mm:ss (yyyy-MM-dd)')
    
    %Get water data from the netCDF file
    time = ncread(ncfile,'Time');
    conc_cdp = ncread(ncfile, 'CONCD_LWO');
    vxl = ncread(ncfile,'VMR_VXL');
    H2o_pic1 = ncread(ncfile,'H2O_WVISO1');
    H2o_pic2 = ncread(ncfile,'H2O_WVISO2');
    counterflow = ncread(ncfile,'DRYFLW_CVI');
    
    %Get isotopes
    dD_1 = ncread(ncfile,'dD_WVISO1');
    dD_2 = ncread(ncfile,'dD_WVISO2');
    d180_1 = ncread(ncfile,'d18O_WVISO1');
    d180_2 = ncread(ncfile,'d18O_WVISO2');

    % Flight data
    flightnumber = upper(ncreadatt(ncfile, '/', 'FlightNumber'));
    flightdate = ncreadatt(ncfile, '/', 'FlightDate');
    time_ref = split(flightdate, "/");
    %time = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time(:,1));
    
    test = ncread('../Status_Quality_Flags/RF05/testqc.nc','CVI_quality');
    mycolors = [];
    for c = test';
        if c == 0
            mycolors = [mycolors; [0,0,1]];
        else
            mycolors = [mycolors; [1,0,1]];
        end
    end


    size(mycolors)
    size(d180_1)
    myColors = zeros(size(test, 1), 3); % List of rgb colors for every data point.
rowsToSetBlue = test == 0;
sum(rowsToSetBlue)
rowsToSetRed = test ~= 0;
myColors(rowsToSetBlue,:) = repmat([0,0,1],length(myColors(rowsToSetBlue)),1);
myColors(rowsToSetRed, :) = repmat([1,0,1],length(myColors(rowsToSetRed)),1);
    
    no_cloud = conc_cdp < 0.01;
    in_cloud = counterflow > 2;
    sum(no_cloud)
    vapor = (conc_cdp < 0.01) & (counterflow < 0.15);
    sum(vapor)
    

    VXL_vapor = vxl(vapor);
    WVISO1 = H2o_pic1(vapor);
    time_vapor = time(vapor);
    T1 = table(VXL_vapor, WVISO1, time_vapor);
    
    H2o_incloud1 = H2o_pic1(in_cloud);
    dD_incloud1 = dD_1(in_cloud);
    time_incloud1 = time(in_cloud);
    
    
    %Plot in 30 minute intervals
    % figure(1);
%     for t = 1:900:(size(time(in_cloud))-900)
% %         %p1 = scatter(H2o_pic1(vapor), dD_1(vapor), 20, time(vapor), "DisplayName", "Picarro 1 out of cloud");hold on 
%          p2 = scatter(H2o_incloud1(t:t+900), dD_incloud1(t:t+900), 20, time_incloud1(t:t+900), "DisplayName", "Picarro 1 in cloud");hold off 
% %         %p2 = scatter(vxl(no_cloud), H2o_pic2(no_cloud),10, datenum(time(no_cloud)), "DisplayName", "Picarro 2");
% % 
%         ylabel('dD');
%         xticks('auto')
% 
%         grid on
%         xlabel('WVISO1 water')
%         legend();
% 
%         title([flightnumber ' ' flightdate]);
% %         row1 = dataTipTextRow('Time', string(time(vapor)(t:t+1800)));
% %         %p1.DataTipTemplate.DataTipRows(end+1) = row1;
% %         row2 = dataTipTextRow('Time', string(time(in_cloud)(t:t+1800)));
% %         p2.DataTipTemplate.DataTipRows(end+1) = row2;
% 
%         grid on
%         legend();
%         title([flightnumber ' ' flightdate]);
%         pause;
%     end
    
    figure(2);
    
    p1 = scatter(H2o_pic1, d180_1, 20, time, "DisplayName", "Picarro 1");hold on 
    %p2 = scatter(H2o_pic1, d180_1, 20, mycolors, "DisplayName", "Picarros vapor");hold on 
    %p2 = scatter(vxl(no_cloud), H2o_pic2(no_cloud),10, datenum(time(no_cloud)), "DisplayName", "Picarro 2");

    ylabel('dD');
    xticks('auto')

    grid on
    xlabel('WVISO2 water')
    legend();

    title([flightnumber ' ' flightdate]);
    % row1 = dataTipTextRow('Time', string(time(vapor)));
    % %p1.DataTipTemplate.DataTipRows(end+1) = row1;
    % row2 = dataTipTextRow('Time', string(time(in_cloud)));
    % p1.DataTipTemplate.DataTipRows(end+1) = row2;
    
    grid on
    legend();
    title([flightnumber ' ' flightdate]);
    
    
end