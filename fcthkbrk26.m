%#######################################################################
%
%          * Femur Cartilage THicKness BReaKdown 26 Program *
%
%          M-File which reads the femur cartilage thicknesses for 26
%     knees and breaks it down by injured and uninjured contralateral
%     knees.  Plots are generated for these breakdowns and side-to-side
%     differences.
%
%     NOTES:  1.  MAT file fb_rnga.mat and fcthka26.mat must
%             be in the current directory.
%
%             2.  MS-Excel file Biomark_MRI_StudyKey.xlsx must also be
%             in the current directory.
%
%             3.  M-files bmsubj_fil.m and get_subj.m must be in the
%             current path or directory.
%
%             4.  Thicknesses and differences in thicknesses are saved
%             to the MAT file:  fcthkbrk26.mat
%
%             5.  Plots are output to fcthkbrk26_thk.ps and
%             fcthkbrk26_diff.ps files.
%
%             6.  All 26 knees are female cases.
%
%     01-Dec-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Set Warnings
%
warning off;
%
% Initialize Variables
%
rad2deg = 180/pi;       % Radians to degrees
%
% Load "Standard" Grid (Mesh)
%
load fb_rnga.mat;
nqe = size(quad,1);     % Number of quadrilateral elements
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
% Load Cartilage Thicknesses
%
load fcthka26.mat;
%
% Get Index to All of the Knees
%
ida = (1:nf)';          % Index to all 26 knees
ids = (1:2:nf)';        % Index to pairs of knees
nsets = size(ids,1);    % Number of pairs (sets) of knees
%
% Load File Names and Flags
%
[fnam2,flags] = bmsubj_fil(7);
fnam1 = char(fnam2(:,1));
fnam2 = char(fnam2(:,2));
%
% Get Matching File IDs
%
[idn,idnum] = get_subj(fnams(ids,:));
[idn1,idnum1] = get_subj(fnam1);
[idn2,idnum2] = get_subj(fnam2);
idxs = zeros(nsets,1);
for k = 1:nsets
   id = find(idnum1==idnum(k));
   if isempty(id)
     id = find(idnum2==idnum(k));
   end
   idxs(k) = id;
end
%
% Get Indices for Injured (0) and Uninjured (1) Knees
%
[fs,idfs] = sort([idnum1(idxs) idnum2(idxs)]');
inj = idfs(:)-1;        % Injured = 0, Uninjured = 1
icase = [find(inj) find(~inj)];
%
% Breakdown by Knee
% Injured/Uninjured Contralateral
%
atxt = 'Anterior \rightarrow';
%
clbl = ['Injured  '
        'Uninjured' ];
%
% Average Thicknesses
%
cthk_case = zeros(nq,2);               % 1st column == injured, 2nd column == uninjured
cthkn_case = zeros(nq,2);
cthks_case = zeros(nq,2);
%
% Side-to-Side Differences
%
dthk_case = zeros(nq,1);               % Injured - uninjured females
dthkn_case = zeros(nq,1);
dthks_case = zeros(nq,1);
%
% Breakdown by Sex
%
idf_case = ida;         % Females
%
% Thicknesses
%
idx0 = icase(:,1);                     % Injured
idx1 = icase(:,2);                     % Uninjured
ct_case(:,:,2) = cthk(idx1,:);         % Cartilage thicknesses for cases
ct_case(:,:,1) = cthk(idx0,:);
dt_case = cthk(idx0,:)-cthk(idx1,:);
%
% Average over All of the Grid Points
%
for l = 1:nq
%
% Get Mean and Standard Deviations for Injured and Uninjured Thicknesses
%
   for k = 1:2
%
      idig = ~isnan(ct_case(:,l,k));
      idig = find(idig);
%
      cthk_case(l,k) = mean(ct_case(idig,l,k));
      cthkn_case(l,k) = size(idig,1);
      cthks_case(l,k) = std(ct_case(idig,l,k));
%
   end
%
% Index to Valid Thickness Differences
%
   idig = ~isnan(dt_case(:,l));
   idig = find(idig);
%
% Get Mean and Standard Deviations
%
   dthk_case(l) = mean(dt_case(idig,l));
   dthkn_case(l) = size(idig,1);
   dthks_case(l) = std(dt_case(idig,l));
%
end
%
% Save the Cartilage Thickness Differences
%
save fcthkbrk26.mat cthk* dthk* fnams icase inj
%
% Plot Case Thicknesses
%
np = nq./((tq(nq)-tq(1))/2+1);
idb = [1; np; nq; nq-np+1; 1];
%
clim = [ 0 max(max(cthk_case)) ];      % Maximum = 4.0692
clim = [ 0 3.8];
%
for k = 1:2
%
   figure;
   orient landscape;
   ha = axes;
   cthkp = cthk_case(:,k);
   idn = find(cthkn_case(:,k)<2);     % Must be a mean of at least two numbers!
   cthkp(idn) = NaN;
%
   ttxt = {'Mean Thicknesses of '; ...
           [deblank(clbl(k,:)) ' Case Knees']};
   [ha,ho] = plt_cprt(tq,zq,cthkp,quad,[tq(idb) zq(idb)],ttxt,clim, ...
                      atxt);
   delete(ho);
   hl = get(gca,'XLabel');
   set(hl,'FontSize',16);
   ylabel('Lateral \rightarrow','FontSize',16,'FontWeight','bold');
   view(2);
   axis normal;
   caxis(clim);
   hb = colorbar;       % Add color bar
%
% Save Plots
%
   if k==1
     print -dpsc2 -r300 fcthkbrk26_thk.ps
   else
     print -dpsc2 -r300 -append fcthkbrk26_thk.ps
   end
%
end
%
% Plot Maximum N for Thicknesses of Cases
%
figure;
orient landscape;
ha = axes;
cthkp = max(cthkn_case,[],2);
clim = [0 max(cthkp)];
idv = find(cthkp==0);
cthkp(idv) = NaN;
ttxt = {'Maximum N for Thicknesses'; ...
        'of Cases'};
[ha,ho] = plt_cprt(tq,zq,cthkp,quad,[tq(idb) zq(idb)],ttxt,clim,atxt);
delete(ho);
hl = get(gca,'XLabel');
set(hl,'FontSize',16);
ylabel('Lateral \rightarrow','FontSize',16,'FontWeight','bold');
view(2);
axis normal;
caxis(clim);
hb = colorbar;       % Add color bar
%
% Save Plot
%
print -dpsc2 -r300 -append fcthkbrk26_thk.ps
%
% Plot Thickness SDs (just Case Injured)
%
figure;
orient landscape;
ha = axes;
i0 = find(cthkn_case<2);
cthkp = cthks_case(:,1);               % Injured knees only
cthkp(i0) = NaN;
ttxt = 'Thickness SDs of Injured Case Knees';
% clim = [0 max(cthkp)];  % Maximum = 1.5111
clim = [0 1];        % Removes long tail on distribution and matches uninjured knees' SD limits
[ha,ho] = plt_cprt(tq,zq,cthkp,quad,[tq(idb) zq(idb)],ttxt,clim,atxt);
delete(ho);
hl = get(gca,'XLabel');
set(hl,'FontSize',16);
ylabel('Lateral \rightarrow','FontSize',16,'FontWeight','bold');
view(2);
axis normal;
caxis(clim);
hb = colorbar;       % Add color bar
%
% Save Plot
%
print -dpsc2 -r300 -append fcthkbrk26_thk.ps
%
% Plot Thickness SDs (just Case Uninjured)
%
figure;
orient landscape;
ha = axes;
i0 = find(cthkn_case<2);
cthkp = cthks_case(:,2);               % Uninjured knees only
cthkp(i0) = NaN;
ttxt = 'Thickness SDs of Uninjured Case Knees';
% clim = [0 max(cthkp)];  % Maximum = 4.6116
clim = [0 1];           % Removes long tail on distribution and matches injured knees' SD limits
[ha,ho] = plt_cprt(tq,zq,cthkp,quad,[tq(idb) zq(idb)],ttxt,clim,atxt);
delete(ho);
hl = get(gca,'XLabel');
set(hl,'FontSize',16);
ylabel('Lateral \rightarrow','FontSize',16,'FontWeight','bold');
view(2);
axis normal;
caxis(clim);
hb = colorbar;       % Add color bar
%
% Save Plot
%
print -dpsc2 -r300 -append fcthkbrk26_thk.ps
%
% Plot Differences for Cases
%
map = jet;
% map(26:39,:) = repmat(0.7,14,3);
map(23:42,:) = repmat(0.7,20,3);       % Expand no difference range
%
% clim = [min(dthk_case) max(dthk_case)];% Minimum = -1.2208, maximum = 1.0489
clim = [-0.6 0.6];      % Truncates tails from distribution
%
figure;
orient landscape;
ha = axes;
idv = find(dthkn_case<2);             % Must be a mean of at least two numbers!
dthk = dthk_case;
dthk(idv) = NaN;
ttxt = {'Injured-Uninjured Thickness Differences'; ...
        'of Cases'};
[ha,ho] = plt_cprt(tq,zq,dthk,quad,[tq(idb) zq(idb)],ttxt,clim,atxt);
delete(ho);
hl = get(gca,'XLabel');
set(hl,'FontSize',16);
ylabel('Lateral \rightarrow','FontSize',16,'FontWeight','bold');
view(2)
axis normal;
caxis(clim);
hb = colorbar;       % Add color bar
%
% Save Plot
%
print -dpsc2 -r300 fcthkbrk26_diff.ps
%
colormap(map);
print -dpsc2 -r300 -append fcthkbrk26_diff.ps
%
% Plot Differences SD for Cases
%
% clim = [min(dthks_case) max(dthks_case)];   % [0 1.2357]
clim = [0 0.95];        % Truncate long tail of distribution
%
figure;
orient landscape;
ha = axes;
idv = find(dthkn_case<2);              % Must be a SD of at least two numbers!
dthk = dthks_case;
dthk(idv) = NaN;
ttxt = {'Injured-Uninjured Thickness Differences SD'; ...
        'of Cases'};
[ha,ho] = plt_cprt(tq,zq,dthk,quad,[tq(idb) zq(idb)],ttxt,clim,atxt);
delete(ho);
hl = get(gca,'XLabel');
set(hl,'FontSize',16);
ylabel('Lateral \rightarrow','FontSize',16,'FontWeight','bold');
view(2);
axis normal;
caxis(clim);
hb = colorbar;       % Add color bar
%
% Save Plot
%
print -dpsc2 -r300 -append fcthkbrk26_diff.ps
%
% Set Warnings
%
warning on;
%
return