function out = compare_cwc(ncfile,wvisofile)
    %Plot a time series of CDP DSDs from SPICULE
    datetime.setDefaultFormats('default','HH:mm:ss (yyyy-MM-dd)')
    
    %Get water data from the netCDF file
    time_seconds = ncread(ncfile,'Time');
    conc_cdp = ncread(ncfile, 'CONCD_LWO');
    conc_2ds = ncread(ncfile,'TACT2V_2DS');
    vxl = ncread(ncfile,'VMR_VXL');
    H2o_pic1 = ncread(wvisofile,'H2O_WVISO1');
    H2o_pic2 = ncread(wvisofile,'H2O_WVISO2');
    king = ncread(ncfile,'PLWCC');
    icing = ncread(ncfile,'RICE');
    cdp_lwc = ncread(ncfile,'PLWCD_LWO')
    cdp_diameter = ncread(ncfile, 'DBARD_LWO');

    PLWCD_LWI
    PLWCD_LWO
    CCDP_LWI
    CDP016
    CDP016_bnds
    CDP058

    PLWC2DCA_RPC Fast 2DC all
PLWC2DCR_RPC Fast 2DC round
PLWC2DSA_2H Fast 2Ds all sub H for V for other channel
PLWC2DHA_H1 HVPS all


    M = H2o_pic1/1000/1000;
    M_wviso2 = H2o_pic2/1000/1000;

    % Air thermo
    hpa = ncread(ncfile,'PSXC');
    celcius = ncread(ncfile, 'ATX');
    Pr = hpa*100;
    Tp = celcius+273.15;

    % PIcarro flows
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

% Picarro 2 total water content
flow_wviso2 = 0.438;  % L/min (set by Alicat)
flow_wviso2_si = flow_wviso2/60/1000; % convert from LPM to m3/s

% measured amount of total water in the WVISO2 analyzer
mass_rate_total = (M_wviso2*18) .* (flow_wviso2_si .* pres_STP/temp_STP/Rd); % end result in units of g/s of water

% assumed mass of condensed water in measurement, according to cvi LWC
mass_rate_condensed = LWC_cvi .* flow_wviso2_si; % units of g/s of condensed water

% assumed mass of vapor in measurement, according to cvi LWC
mass_rate_vapor = mass_rate_total - mass_rate_condensed;

vapor_water_content = mass_rate_vapor./flow_wviso2_si;
total_water_content = mass_rate_total./flow_wviso2_si;




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
    tiledlayout(3,1);

    ax1 = nexttile;

    yyaxis left
    p1 = plot(datenum(time), LWC_cvi, "DisplayName", "CVI cloud water content", "Color","g", "LineStyle", "-","LineWidth", 2);hold on
    p2 = plot(datenum(time), king, "DisplayName", "King probe LWC", "Color","c", "LineStyle", "-","LineWidth", 2); hold on 
    p3 = plot(datenum(time), cdp_lwc, "DisplayName", "CDP LWC", "Color","r", "LineStyle", "-","LineWidth", 2);
    xticks('auto')

    p1 = plot(datenum(time), total_water_content, "DisplayName", "CVI total water content", "Color","b", "LineStyle", "-","LineWidth", 2);hold on
    ylabel('LWC (g/m3)');

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

    %Ice habits
    ax3 = nexttile;
    yyaxis left
    p1 = plot(datenum(time), hvps, "DisplayName", "HVPS (100um - 10mm)", "Color","g", "LineStyle", "-","LineWidth", 2);hold on
    p2 = plot(datenum(time), conc_2ds, "DisplayName", "2DS (10 - 1000 um)", "Color","c", "LineStyle", "-"); hold on 
    ylabel('OAP particle counts');
        xticks('auto')
        yyaxis right
        p2 = plot(datenum(time), cdp_diameter, "DisplayName", "2DS (10 - 1000 um)", "Color","r", "LineStyle", "-"); hold on 
        ylabel('CDP mean diameter');


    datetick('x');
    grid on
    xlabel('Time')
    legend();
    title([flightnumber ' ' flightdate]);

       %Link axes for panning and zooming
    linkaxes([ax1, ax2, ax3],'x');
    zoom xon;  %Zoom x-axis only
    pan;  %Toggling pan twice seems to trigger desired behavior, not sure why
    pan;
    
end