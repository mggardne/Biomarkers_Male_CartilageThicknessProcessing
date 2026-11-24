%#######################################################################
%
%   * Femur Cartilage THicKness BReaKdown BioMarkers Male Program *
%
%          M-File which reads the femur cartilage thicknesses for male
%     control knees and breaks it down by injured and uninjured
%     contralateral knees.  Plots are generated for these breakdowns
%     and side-to-side differences.
%
%     NOTES:  1.  MAT file fb_rngm.mat and fcthkm.mat must be in the
%             current directory.
%
%             2.  MS-Excel file Biomark_MRI_StudyKey.xlsx must also be
%             in the current directory.
%
%             3.  M-files bmsubj_fil.m must be in the current path or
%             directory.
%
%             4.  Thicknesses and differences in thicknesses are saved
%             to the MAT file:  fcthkbrkbmm.mat
%
%             5.  Plots are output to fcthkbrkbmm_thk.ps and
%             fcthkbrkbmm_diff.ps files.
%
%             6.  All 10 knees are male controls.
%
%     28-Sep-2016 * Mack Gardner-Morse
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
ida = (1:nf)';          % Index to all 10 knees
ids = (1:2:nf)';        % Index to pairs of knees
nsets = size(ids,1);    % Number of pairs (sets) of knees
%
% Load Control File Names and Flags
%
[~,~,fnam2,flags] = bmsubj_fil(7,9);
fnam1 = char(fnam2(:,2));              % Injured followup
fnam2 = char(fnam2(:,3));              % Uninjured followup
%
% Get Matching File IDs
%
idx = find(fnam1(:,5)==' ');          % Index to single digit numbers
fnam1(idx,:) = [repmat('0',size(idx,1),1) fnam1(idx,1:4)];
%
idx = find(fnam2(:,5)==' ');          % Index to single digit numbers
fnam2(idx,:) = [repmat('0',size(idx,1),1) fnam2(idx,1:4)];
%
% Get Indices for Injured (0) and Uninjured (1) Knees
%
[~,idx0] = intersect(fnams(:,1:5),fnam1,'rows'); % Injured
[~,idx1] = intersect(fnams(:,1:5),fnam2,'rows'); % Uninjured
%
ictrl = [idx0 idx1];    % Column 1 = Injured, Column 2 = Uninjured
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
cthk_ctrl = zeros(nq,2);               % Mean, 1st column == injured, 2nd column == uninjured
cthkn_ctrl = zeros(nq,2);              % N
cthks_ctrl = zeros(nq,2);              % SD
%
% Side-to-Side Differences
%
dthk_ctrl = zeros(nq,1);               % Mean, injured - uninjured males
dthkn_ctrl = zeros(nq,1);              % N
dthks_ctrl = zeros(nq,1);              % SD
%
% Thicknesses
%
ct_ctrl(:,:,2) = cthk(idx1,:);         % Uninjured cartilage thicknesses for controls
ct_ctrl(:,:,1) = cthk(idx0,:);         % Injured cartilage thicknesses for controls
dt_ctrl = cthk(idx0,:)-cthk(idx1,:);   % Injured-uninjured cartilage thickness differences
%
% Average over All of the Grid Points
%
for l = 1:nq
%
% Get Mean and Standard Deviations for Injured and Uninjured Thicknesses
%
   for k = 1:2
%
      idig = ~isnan(ct_ctrl(:,l,k));
      idig = find(idig);
%
      cthk_ctrl(l,k) = mean(ct_ctrl(idig,l,k));
      cthkn_ctrl(l,k) = size(idig,1);
      cthks_ctrl(l,k) = std(ct_ctrl(idig,l,k));
%
   end
%
% Index to Valid Thickness Differences
%
   idig = ~isnan(dt_ctrl(:,l));
   idig = find(idig);
%
% Get Mean and Standard Deviations
%
   dthk_ctrl(l) = mean(dt_ctrl(idig,l));
   dthkn_ctrl(l) = size(idig,1);
   dthks_ctrl(l) = std(dt_ctrl(idig,l));
%
end
%
% Save the Cartilage Thickness Differences
%
save fcthkbrkbmm.mat cthk* dthk* fnams ictrl
%
% Plot Control Thicknesses
%
np = nq./((tq(nq)-tq(1))/2+1);
idb = [1; np; nq; nq-np+1; 1];
%
clim = [ 0 max(max(cthk_ctrl)) ];      % Maximum = 4.0692
clim = [ 0 4.2];
%
for k = 1:2
%
   figure;
   orient landscape;
   colormap jet;
   ha = axes;
   cthkp = cthk_ctrl(:,k);
   idn = find(cthkn_ctrl(:,k)<2);     % Must be a mean of at least two numbers!
   cthkp(idn) = NaN;
%
   ttxt = {'Mean Thicknesses of '; ...
           [deblank(clbl(k,:)) ' Male Control Knees']};
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
     print -dpsc2 -r300 fcthkbrkbmm_thk.ps
   else
     print -dpsc2 -r300 -append fcthkbrkbmm_thk.ps
   end
%
   print('-djpeg95','-r600',['fcthkbrkbmm_thk' int2str(k) '.jpg']);
%
end
%
% Plot Maximum N for Thicknesses of Controls
%
figure;
orient landscape;
colormap jet;
ha = axes;
cthkp = max(cthkn_ctrl,[],2);
clim = [0 max(cthkp)];
idv = find(cthkp==0);
cthkp(idv) = NaN;
ttxt = {'Maximum N for Thicknesses'; ...
        'of Male Controls'};
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
print -dpsc2 -r300 -append fcthkbrkbmm_thk.ps
print('-djpeg95','-r600','fcthkbrkbmm_thk3.jpg');
%
% Plot Thickness SDs (just Control Injured)
%
figure;
orient landscape;
colormap jet;
ha = axes;
i0 = find(cthkn_ctrl<2);
cthkp = cthks_ctrl(:,1);               % Injured knees only
cthkp(i0) = NaN;
ttxt = 'Thickness SDs of Injured Male Control Knees';
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
print -dpsc2 -r300 -append fcthkbrkbmm_thk.ps
print('-djpeg95','-r600','fcthkbrkbmm_thk4.jpg');
%
% Plot Thickness SDs (just Control Uninjured)
%
figure;
orient landscape;
colormap jet;
ha = axes;
i0 = find(cthkn_ctrl<2);
cthkp = cthks_ctrl(:,2);               % Uninjured knees only
cthkp(i0) = NaN;
ttxt = 'Thickness SDs of Uninjured Male Control Knees';
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
print -dpsc2 -r300 -append fcthkbrkbmm_thk.ps
print('-djpeg95','-r600','fcthkbrkbmm_thk5.jpg');
%
% Plot Differences for Controls
%
map = jet;
% map(26:39,:) = repmat(0.7,14,3);
map(23:42,:) = repmat(0.7,20,3);       % Expand no difference range
%
% clim = [min(dthk_ctrl) max(dthk_ctrl)];% Minimum = -1.2208, maximum = 1.0489
clim = [-0.6 0.6];      % Truncates tails from distribution
%
figure;
orient landscape;
colormap jet;
ha = axes;
idv = find(dthkn_ctrl<2);             % Must be a mean of at least two numbers!
dthk = dthk_ctrl;
dthk(idv) = NaN;
ttxt = {'Injured-Uninjured Thickness Differences'; ...
        'of Male Controls'};
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
print -dpsc2 -r300 fcthkbrkbmm_diff.ps
print('-djpeg95','-r600','fcthkbrkbmm_diff1.jpg');
%
colormap(map);
print -dpsc2 -r300 -append fcthkbrkbmm_diff.ps
print('-djpeg95','-r600','fcthkbrkbmm_diff2.jpg');
%
% Plot Differences SD for Controls
%
% clim = [min(dthks_ctrl) max(dthks_ctrl)];   % [0 1.2357]
clim = [0 0.95];        % Truncate long tail of distribution
%
figure;
orient landscape;
colormap jet;
ha = axes;
idv = find(dthkn_ctrl<2);              % Must be a SD of at least two numbers!
dthk = dthks_ctrl;
dthk(idv) = NaN;
ttxt = {'Injured-Uninjured Thickness Differences SD'; ...
        'of Male Controls'};
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
print -dpsc2 -r300 -append fcthkbrkbmm_diff.ps
print('-djpeg95','-r600','fcthkbrkbmm_diff3.jpg');
%
% Set Warnings
%
warning on;
%
return