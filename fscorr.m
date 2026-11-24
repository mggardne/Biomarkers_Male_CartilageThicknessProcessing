%#######################################################################
%
%                 * Femur Shaft CORRelations Program *
%
%          M-File which uses the bony geometry of the biomarker knees
%     to calculate the mean values, standard deviations and correlations
%     between the width of the femur medial and lateral condyles, the
%     femur shaft and the proximal tibia.
%
%     NOTES:  1.  MAT files *Abc.mat must be in the directory
%             "Biomarker MAT files".  The MAT files *CS.mat must be in
%             the directory "..\Biomarkers Tibia Bone Mat Files".
%
%     21-Nov-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Data Directories and File Names
%
ddir = 'Biomarker MAT files';
tdir = '..\Biomarkers Tibia Bone Mat Files';
%
d = dir(fullfile(ddir,'*BAbc.mat'));
d = {d.name}';          %'
%'
e = dir(fullfile(ddir,'*EAbc.mat'));
e = {e.name}';          %'
%
t = dir(fullfile(tdir,'*CS.mat'));
t = {t.name}';          %'
%
nf = size(t,1);
%
% Loop through the Tibia Data Files
%
fnams = repmat(' ',nf,5);
tpw = zeros(nf,1);
fsw = zeros(nf,1);
fcw = zeros(nf,1);
%
for k = 1:nf
   fnamt = char(t(k,:));
   fnamd = [];
   ie = strncmp(t(k,:),e,5);           % Look for matching femur data
   if any(ie)
     fnamd = char(e(ie,:));
   else
     id = strncmp(t(k,:),d,5);         % Look for matching femur data
     if any(id)
       fnamd = char(d(id,:));
     end
   end
   if ~isempty(fnamd)   % If matching femur data
     fnams(k,:) = fnamt(1:5);
     load(fullfile(tdir,fnamt));
     tpw(k) = max(xyzpt(:,2))-min(xyzpt(:,2));
     load(fullfile(ddir,fnamd));
     xyzfs = cell2mat(datfs);
     fsw(k) = max(xyzfs(:,1))-min(xyzfs(:,1));
     xyzfc = cell2mat([datlb; datmb]);
     fcw(k) = max(xyzfc(:,1))-min(xyzfc(:,1));
%     clear dat* xyzpt;
   end
end
%
% Calculate N, Means, SD, Correlations and R^2
%
idv = find(fsw);
dat = [fcw(idv) fsw(idv) tpw(idv)];
n = size(idv,1)
mv = mean(dat)
sd = std(dat)
r = corrcoef(dat)
R2 = r.*r
%
return