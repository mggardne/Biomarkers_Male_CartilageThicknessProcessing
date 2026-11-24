%#######################################################################
%
%                 * RUN Femur MAT Files All Program *
%
%          M-File which transform the femur data to the femur coordinate
%     system and scales the geometry.  The resulting geometry is saved
%     to MAT files *_sc.mat.
%
%     NOTES:  1.  The MAT file fscale3.mat must be in the current
%             directory.
%
%             2.  The MAT data files must be in the "Biomarker MAT
%             files" directory.
%
%             3.  The M-files coord_tf.m, coord_rx.m, coord_sc.m,
%             cyl_fit.m, cyl_plt.m, dist2cyl.m, f_cs_14.m, plt_datsl.m,
%             pt2line.m, pts2lin.m, sl_info.m and tri_area.m  must be
%             in the current path or directory.
%
%     08-Aug-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Load Directory and File Names
%
load fscale3.mat;
%
nf = size(fnams,1);     % Number of files
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
% Load Data
%
   load(fullfile(ddir,fnam));
%
   if exist(fullfile(ddir,[fstr 'm.mat']),'file')
     load(fullfile(ddir,[fstr 'm.mat']));   % Get properly ordered cartilage data
   end
%
% Transform to Femur Coordinate System
%
   [datlbt,datmbt,dattbt,datcpt] = coord_tf(xyzo,xyzax',datlb, ...
                                            datmb,dattb,datcp);
   [datlct,datmct,dattc1t,dattc2t] = coord_tf(xyzo,xyzax',datlc, ...
                                              datmc,dattc1,dattc2);
%
% Reflect Right Knees
%
   if ileg
     datlbr = datlbt;
     datmbr = datmbt;
     dattbr = dattbt;
     datcpr = datcpt;
     datlcr = datlct;
     datmcr = datmct;
     dattc1r = dattc1t;
     dattc2r = dattc2t;
   else
     [datlbr,datmbr,dattbr,datcpr] = coord_rx(datlbt,datmbt, ...
                                              dattbt,datcpt);
     [datlcr,datmcr,dattc1r,dattc2r] = coord_rx(datlct,datmct, ...
                                                dattc1t,dattc2t);
   end
%
% Scale Data
%
   [datlbs,datmbs,dattbs,datcps] = coord_sc(rsf(kf),ysf2(kf), ...
                                           datlbr,datmbr,dattbr,datcpr);
   [datlcs,datmcs,dattc1s,dattc2s] = coord_sc(rsf(kf),ysf2(kf), ...
                                         datlcr,datmcr,dattc1r,dattc2r);
%
% Save Scaled Data
%
   fsav = fullfile(ddir,[fstr '_sc.mat']);
   save(fsav,'datlbs','datlcs','datmbs','datmcs','dattbs', ...
        'datcps','dattc1s','dattc2s','knum','leg','xyzo','xyzax');
%
end
%
return