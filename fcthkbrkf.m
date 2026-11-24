%#######################################################################
%
%         * Femur Cartilage THicKness BReaKdown Male Program *
%
%          M-File which reads the femur cartilage thicknesses for male
%     knees and breaks it down by injured and uninjured contralateral
%     knees.  Plots are generated for these breakdowns and side-to-side
%     differences.
%
%     NOTES:  1.  MAT file fb_rngm.mat and fcthkm.mat must
%             be in the current directory.
%
%             2.  MS-Excel file Biomark_MRI_StudyKey.xlsx must also be
%             in the current directory.
%
%             3.  M-files bmsubj_fil.m must be in the current path or
%             directory.
%
%             4.  Thicknesses and differences in thicknesses are saved
%             to the MAT file:  fcthkbrkm.mat
%
%             5.  Plots are output to fcthkbrkm_thk.ps and
%             fcthkbrkm_diff.ps files.
%
%             6.  All 20 knees are male cases.
%
%     28-Aug-2015 * Mack Gardner-Morse
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
load fb_rngm.mat;
nqe = size(quad,1);     % Number of quadrilateral elements
%
% Load Cartilage Thicknesses
%
load fcthkm.mat;
nf = size(fnams,1);     % Number of files
%
% Get Index to All of the Knees
%
ida = (1:nf)';          % Index to all 20 knees
ids = (1:2:nf)';        % Index to pairs of knees
nsets = size(ids,1);    % Number of pairs (sets) of knees
%
% Load Case File Names and Flags
%
% [fnam2,flags] = bmsubj_fil(7);
% fnam1 = char(fnam2(:,1));
% fnam2 = char(fnam2(:,2));
[fncase, flcase, fncont, flcont] = bmsubj_fil;
fnam1 = char(fncont(:,2)); % 
fnam2 = char(fncont(:,3)); % 
%
% Get Matching File IDs
%
idx = find(fnam1(:,4)==' ');          % Index to single digit numbers
fnam1(idx,:) = [repmat('0',size(idx,1),1) fnam1(idx,1:3)];
idx = find(fnam1(:,5)==' ');          % Index to double digit numbers
fnam1(idx,:) = [repmat('0',size(idx,1),1) fnam1(idx,1:4)];
%
idx = find(fnam2(:,4)==' ');          % Index to single digit numbers
fnam2(idx,:) = [repmat('0',size(idx,1),1) fnam2(idx,1:3)];
idx = find(fnam2(:,5)==' ');          % Index to double digit numbers
fnam2(idx,:) = [repmat('0',size(idx,1),1) fnam2(idx,1:4)];
%
% Get Indices for Injured (0) and Uninjured (1) Knees
%
[~,idi] = intersect(fnams(:,1:5),fnam1,'rows');
[~,idu] = intersect(fnams(:,1:5),fnam2,'rows');
%
inj = true(nf,1);
inj(idi) = false;       % Injured = 0, Uninjured = 1
icase = [find(~inj) find(inj)];        % Column 1 = Injured, Column 2 = Uninjured
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
dthk_case = zeros(nq,1);               % Injured - uninjured males
dthkn_case = zeros(nq,1);
dthks_case = zeros(nq,1);
%
% Breakdown by Sex
%
idf_case = ida;         % Males
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
% return
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
save fcthkbrkm.mat cthk* dthk* fnams icase inj
%
% Plot Case Thicknesses
%
np = nq./((tq(nq)-tq(1))/2+1);
idb = [1; np; nq; nq-np+1; 1];
%
clim = [ 0 max(max(cthk_case)) ];      % Maximum = 4.0692
clim = [ 0 4.2];
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
   colormap(jet);
%
% Save Plots
%
   if k==1
     print -dpsc2 -r600 fcthkbrkm_thk.ps
   else
     print -dpsc2 -r600 -append fcthkbrkm_thk.ps
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
colormap(jet);
%
% Save Plot
%
print -dpsc2 -r600 -append fcthkbrkm_thk.ps
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
colormap(jet);
%
% Save Plot
%
print -dpsc2 -r600 -append fcthkbrkm_thk.ps
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
colormap(jet);
%
% Save Plot
%
print -dpsc2 -r600 -append fcthkbrkm_thk.ps
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
colormap(jet);
%
% Save Plot
%
print -dpsc2 -r600 fcthkbrkm_diff.ps
%
colormap(map);
print -dpsc2 -r600 -append fcthkbrkm_diff.ps
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
colormap(jet);
%
% Save Plot
%
print -dpsc2 -r600 -append fcthkbrkm_diff.ps
autoArrangeFigures(3,3);
%
% Set Warnings
%
warning on;
%
return