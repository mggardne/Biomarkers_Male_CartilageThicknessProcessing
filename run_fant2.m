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
% Load Indices for Anterior Regions
%
load fant2.mat
%
% Loop through MAT Files
%
for kf = 1:nf           % Loop through MAT files
%
   fnam = fnams(kf,:);                 % File name
   idot = strfind(fnam,'.');
   fstr = fnam(1:idot-1);              % File name w/o extension
%
   hf = figure;
   orient landscape;
%
% Loop Through Time Points
%
   for kt = 1:2         % Time points 1 and 2
%
% Read Data Files from Directories
%
      ddir = [ddirs int2str(kt) '\'];
%
      load([ddir fnam]);
%
% Plot Data with Anterior Regions
%
      subplot(1,2,kt);
      view(3);
      hold on;
%
      nslice = size(datlb,1);
%
      for ks = 1:nslice
         xyz = datlb{ks};
         hl = plot3(xyz(:,1),xyz(:,2),xyz(:,3),'b.-','LineWidth', ...
                    0.5,'MarkerSize',5);
         ida = idk{kf,kt}{1}{ks};
         idpp = ida(idp{kf,kt}{1}{ks});
         plot3(xyz(idpp,1),xyz(idpp,2),xyz(idpp,3),'go','LineWidth', ...
               0.5,'MarkerSize',3);
         idnp = ida(idn{kf,kt}{1}{ks});
         plot3(xyz(idnp,1),xyz(idnp,2),xyz(idnp,3),'mo','LineWidth', ...
               0.5,'MarkerSize',3);
         np = size(ida,1);
         nc = round(np/2);
         idc = ida(nc);
         plot3(xyz(idc,1),xyz(idc,2),xyz(idc,3),'kd','LineWidth', ...
               0.5,'MarkerSize',4);
      end
%
      nslice = size(datmb,1);
%
      for ks = 1:nslice
         xyz = datmb{ks};
         hm = plot3(xyz(:,1),xyz(:,2),xyz(:,3),'r.-','LineWidth', ...
                    0.5,'MarkerSize',5);
         ida = idk{kf,kt}{2}{ks};
         idpp = ida(idp{kf,kt}{2}{ks});
         plot3(xyz(idpp,1),xyz(idpp,2),xyz(idpp,3),'go','LineWidth', ...
               0.5,'MarkerSize',3);
         idnp = ida(idn{kf,kt}{2}{ks});
         plot3(xyz(idnp,1),xyz(idnp,2),xyz(idnp,3),'mo','LineWidth', ...
               0.5,'MarkerSize',3);
         np = size(ida,1);
         nc = round(np/2);
         idc = ida(nc);
         plot3(xyz(idc,1),xyz(idc,2),xyz(idc,3),'kd','LineWidth', ...
               0.5,'MarkerSize',4);
      end
%
% Finish Plot
%
      axis equal;
      xlabel('X (mm)','FontSize',12,'FontWeight','bold');
      ylabel('Y (mm)','FontSize',12,'FontWeight','bold');
      zlabel('Z (mm)','FontSize',12,'FontWeight','bold');
      ttxt = {[fstr ' Time ' int2str(kt)]; 'Blue - Lateral'};
      title(ttxt,'FontSize',16,'FontWeight','bold','interpret','none');
%
   end
%
% Save Plot
%
   print('-dpsc2','-r600',[fstr '_ant2.ps']);
   pause;
%   close(hf);
%
end
%
return