function [Dcenters, N] = holodec_lwc_comparison()
% return bin centers and number of particles in the bin
% separate plots:
% bin holodec with same size bins as cdp
%
% difference plot
% turn holodec to 1 hz
% match up time stamps with cdp data
% subtract values
% plot difference

% cdp netcdf location
nc_path = '/home/utest/Research/CAESAR/ncfiles';
ncfile = 'RF02.20240229.110700_181600.PNI.nc';
wviso_nc = 'CAESAR_CVI-WVISO_20240229_v1.0.nc';
flightdate = ncreadatt(ncfile, '/', 'FlightDate');
time_ref = split(flightdate, "/");

vwind = ncread(ncfile,'WIC'); %Vertical windspeed derived from Rosemount 858 airdata probe located on the starboard pylon, in units of metres per second
king = ncread(ncfile,'PLWCC');
cdp_lwc = ncread(ncfile,'PLWCD_LWO');
cdp2_lwc = ncread(ncfile,'PLWCD_LWI');
CWC_cvi = ncread(wviso_nc,'CWC_WVISO1');
CWC_2DC = ncread(ncfile, 'PLWC2DCA_RPC'); %Fast 2DC all
CWC_2DSH = ncread(ncfile, 'PLWC2DSA_2H'); %Fast 2Ds all sub H for V for other channel
CWC_HVPS = ncread(ncfile, 'PLWC2DHA_H1'); %HVPS all


time = ncread(ncfile,'Time');
start = time(1)
endraf = time(end)
cdp_conc = ncread(ncfile, 'CCDP_LWI');
s = size(cdp_conc);
conc = reshape(cdp_conc, [s(1), s(3)]);

all_edges = ncreadatt(ncfile, 'CCDP_LWI', 'CellSizes')
bins = [];
for b = 1 : length(all_edges)-1
    center = (all_edges(b) + all_edges(b+1))/2;
    bins = [bins; center];
end

% Density of water
rho_liquid = 997 * 1e3 ; %g/m^3
mass = rho_liquid*(4/3)*pi*(bins*10^(-6)/2).^3

cutsize = ncread(wviso_nc, 'cutsize_CVI');


cdp_cut_lwc = []
n=1;


% 
cvitimes = ncread(wviso_nc,'time');
for t=cvitimes'
    if ~isnan(cutsize(cvitimes==t))
         [val,idx] = min(abs(all_edges-cutsize(cvitimes==t)));
    else
        idx = 1;
    end
    [val,nc_idx] = min(abs(time-t));
    mass_matrix = conc(:,nc_idx)*1e6.*mass;
    cdp_cut_lwc(n) = sum(mass_matrix(idx:end));
    n=n+1;
end
% 
size(cdp_cut_lwc)
% 
% % Reshape the concentration array into two dimensions
% s = size(cdp_conc);
% conc2 = reshape(cdp_conc, [s(1), s(3)]);
% s2 = size(conc2);

%time = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time(:,1));
% 
% % Limit the CDP to sizes larger than 10 um
% % Define large droplet concentration threshold
% % 9 = 10 um
% % 13 = 15 um
% % 15 = 19 um
% bin_edges = all_edges(9:end);
% bins = [];
% for b = 1 : length(bin_edges)-1
%     center = (bin_edges(b) + bin_edges(b+1))/2;
%     bins = [bins; center];
% end
% 
% cdp_cutsize = conc2(9:end,:);


% % Liquid Water content of Holodec and CDP
% Using density of water, and diameter, calculate LWZ in g/m^3





%% Plot LWC CDP, King, CVI, CUTSIZE CDP, 2DC, 2DS

figure(1)
    p1 = plot(cvitimes, CWC_cvi, "DisplayName", "CVI total water content", "LineStyle", "-","LineWidth", 3);hold on
  p3 = plot(time, cdp2_lwc, "DisplayName", "CDP full", "LineStyle", "-","LineWidth", 2);hold on
      p2 = plot(cvitimes, cdp_cut_lwc, "DisplayName", "CDP above CVI cutsize", "LineStyle", "-","LineWidth", 2);hold on
 % p4 = plot(time, CWC_2DSH, "DisplayName", "2DS-H", "LineStyle", "-","LineWidth", 2);hold on
 %  p5 = plot(time, CWC_HVPS, "DisplayName", "HVPS", "LineStyle", "-","LineWidth", 2);hold on
  p5 = plot(time, king, "DisplayName", "King LWC", "LineStyle", "-","LineWidth", 2);hold on
 
    ylabel('LWC (g/m3)');


    grid on
    xlabel('Time')
    legend();
    %title([flightnumber ' ' flightdate])




end



