function out = compare_cwc(ncfile,wvisofile)
% If counterflow is off, then concert wviso1 and wviso2 to g/m3 and do scatter plot of entire flight

time_seconds = ncread(ncfile,'Time');
dryflow = ncread(ncfile, 'DRYFLW_CVI');
    H2o_pic1 = ncread(wvisofile,'H2O_WVISO1');
    H2o_pic2 = ncread(wvisofile,'H2O_WVISO2');

    M_WVISO1 = H2o_pic1/1000/1000;
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
    LWC_cvi = (M_WVISO1.*18) .*  ((flow_inlet/60/1000 .* 101325/298/Rd) ./ (CVI_tip_area .* air_speed))

% Picarro 2 total water content
flow_wviso1 = 0.64;
flow_wviso2 = 0.438;  % L/min (set by Alicat)
flow_wviso1_si = flow_wviso1/60/1000; % convert from LPM to m3/s
flow_wviso2_si = flow_wviso2/60/1000; % convert from LPM to m3/s

% measured amount of total water in the WVISO analyzers
wviso2_gm3 = (M_wviso2*18) .* (Pr./Tp./Rd); % 

% assumed mass of condensed water in measurement, according to cvi LWC
mass_rate_condensed = LWC_cvi .* flow_wviso2_si; % units of g/s of condensed water

% assumed mass of vapor in measurement, according to cvi LWC
vapor_content = wviso2_gm3 - LWC_cvi;

figure(1)
plot(time_seconds,LWC_cvi,time_seconds,wviso2_gm3,time_seconds,vapor_content); hold on;

end