function out = plot_ice_isotope(ncfile)
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
    
    
    no_cloud = conc_cdp < 0.01;
    in_cloud = counterflow > 2;
    sum(no_cloud)
    vapor = (conc_cdp < 0.01) & (counterflow < 0.15);
    sum(vapor)
    

    VXL_vapor = vxl(vapor);
    WVISO1 = H2o_pic1(vapor);
    time_vapor = time(vapor);
    T1 = table(VXL_vapor, WVISO1, time_vapor);
    
    %Make figure
    figure(1);
    
    %Ice habits
    ax1 = nexttile;
    %p1 = scatter(H2o_pic1(vapor), dD_1(vapor), 20, time(vapor), "DisplayName", "Picarro 1 out of cloud");hold on 
    p2 = scatter(H2o_pic1(in_cloud), dD_1(in_cloud), 20, time(in_cloud), "DisplayName", "Picarro 1 in cloud");hold on 
    %p2 = scatter(vxl(no_cloud), H2o_pic2(no_cloud),10, datenum(time(no_cloud)), "DisplayName", "Picarro 2");

    ylabel('dD');
    xticks('auto')

    grid on
    xlabel('WVISO1 water')
    legend();

    title([flightnumber ' ' flightdate]);
    row1 = dataTipTextRow('Time', string(time(vapor)));
    %p1.DataTipTemplate.DataTipRows(end+1) = row1;
    row2 = dataTipTextRow('Time', string(time(in_cloud)));
    p2.DataTipTemplate.DataTipRows(end+1) = row2;
    
    grid on
    legend();
    title([flightnumber ' ' flightdate]);
    
    
end