% clear variables; close all
load NB_YP_NS_OCEAN_ICE_2006_2020.mat ISN PRES TEMP

% Pressure and temperature as in the CTD reference database for Argo
% Salinity DMQC (see Table 1 in the MOCCA deliverable D4.4.5
% (https://www.euro-argo.eu/content/download/142333/file/D4.4.5%20Report%20on%20the%20update%20of%20the%20CTD%20reference%20database%20for%20Salinity%20DMQC%20in%20the%20Nordic%20Seas_v1.0.pdf)

% get ice flag (from the ISN field in the structure DIST_ICE that is an output from the 
% metaprof_satice functions in the seaice_profile toolbox 
% https://github.com/euroargodev/seaice_profile

ISICE=sum(ISN,1);

pres_int=[10 30;20 50];%;5 25;10 40];
t_ice=-2:0.1:0;
n_t_med=3;

isa_plot(PRES,TEMP,ISICE,pres_int,n_t_med,t_ice)
