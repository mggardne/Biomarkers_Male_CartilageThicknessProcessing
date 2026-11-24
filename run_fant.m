%
% Data Directories and File Names
%
ddirs = 'Ben Reliability Timepoint ';
fnams = [ '012_R_BAbc.mat'
          '014_R_BAbc.mat'
          '015_L_BAbc.mat'
          '018_R_BAbc.mat'
          '020_R_BAbc.mat'
          '026_R_BAbc.mat'
          '029_L_BAbc.mat'
          '032_R_BAbc.mat'
          '034_R_BAbc.mat'
          '036_R_BAbc.mat'
          '039_L_BAbc.mat'
          '042_R_BAbc.mat'
          '044_R_BAbc.mat'
          '046_R_BAbc.mat'
          '048_R_BAbc.mat' ];
%
nf = size(fnams,1);     % Number of files
%
% Initialize Variables
%
idk = cell(nf,2);
idn = cell(nf,2);
idp = cell(nf,2);
idmn = cell(nf,2);
klim = cell(nf,2);
r = cell(nf,2);
%
% Loop Through Time Points
%
for kt = 1:2            % Time points 1 and 2
%
   ddir = [ddirs int2str(kt) '\'];
%
% Loop through MAT Files
%
   for kf = 1:nf        % Loop through MAT files
%
% Read Data Files from Directories
%
      fnam = fnams(kf,:);              % File name
      idot = strfind(fnam,'.');
      fstr = fnam(1:idot-1);           % File name w/o extension
%
      load([ddir fnam]);
%
% Find Posterior Regions
%
      [idkl,idpl,idnl,idmnl,kcutl,rcl,rc2l,fdatl] = fant_k(datlb, ...
                                                           0.02,true);
      system(['ren fant_k.ps ' fstr '_' int2str(kt) '_lat_ant.ps']);
      close all;
%
      [idkm,idpm,idnm,idmnm,kcutm,rcm,rc2m,fdatm] = fant_k(datmb, ...
                                                           0.02,true);
      system(['ren fant_k.ps ' fstr '_' int2str(kt) '_med_ant.ps']);
      close all;
%
      idk{kf,kt} = {idkl idkm};
      idp{kf,kt} = {idpl idpm};
      idn{kf,kt} = {idnl idnm};
      idmn{kf,kt} = {idmnl idmnm};
      klim{kf,kt} = {kcutl kcutm};
      r{kf,kt} = {[rcl rc2l] [rcm rc2m]};
%
   end
end
%
% Save Indices to MAT file
%
save fant2 idk idp idn idmn klim r;
%
return