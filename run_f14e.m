%#######################################################################
%
%           * RUN Femur Coordinate System 14 Erin Program *
%
%          M-File which runs femur coordinate system function on the new
%     (Erin's) biomarkers subchondral bone MAT files and plots the
%     coordinate system.  Possible scaling parameters are output to the
%     MS-Excel file, "f14e.xlsx".  The coordinate transformation is
%     saved in the original MAT files.
%
%     NOTES:  1.  The MAT data files must be in the "Biomarker MAT
%             files" directory.
%
%             2.  The M-files cyl_fit.m, cyl_plt.m, dist2cyl.m,
%             f_cs_14.m, plt_datsl.m, pt2line.m, pts2lin.m, sl_info.m
%             and tri_area.m  must be in the current path or directory.
%
%             3.  Requires the Matlab optimization toolbox.
%
%     11-Nov-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Data Directory and File Names
%
ddir = 'Biomarker MAT files';
d = dir(fullfile(ddir,'*_EAbc7t.mat'));
fnams = char({d.name}'); %' File names
%
nf = size(fnams,1);     % Number of files
%
% MS-Excel Spreadsheet File Name and Initialize Output Row
%
xnam = 'f14e.xlsx';
irow = 3;
%
% Figures
%
hf = figure;
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
% Get Femur Coordinate Axis and Plot Data
%
   [xyzo,xyzax,xyzlnx,r,s,sc,sy,sse,fh] = f_cs_14(datlb,datmb,datfs, ...
                                               datcp,true,hf);
%
% Save Data
%
   save(fullfile(ddir,fnam),'-append','xyzo','xyzax');
%
   xlswrite(xnam,{fstr},1,['A' int2str(irow)]);
   xlswrite(xnam,[xyzo xyzax(1,:)],1,['B' int2str(irow)]);
   data = [r,s(1),sc(2),sy];
   xlswrite(xnam,data,1,['H' int2str(irow)]);
   irow = irow+1;
%
% Finish Plot
%
   axis equal;
   ttxt = {fstr; 'Blue - Lateral'};
   title(ttxt,'FontSize',16,'FontWeight','bold','interpret','none');
%
% Save Plot
%
   print('-dpsc2','-r600',[fstr '_cs14e.ps']);
   clf(hf);
%
end
%
return