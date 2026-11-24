%#######################################################################
%
%            * RUN Femur Scale Coordinates 3 All Program *
%
%          M-File which reads radius and width data from MS-Excel
%     spreadsheet, f14a.xlsx, to calculate scaling factors which are
%     saved to the MAT file, fscale3.mat.  The unscaled and scaled bony
%     geometry are plotted and saved to the file run_fsc3a.ps.
%
%     NOTES:  1.  The MS-Excel spreadsheet f14a.xlsx must be in the
%             current directory.
%
%             2.  The MAT data files must be in the "Biomarker MAT
%             files" directory.
%
%             3.  The M-files coord_tf.m, coord_rx.m, coord_sc.m,
%             cyl_fit.m, cyl_plt.m, dist2cyl.m, f_cs_14.m, plt_datsl.m,
%             pt2line.m, pts2lin.m, sl_info.m and tri_area.m must be
%             in the current path or directory.
%
%     08-Aug-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Data Directory and File Names
%
ddir = 'Biomarker MAT files';
d = dir(fullfile(ddir,'*_BAbc.mat'));
fnams = char({d.name}');
%
nf = size(fnams,1);     % 'Number of files
%
% Read Scaling Data from MS-Excel Spreadsheet f14a.xlsx
%
[num,txt,raw] = xlsread('f14a.xlsx');
%
rc = num(:,7);          % Cylinder radii
yr1 = num(:,8);         % Femoral shaft MRI CS X axis range at two time points
yr2 = num(:,9);         % Femoral shaft femur CS Y axis range at two time points
%
% Get Scaling Factors
%
rcm = mean(rc);         % Mean radii
yr1m = mean(yr1);       % Mean width range in MRI CS
yr2m = mean(yr2);       % Mean width range in femur CS
%
rsf = repmat(rcm,nf,1)./rc;            % Radii scaling factor
ysf1 = repmat(yr1m,nf,1)./yr1;         % Y axis scaling factor in MRI CS
ysf2 = repmat(yr2m,nf,1)./yr2;         % Y axis scaling factor in femur CS
%
% Save Scale Factors
%
save fscale3 ddir fnams rc rsf yr1 yr2 ysf1 ysf2
%
% Open Figure
%
hf = figure;
orient landscape;
%
% Loop through MAT Files
%
for kf = 1:nf           % Loop through MAT files
%
   fnam = fnams(kf,:);                 % File name
   idot = strfind(fnam,'.');
   fstr = fnam(1:idot-1);              % File name w/o extension
   ileg = strcmp(fstr(5),'L');         % True for left leg
%
% Read Data Files from Directories
%
   load(fullfile(ddir,fnam));
%
% Transform to Femur Coordinate System
%
   [datlbt,datmbt,dattbt] = coord_tf(xyzo,xyzax',datlb,datmb,dattb);
%
% Reflect Right Knees
%
   if ileg
     datlbr = datlbt;
     datmbr = datmbt;
     dattbr = dattbt;
   else
     [datlbr,datmbr,dattbr] = coord_rx(datlbt,datmbt,dattbt);
   end
%
% Plot Unscaled Data
%
   ha = subplot(1,2,1);
   view(3);
   hold on;
   axis equal;
   plt_datsl(datlbr,'b.-',0.5);
   plt_datsl(datmbr,'g.-',0.5);
   plt_datsl(dattbr,'m.-',0.5);
%
   if (kf==nf)
     quiver3(zeros(1,3),zeros(1,3),zeros(1,3),[1 0 0],[0 1 0], ...
             [0 0 1],30,'Color','k','LineWidth',3)
     xlabel('X (mm)','FontSize',12,'FontWeight','bold');
     ylabel('Y (mm)','FontSize',12,'FontWeight','bold');
     zlabel('Z (mm)','FontSize',12,'FontWeight','bold');
     ttxt = {'Unscaled'; '(Blue - Lateral)'};
     title(ttxt,'FontSize',16,'FontWeight','bold','interpret','none');
   end
%
% Scale Data
%
   [datlbs,datmbs,dattbs] = coord_sc(rsf(kf),ysf2(kf), ...
                                     datlbr,datmbr,dattbr);
%
% Plot Scaled Data
%
   ha = subplot(1,2,2);
   view(3);
   hold on;
   axis equal;
   plt_datsl(datlbs,'b.-',0.5);
   plt_datsl(datmbs,'g.-',0.5);
   plt_datsl(dattbs,'m.-',0.5);
%
end
%
% Finish Plot
%
quiver3(zeros(1,3),zeros(1,3),zeros(1,3),[1 0 0],[0 1 0], ...
        [0 0 1],30,'Color','k','LineWidth',3)
axis equal;
xlabel('X (mm)','FontSize',12,'FontWeight','bold');
ylabel('Y (mm)','FontSize',12,'FontWeight','bold');
zlabel('Z (mm)','FontSize',12,'FontWeight','bold');
ttxt = {'Scaled'; '(Blue - Lateral)'};
title(ttxt,'FontSize',16,'FontWeight','bold','interpret','none');
%
% Save Plot
%
print('-dpsc2','-r600','run_fsc3a.ps');
%
return