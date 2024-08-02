function out = plot_twc_comparison(ncfile)
    %Plot a time series of CDP DSDs from SPICULE
    datetime.setDefaultFormats('default','HH:mm:ss (yyyy-MM-dd)')
    
    %Get water data from the netCDF file
    time_seconds = ncread(ncfile,'Time');
    conc_cdp = ncread(ncfile, 'CONCD_LWO');
    conc_2ds = ncread(ncfile,'TACT2V_2DS');
    vxl = ncread(ncfile,'VMR_VXL');
    H2o_pic1 = ncread(ncfile,'H2O_WVISO1');
    H2o_pic2 = ncread(ncfile,'H2O_WVISO2');
    king = ncread(ncfile,'PLWCC');
    icing = ncread(ncfile,'RICE');
    cdp_lwc = ncread(ncfile,'PLWCD_LWO')

    M = H2o_pic1/1000/1000;

    % Air thermo
    hpa = ncread(ncfile,'PSXC');
    celcius = ncread(ncfile, 'ATX');
    Pr = hpa*100;
    Tp = celcius+273.15;

    air_speed = ncread(ncfile, 'TASX');
	flow_user = ncread(ncfile, 'USRFLW_CVI');
	 	flow_bypass = ncread(ncfile, 'BYPFLW_CVI');
	 	pres_sample = ncread(ncfile, 'PSAMP_CVI') * 100;
		temp_inlet = 40 + 273.16;

        flow_inst = 0.64; % L/min (measured by Alicat)
	 	pres_STP = 101325; % Pa
	 	temp_STP = 298; % K;  David used 273.16K, but Alicat uses 25C
	 	CVI_tip_area = 31.416/1000/1000; % m2;  is this the same size as NCAR%s?
	 	CVI_tip_area = 2.865258e-05;
        Rw = 461.5 * 18/1000 % Rw=461.5 J/(kg·K) *kg/1000g *18 g/mol 
	 	Rd = 287.058 * 28.9645/1000 % Rd=287.058 J/(kg·K) * kg/1000g *28.9645 g/mol 
    flow_inlet = flow_bypass + flow_inst + flow_user;% L/min (all measured by Alicat)
    LWC_cvi = (M.*18) .*  ((flow_inlet/60/1000 .* 101325/298/Rd) ./ (CVI_tip_area .* air_speed))
    %Get isotopes
    dD_1 = ncread(ncfile,'dD_WVISO1');
    dD_2 = ncread(ncfile,'dD_WVISO2');
    d180_1 = ncread(ncfile,'d18O_WVISO1');
    d180_2 = ncread(ncfile,'d18O_WVISO2');

    %Additional cloud data
    hvps = ncread(ncfile,'TACT2V_HVPS');
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
    tiledlayout(2,1);
    
    %Ice habits
    ax1 = nexttile;

    %Ice habits
    yyaxis left
    p1 = plot(datenum(time), LWC_cvi, "DisplayName", "CVI cloud water content", "Color","g", "LineStyle", "-","LineWidth", 2);hold on
    p2 = plot(datenum(time), king, "DisplayName", "King probe LWC", "Color","c", "LineStyle", "-","LineWidth", 2); hold on 
    p3 = plot(datenum(time), cdp_lwc, "DisplayName", "CDP LWC", "Color","r", "LineStyle", "-","LineWidth", 2);
    ylabel('LWC');
    xticks('auto')

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
    
    ax2 = nexttile;
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
    linkaxes([ax1, ax2],'x');
    zoom xon;  %Zoom x-axis only
    pan;  %Toggling pan twice seems to trigger desired behavior, not sure why
    pan;
    
end