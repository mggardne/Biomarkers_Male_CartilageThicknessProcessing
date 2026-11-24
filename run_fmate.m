%#######################################################################
%
%                 * RUN Femur MAT Files Erin Program *
%
%          M-File which transform the new (Erin's) femur data to the
%     femur coordinate system and scales the geometry.  The resulting
%     geometry is saved to MAT files *_sc.mat.
%
%     NOTES:  1.  The MAT file fscale3e.mat must be in the current
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
%     11-Nov-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Load Directory and File Names
%
load fscale3e.mat;
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
   [datlcat,datlcct,datlcst,datmcat,datmcct,datmcst,dattcat,dattcct, ...
    dattcst] = coord_tf(xyzo,xyzax',datlca,datlcc,datlcs,datmca, ...
    datmcc,datmcs,dattca,dattcc,dattcs);
%
% Reflect Right Knees
%
   if ileg
     datlbr = datlbt;
     datmbr = datmbt;
     dattbr = dattbt;
     datcpr = datcpt;
     datlcar = datlcat;
     datlccr = datlcct;
     datlcsr = datlcst;
     datmcar = datmcat;
     datmccr = datmcct;
     datmcsr = datmcst;
     dattcar = dattcat;
     dattccr = dattcct;
     dattcsr = dattcst;
   else
     [datlbr,datmbr,dattbr,datcpr] = coord_rx(datlbt,datmbt, ...
                                              dattbt,datcpt);
     [datlcar,datlccr,datlcsr,datmcar,datmccr,datmcsr,dattcar, ...
       dattccr,dattcsr] = coord_rx(datlcat,datlcct,datlcst,datmcat, ...
       datmcct,datmcst,dattcat,dattcct,dattcst);
   end
%
% Scale Data
%
   [datlbs,datmbs,dattbs,datcps] = coord_sc(rsf(kf),ysf2(kf), ...
                                           datlbr,datmbr,dattbr,datcpr);
   [datlcas,datlccs,datlcss,datmcas,datmccs,datmcss,dattcas,dattccs, ...
    dattcss] = coord_sc(rsf(kf),ysf2(kf),datlcat,datlcct,datlcst, ...
    datmcat,datmcct,datmcst,dattcat,dattcct,dattcst);
%
% Save Scaled Data
%
   fsav = fullfile(ddir,[fstr '_sc.mat']);
   save(fsav,'datlbs','datlcas','datlccs','datlcss','datmbs', ...
    'datmcas','datmccs','datmcss','dattbs','datcps','dattcas', ...
    'dattccs','dattcss','knum','leg','xyzo','xyzax');
%
end
%
return