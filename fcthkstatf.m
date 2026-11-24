%#######################################################################
%
%        * Femur Cartilage THicKness STATistics Male Program *
%
%          M-File which reads the femur cartilage thicknesses for the
%     male case knees, breaks down the thicknesses by injured and
%     uninjured knees, does pairwise T-tests and writes p-values to CSV
%     files (fcthkbmm_?.csv).
%
%     NOTES:  1.  Assumes only case males are in the MAT file.
%
%             2.  MAT file fcthkm.mat must be in the current
%             directory.
%
%             3.  The MS-Excel spreadsheets Partitions6_fm.csv and 
%             Biomark_MRI_StudyKey.xls must be in the current directory.
%
%             4.  P-values are output to fcthkbmm_?.csv files for each
%             of the six regions.
%
%             5.  Requires the Matlab Statistics toolbox.
%
%             6.  M-file bmsubj_fil.m must be in the current path or
%             directory.
%
%             7.  See fcthkbmm_?.csv files where ? is 1-6 for p-values.
%
%     28-Aug-2015 * Mack Gardner-Morse
%

%#######################################################################
%
% Get the Femur Cartilage Thicknesses
%
load fcthkf.mat;
npts = size(cthk,2);
nmf = size(cthk,1);
%
% Get Femur Regions
%
idreg = csvread('Partitions6_fm.csv');
%
% Get Injured and Uninjured Knees
%
[fncase,fcase] = bmsubj_fil(7);
fnamsi = char(fncase(:));
nk = size(fnamsi,1);
%
idx = find(fnamsi(:,4)==' ');          % Index to single digit numbers
fnamsi(idx,:) = [repmat('0',size(idx,1),1) fnamsi(idx,1:3)];
%
[~,~,idm] = intersect(fnams(:,2:5),fnamsi,'rows');
%
inj = false(nmf,1);
idi = find(idm<=nk/2);  % Index to injured knees
inj(idi) = true;
idu = find(~inj);       % Index to uninjured knees
%
% Get Femur Cartilage Thicknesses for Injured and Uninjured Knees
%
cthk_i = cthk(idi,:);   % Thicknesses for injured knees
cthk_u = cthk(idu,:);   % Thicknesses for uninjured knees
%
idvi = ~isnan(cthk_i);  % Valid thicknesses for injured knees
idvu = ~isnan(cthk_u);  % Valid thicknesses for uninjured knees
%
% Find Differences with >=20% of the 10 Subjects
%
ddv = 2*idvi-idvu;      % Valid differnces
id2 = find(ddv==2);     % No matching contralateral thickness
ddv(id2) = 0;
id1 = find(ddv==-1);    % No matching injured thickness
ddv(id1) = 0;
nd = sum(ddv);
%
idp = find(nd>2);       % Points with n >=20% of N
%
% Thicknesses That Make Differences
%
cthkwi = (cthk_i.*ddv)./ddv;
cthkwu = (cthk_u.*ddv)./ddv;
%
% Do Pairwise T-Tests and Write to CSV Files
% See fcthkbmm_?.csv files.
%
cnam = 'fcthkbmf_';
for m = 1:6             % Six regions
   idr = find(idreg==m);
   id = intersect(idr,idp);
   [h,tt] = ttest(cthkwi(:,id),cthkwu(:,id));         % T-tests
   csvwrite([cnam int2str(m) '.csv'],[id(:) tt(:)]);  % Write to CSV files
end
%
return