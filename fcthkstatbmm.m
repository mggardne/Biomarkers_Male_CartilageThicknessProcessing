%#######################################################################
%
%
%   * Femur Cartilage THicKness STATistics BioMarkers Male Program *
%
%          M-File which reads the femur cartilage thicknesses for the
%     biomarkers male control knees, breaks down the thicknesses by
%     injured and uninjured knees, does pairwise T-tests and writes
%     p-values to MS-Excel spreadsheet file:  fcthkstatbmm.xlsx.
%
%     NOTES:  1.  Assumes only control males are in the MAT file.
%
%             2.  MAT file fcthkbrkbmm.mat must be in the current
%             directory.
%
%             3.  The MS-Excel spreadsheets Partitions6_m2.xlsx must be 
%             in the current directory.
%
%             4.  P-values are output to file fcthkstatbmm.xlsx with
%             sheets for each of the six regions.
%
%             5.  Requires the Matlab Statistics toolbox.
%
%             6.  See fcthkstatbmm.xlsx file for p-values.
%
%     29-Sep-2016 * Mack Gardner-Morse
%

%#######################################################################
%
% Get the Femur Cartilage Thicknesses
%
load fcthkbrkbmm.mat;
[nmm,npts] = size(cthk);
%
% Get Femur Regions
%
idreg = xlsread('Partitions6_m2.xlsx','Average');
%
% Get Injured and Uninjured Knees
%
idi = ictrl(:,1);       % Index to injured knees
idu = ictrl(:,2);       % Index to uninjured knees
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
idp = find(nd>=2);      % Points with n >= 2 of the 5 subjects
%
% Thicknesses That Make Differences
%
cthkwi = (cthk_i.*ddv)./ddv;
cthkwu = (cthk_u.*ddv)./ddv;
%
% Do Pairwise T-Tests and Write to MS-Excel Spreadsheet File
% See file fcthkstatbmm.xlsx.
%
xlsnam = 'fcthkstatbmm.xlsx';
rnams = ['pos'; 'ctr'; 'ant'];
cnams = ['lat'; 'med'];
hdr = {'Pt' 'P-value' '' 'Pt' 'P-value' 'Rank' 'Max' '' 'Pt' ...
       'Adj P-val' '' 'Pt' 'Adj P-val' 'Rank'};

%
for k = 1:3             % Regions (1 => Posterior, 2 => Central, 3 => Anterior)
   rnam = rnams(k,:);
   for l = 1:2          % Compartments (1 => Lateral, 2 => Medial)
      shtnam = [cnams(l,:) '_' rnam];
      m = k+(l-1)*3;
      idr = find(idreg==m);
      id = intersect(idr,idp);
      [h,tt] = ttest(cthkwi(:,id),cthkwu(:,id)); % T-tests
      dat = [id(:) tt(:)];
      xlswrite(xlsnam,hdr,shtnam,'A1');          % Write to XLSX file
      xlswrite(xlsnam,dat,shtnam,'A2');          % Write to XLSX file
      nd = size(dat,1);
      dats = [sortrows(dat,2) (1:nd)'];
      xlswrite(xlsnam,dats,shtnam,'D2');         % Write to XLSX file
      xlswrite(xlsnam,nd,shtnam,'G2');           % Write to XLSX file
      dat2 = [dats(:,1) dats(:,2)*nd./dats(:,3)];
      xlswrite(xlsnam,dat2,shtnam,'I2');         % Write to XLSX file
      dat2s = [sortrows(dat2,2) (1:nd)'];
      xlswrite(xlsnam,dat2s,shtnam,'L2');        % Write to XLSX file
   end
end
%
return