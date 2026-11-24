%#######################################################################
%
%                     * Femur CARTilage Program *
%
%          M-File which preprocesses the new (Erin's) biomarkers femur
%     data by checking and improving the cartilage meshes using
%     tri_fix2.m.  The data is saved to MAT files *sc.mat.
%
%     NOTES:  1.  MAT files *EAbc7tsc.mat must be in the subdirectory
%             "Biomarker MAT files".
%
%             2.  The M-file tri_fix2.m must be in the current path or
%             directory.
%
%     26-Nov-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Data Directory and File Names
%
if ismac
  ddir = '';
else
  ddir = 'Biomarker MAT files\';
end
d = dir(fullfile(ddir,'*EAbc7tsc.mat'));
fnams = deblank(char(d.name));
nf = size(fnams,1);     % Number of files
%
% Loop through MAT Files
%
for kf = 1:nf           % Loop through MAT files
%
   fnam = fnams(kf,:);                 % File name
   idot = strfind(fnam,'.');
   fstr = fnam(1:idot-1);              % File name w/o extension
%
% Load Data
%
   load(fullfile(ddir,fnam));
%
% Check and Improve Cartilage Mesh
%
   trisc = tri_fix2(trisc,xyzsc);      % Not necessary?  Check of mesh
%
% Save Data
%
   fsav = fullfile(ddir,fnam);
   save(fsav,'datsb','datsc','trisb','trisc','trzsc', ...
        'xyzsb','xyzsc');
%
   fprintf(1,'File number %i completed!\n',kf);
%
end
%
return