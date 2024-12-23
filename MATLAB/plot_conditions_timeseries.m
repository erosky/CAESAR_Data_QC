function out = plot_ice_isotope(ncfile,wvisofile)
    %Plot a time series of CDP DSDs from SPICULE
    datetime.setDefaultFormats('default','HH:mm:ss (yyyy-MM-dd)')
    
    %Get water data from the netCDF file
    time_seconds = ncread(ncfile,'Time');
    conc_cdp = ncread(ncfile, 'CONCD_LWO');
    conc_2ds = ncread(ncfile,'PLWC2DSA_2H');
    vxl = ncread(ncfile,'VMR_VXL');
    H2o_pic1 = ncread(ncfile,'H2O_WVISO1');
    H2o_pic2 = ncread(ncfile,'H2O_WVISO2');
    king = ncread(ncfile,'PLWCC');
    icing = ncread(ncfile,'RICE');
    vwind = ncread(ncfile,'WIX');

    % Air thermo
    hpa = ncread(ncfile,'PSXC');
    celcius = ncread(ncfile, 'ATX');
    pa = hpa*100;
    k = celcius+273.15;
    gm3_pic1 = H2o_pic1*(2.167e-6).*(pa./k);
    
    %Get isotopes
    dD_1 = ncread(ncfile,'dD_WVISO1');
    dD_2 = ncread(ncfile,'dD_WVISO2');
    d180_1 = ncread(ncfile,'d18O_WVISO1');
    d180_2 = ncread(ncfile,'d18O_WVISO2');
    %cvi_status = ncread(wvisofile,'quality_WVISO1');

    %Additional cloud data
    hvps = ncread(ncfile,'PLWC2DHA_H1');
    nevzorov_lwc = ncread(ncfile,'VCOLLWC_NEV');
    nevzorov_lwc_ref = ncread(ncfile,'VREFLWC_NEV');

    % Flight data
    altitude = ncread(ncfile,'GGALT');

    flightnumber = upper(ncreadatt(ncfile, '/', 'FlightNumber'));
    flightdate = ncreadatt(ncfile, '/', 'FlightDate');
    time_ref = split(flightdate, "/");
    time = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time_seconds(:,1));
    
    
    %Make figure
    figure(1);
    tiledlayout(4,1);
    
    %Ice habits
    ax1 = nexttile;
    yyaxis left
    p1 = plot(datenum(time), hvps, "DisplayName", "HVPS (100um - 10mm)", "Color","g", "LineStyle", "-","LineWidth", 2);hold on
    p2 = plot(datenum(time), conc_2ds, "DisplayName", "2DS (10 - 1000 um)", "Color","c", "LineStyle", "-"); hold on 
    ylabel('OAP particle counts');
        xticks('auto')

    yyaxis right
    p3 = plot(datenum(time), conc_cdp, "DisplayName", "CDP (5 - 35 um)", "Color","b", "LineStyle", "-"); hold on
    % p1R = plot(datenum(time), king, "DisplayName", "King LWC(g/m3)", "Color","m", "LineStyle", "-","LineWidth", 2);hold on
    % p2R = plot(datenum(time), gm3_pic1, "DisplayName", "CVI h20 (g/m3)", "Color","r", "LineStyle", "-"); hold on 
    ylabel('LWC');


    datetick('x');
    grid on
    xlabel('Time')
    legend();
    title([flightnumber ' ' flightdate]);
    
    datatipRow = dataTipTextRow('UTC',time);
    datatipRow2 = dataTipTextRow('seconds',string(time_seconds));
    p1.DataTipTemplate.DataTipRows(end+1:end+2) = [datatipRow, datatipRow2];
    p2.DataTipTemplate.DataTipRows(end+1:end+2) = [datatipRow, datatipRow2];
    p3.DataTipTemplate.DataTipRows(end+1:end+2) = [datatipRow, datatipRow2];
    
    %isotopes
    ax2 = nexttile;
    yyaxis left
    p4 = plot(datenum(time), dD_1, "DisplayName", "dD (CVI)", "Color","r", "LineStyle", "-", "LineWidth", 2); hold on
    p5 = plot(datenum(time), d180_1, "DisplayName", "d180 (CVI)", "Color","g", "LineStyle", "-", "LineWidth", 2); hold on
    ylabel('Condensate isotopic signal');
    
    p4.DataTipTemplate.DataTipRows(end+1:end+2) = [datatipRow, datatipRow2];
    p5.DataTipTemplate.DataTipRows(end+1:end+2) = [datatipRow, datatipRow2];

    % yyaxis right
    p6 = plot(datenum(time), dD_2, "DisplayName", "dD (SDI)", "Color","m", "LineStyle", "--", "LineWidth", 2);hold on
    p7 = plot(datenum(time), d180_2, "DisplayName", "d180 (SDI)", "Color","b", "LineStyle","--", "LineWidth", 2);hold on
    ylabel('Total water isotopic signature');

    p6.DataTipTemplate.DataTipRows(end+1:end+2) = [datatipRow, datatipRow2];
    p7.DataTipTemplate.DataTipRows(end+1:end+2) = [datatipRow, datatipRow2];
    
    datetick('x')
    xlabel('Time')
    legend
    grid on

    ax3 = nexttile;
    %yyaxis left
    %p5 = plot(datenum(time), cvi_status, "DisplayName", "cvi status", "Color","g", "LineStyle", "-","LineWidth", 2);hold on
   % ylabel('bad good caution_low_H2O caution_inlet_wetting uncharacterized');
    
    %p5.DataTipTemplate.DataTipRows(end+1) = datatipRow;

    yyaxis right
    p8 = plot(datenum(time), H2o_pic1, "DisplayName", "wviso1 h20", "Color","m", "LineStyle", "-","LineWidth", 2);hold on
    p9 = plot(datenum(time), H2o_pic2, "DisplayName", "wviso2 h20", "Color","r", "LineStyle", "--", "LineWidth", 2);


    p8.DataTipTemplate.DataTipRows(end+1:end+2) = [datatipRow, datatipRow2];
    p9.DataTipTemplate.DataTipRows(end+1:end+2) = [datatipRow, datatipRow2];

    datetick('x');
    grid on
    xlabel('Time')
    legend();
    title([flightnumber ' ' flightdate]);
    
    ax4 = nexttile;
    yyaxis left
    p11 = plot(datenum(time), altitude, "DisplayName", "Altitude (m)", "Color","g", "LineStyle", "-","LineWidth", 2);hold on
    yyaxis right
    p10 = plot(datenum(time), celcius, "DisplayName", "Temperature (C)", "Color","b", "LineStyle", "-","LineWidth", 2);hold on
    ylabel('Temperature');
 
    p11.DataTipTemplate.DataTipRows(end+1:end+2) = [datatipRow, datatipRow2];
    p10.DataTipTemplate.DataTipRows(end+1:end+2) = [datatipRow, datatipRow2];

    datetick('x');
    grid on
    xlabel('Time')
    legend();
    title([flightnumber ' ' flightdate]);
    
    
    %Link axes for panning and zooming
    linkaxes([ax1, ax2, ax3, ax4],'x');
    zoom xon;  %Zoom x-axis only
    pan;  %Toggling pan twice seems to trigger desired behavior, not sure why
    pan;
    
end