%#######################################################################
%
%   * Femur Cartilage THicKness BReaKdown BioMarkers Male 2 Program *
%
%          M-File which reads the femur cartilage thicknesses for male
%     control knees and combines the injured and uninjured contralateral
%     knees.  Plots are generated for this data.  Means, N, pooled SDs
%     and CIs (based on the pooled SDs) are calculated by femur regions.
%
%     NOTES:  1.  Assumes only control males are in the thickness MAT
%             file.
%
%             2.  MAT files fcthkbrkbmm.mat and fb_rngm.mat must be in
%             the current directory.
%
%             3.  MS-Excel spreadsheets Partitions6_m2.xlsx must be in
%             the current directory.
%
%             4.  Results are output to file fcthkbrkbmm.xlsx with
%             sheets for the cartilage thicknesses and differences.
%
%             5.  Plots are output to file: fcthkbrkbmm2.ps and JPEG
%             files fcthkbrkbmm2_*.jpg.
%
%             6.  Requires the Matlab Statistics toolbox.
%
%     25-Oct-2016 * Mack Gardner-Morse
%

%#######################################################################
%
% Print Plots to PS File
%
% iprt = false;
iprt = true;
%
% Get Control "Standard" Grid
%
load fb_rngm.mat;
%
% Get the Control Femur Cartilage Thicknesses and Thickness Differences
%
load fcthkbrkbmm.mat;
[nmf,npts] = size(cthk);
%
% Get Femur Regions
%
idreg = xlsread('Partitions6_m2.xlsx','Average');
%
% Combine Injured and Uninjured Data
%
cthkn_ctrlc = sum(cthkn_ctrl,2);       % Ns
cthkm_ctrlc = cthk_ctrl;
cthkm_ctrlc(isnan(cthkm_ctrlc)) = 0;
cthkm_ctrlc = sum(cthkm_ctrlc.*cthkn_ctrl,2)./cthkn_ctrlc; % Means
cthks_ctrlc = zeros(npts,1);
for k = 1:npts
   id = ~isnan(cthk(:,k));
   cthks_ctrlc(k) = std(cthk(id,k));   % SDs
end
%
t = tinv(0.975,cthkn_ctrlc-1);
cthkc_ctrlc = (t.*cthks_ctrlc)./sqrt(cthkn_ctrlc);    % 95% CI
%
% Plot Combined Cartilage Thicknesses
%
xtxt = 'Anterior \rightarrow';
ytxt = 'Lateral \rightarrow';
%
ttxt = {'Mean Thicknesses of '; 'Male Control Knees'};
cthkp = cthkm_ctrlc;
%
figure;
orient landscape;
colormap jet;
hp = patch(tq(quad'),zq(quad'),cthkp(quad'),cthkp(quad'), ...
           'FaceColor','interp','EdgeColor','interp');
%
hold on;
axis off
caxis([0 max(cthkp)]);
axlim = axis; 
hx = text(mean(axlim(1:2)),axlim(3)-1,xtxt,'FontSize',18, ...
          'FontWeight','bold','HorizontalAlign','center');
hy = text(axlim(1)+30,mean(axlim(3:4)),ytxt,'FontSize',18, ...
          'FontWeight','bold','HorizontalAlign','center','Rotation',90);
ht = title(ttxt,'FontSize',20,'FontWeight','bold');
hb = colorbar;       % Add color bar
%
% Save Plot
%
if iprt
  print -dpsc2 -r300 fcthkbrkbmm2.ps
  print('-djpeg95','-r600','fcthkbrkbmm2_thk.jpg');
end
%
% Plot Combined N for Cartilage Thicknesses
%
ttxt = {'N for Thicknesses of'; 'Male Control Knees'};
cthkp = cthkn_ctrlc;
idv = find(cthkp==0);
cthkp(idv) = NaN;
%
figure;
orient landscape;
colormap jet;
hp = patch(tq(quad'),zq(quad'),cthkp(quad'),cthkp(quad'), ...
           'FaceColor','interp','EdgeColor','interp');
%
hold on;
axis off
caxis([0 max(cthkp)]);
axlim = axis; 
hx = text(mean(axlim(1:2)),axlim(3)-1,xtxt,'FontSize',18, ...
          'FontWeight','bold','HorizontalAlign','center');
hy = text(axlim(1)+30,mean(axlim(3:4)),ytxt,'FontSize',18, ...
          'FontWeight','bold','HorizontalAlign','center','Rotation',90);
ht = title(ttxt,'FontSize',20,'FontWeight','bold');
hb = colorbar;       % Add color bar
%
% Save Plot
%
if iprt
  print -dpsc2 -r300 -append fcthkbrkbmm2.ps
  print('-djpeg95','-r600','fcthkbrkbmm2_N.jpg');
end
%
% Plot Combined SD for Cartilage Thicknesses
%
ttxt = {'Thickness SDs for'; 'Male Control Knees'};
cthkp = cthks_ctrlc;
%
figure;
orient landscape;
colormap jet;
hp = patch(tq(quad'),zq(quad'),cthkp(quad'),cthkp(quad'), ...
           'FaceColor','interp','EdgeColor','interp');
%
hold on;
axis off
caxis([0 max(cthkp)]);
axlim = axis; 
hx = text(mean(axlim(1:2)),axlim(3)-1,xtxt,'FontSize',18, ...
          'FontWeight','bold','HorizontalAlign','center');
hy = text(axlim(1)+30,mean(axlim(3:4)),ytxt,'FontSize',18, ...
          'FontWeight','bold','HorizontalAlign','center','Rotation',90);
ht = title(ttxt,'FontSize',20,'FontWeight','bold');
hb = colorbar;       % Add color bar
%
% Save Plot
%
if iprt
  print -dpsc2 -r300 -append fcthkbrkbmm2.ps
  print('-djpeg95','-r600','fcthkbrkbmm2_SD.jpg');
end
%
% Plot Combined SD for Cartilage Thicknesses
%
ttxt = {'95% Confidence Interval for Thicknesses'; ...
        'of Male Control Knees'};
cthkp = cthkc_ctrlc;
%
figure;
orient landscape;
colormap jet;
hp = patch(tq(quad'),zq(quad'),cthkp(quad'),cthkp(quad'), ...
           'FaceColor','interp','EdgeColor','interp');
%
hold on;
axis off
% caxis([0 max(cthkp)]);
caxis([0 1]);
axlim = axis; 
hx = text(mean(axlim(1:2)),axlim(3)-1,xtxt,'FontSize',18, ...
          'FontWeight','bold','HorizontalAlign','center');
hy = text(axlim(1)+30,mean(axlim(3:4)),ytxt,'FontSize',18, ...
          'FontWeight','bold','HorizontalAlign','center','Rotation',90);
ht = title(ttxt,'FontSize',20,'FontWeight','bold');
hb = colorbar;       % Add color bar
%
% Save Plot
%
if iprt
  print -dpsc2 -r300 -append fcthkbrkbmm2.ps
  print('-djpeg95','-r600','fcthkbrkbmm2_CI.jpg');
end
%
% Calculate Pooled SDs and Calculate 95% CI for Entire Femur
%
id = find(cthkn_ctrlc>1);
ncthk(7,3) = size(id,1);% Six regions plus entire femur = 7 and injured, uninjured and combined = 3
mncthk(7,3) = min(cthkm_ctrlc(id));
mxcthk(7,3) = max(cthkm_ctrlc(id));
mcthk(7,3) = mean(cthkm_ctrlc(id));
cthkn_ctrlcm1 = cthkn_ctrlc(id)-1;
scthk(7,3) = sum(cthks_ctrlc(id).*cthks_ctrlc(id).*cthkn_ctrlcm1);
scthk(7,3) = sqrt(scthk(7,3)./sum(cthkn_ctrlcm1));
t = tinv(0.975,ncthk(7,3)-1);
cicthk(7,3) = (t.*scthk(7,3))./sqrt(ncthk(7,3));
%
for l = 1:6
   idr = find(idreg==l);
   idx = intersect(idr,id);
   ncthk(l,3) = size(idx,1);
   thk = cthkm_ctrlc(idx);
   mncthk(l,3) = min(thk);
   mxcthk(l,3) = max(thk);
   mcthk(l,3) = mean(thk);
   ncthkm1 = cthkn_ctrlc(idx)-1;
   scthk(l,3) = sum(cthks_ctrlc(idx).*cthks_ctrlc(idx).*ncthkm1);
   scthk(l,3) = sqrt(scthk(l,3)./sum(ncthkm1));
   cicthk(l,3) = (t.*scthk(l,3))./sqrt(ncthk(l,3));
end
%
% Calculate Pooled SDs and Calculate 95% CI for Injured and Uninjured
%
for k = 1:2             % First column = injured, second column = uninjured
   idp = find(cthkn_ctrl(:,k)>1);
   ncthk(7,k) = size(idp,1);
   thk = cthk_ctrl(idp,k);
   mncthk(7,k) = min(thk);
   mxcthk(7,k) = max(thk);
   mcthk(7,k) = mean(thk);
   ncthkm1 = cthkn_ctrl(idp,k)-1;
   scthk(7,k) = sum(cthks_ctrl(idp,k).*cthks_ctrl(idp,k).*ncthkm1);
   scthk(7,k) = sqrt(scthk(7,k)./sum(ncthkm1));
   cicthk(7,k) = (t.*scthk(7,k))./sqrt(ncthk(7,k));
%
   for l = 1:6
      idr = find(idreg==l);
      id = intersect(idr,idp);
      ncthk(l,k) = size(id,1);
      thk = cthk_ctrl(id,k);
      mncthk(l,k) = min(thk);
      mxcthk(l,k) = max(thk);
      mcthk(l,k) = mean(thk);
      ncthkm1 = cthkn_ctrl(id,k)-1;
      scthk(l,k) = sum(cthks_ctrl(id,k).*cthks_ctrl(id,k).*ncthkm1);
      scthk(l,k) = sqrt(scthk(l,k)./sum(ncthkm1));
      cicthk(l,k) = (t.*scthk(l,k))./sqrt(ncthk(l,k));
   end
end
%
% Calculate Pooled SDs and Calculate 95% CI for Entire Femur for
% Cartilage Thickness Differences
%
id = find(dthkn_ctrl>1);
ndthk(7,1) = size(id,1);% Six regions plus entire femur = 7
mndthk(7,1) = min(dthk_ctrl(id));
mxdthk(7,1) = max(dthk_ctrl(id));
mdthk(7,1) = mean(dthk_ctrl(id));
dthkn_ctrlm1 = dthkn_ctrl(id)-1;
sdthk(7,1) = sum(dthks_ctrl(id).*dthks_ctrl(id).*dthkn_ctrlm1);
sdthk(7) = sqrt(sdthk(7)./sum(dthkn_ctrlm1));
t = tinv(0.975,ndthk(7)-1);
cidthk(7,1) = (t.*sdthk(7))./sqrt(ndthk(7));
%
for l = 1:6
   idr = find(idreg==l);
   idx = intersect(idr,id);
   ndthk(l) = size(idx,1);
   thk = dthk_ctrl(idx);
   mndthk(l) = min(thk);
   mxdthk(l) = max(thk);
   mdthk(l) = mean(thk);
   ndthkm1 = dthkn_ctrl(idx)-1;
   sdthk(l) = sum(dthks_ctrl(idx).*dthks_ctrl(idx).*ndthkm1);
   sdthk(l) = sqrt(sdthk(l)./sum(ndthkm1));
   cidthk(l) = (t.*sdthk(l))./sqrt(ndthk(l));
end
%
% Write Thickness Region Data to MS-Excel Spreadsheet
%
xlsnam = 'fcthkbrkbm.xlsx';            % XLSX file name
shtnam = 'Male Control Thickness';     % Sheet name
hdr = {'Injured' 'Uninjured' 'Combined'};
rnams = {'Lateral Posterior';          % Region names
         'Lateral Central';
         'Lateral Anterior';
         'Medial Posterior';
         'Medial Central';
         'Medial Anterior';
         'Entire Femur'};
%
irow = 1;
dat = ncthk;
xlswrite(xlsnam,{'Number of Points for Cartilage Thicknesses'}, ...
         shtnam,['A' int2str(irow)]);
xlswrite(xlsnam,hdr,shtnam,['B' int2str(irow+1)]);
xlswrite(xlsnam,rnams,shtnam,['A' int2str(irow+2)]);
xlswrite(xlsnam,dat,shtnam,['B' int2str(irow+2)]);
%
irow = irow+10;
dat = mncthk;
xlswrite(xlsnam,{'Minimum Cartilage Thicknesses'},shtnam, ...
         ['A' int2str(irow)]);
xlswrite(xlsnam,hdr,shtnam,['B' int2str(irow+1)]);
xlswrite(xlsnam,rnams,shtnam,['A' int2str(irow+2)]);
xlswrite(xlsnam,dat,shtnam,['B' int2str(irow+2)]);
%
irow = irow+10;
dat = mxcthk;
xlswrite(xlsnam,{'Maximum Cartilage Thicknesses'},shtnam, ...
         ['A' int2str(irow)]);
xlswrite(xlsnam,hdr,shtnam,['B' int2str(irow+1)]);
xlswrite(xlsnam,rnams,shtnam,['A' int2str(irow+2)]);
xlswrite(xlsnam,dat,shtnam,['B' int2str(irow+2)]);
%
irow = irow+10;
dat = mcthk;
xlswrite(xlsnam,{'Average Cartilage Thicknesses'},shtnam, ...
         ['A' int2str(irow)]);
xlswrite(xlsnam,hdr,shtnam,['B' int2str(irow+1)]);
xlswrite(xlsnam,rnams,shtnam,['A' int2str(irow+2)]);
xlswrite(xlsnam,dat,shtnam,['B' int2str(irow+2)]);
%
irow = irow+10;
dat = scthk;
xlswrite(xlsnam,{'SD of Cartilage Thicknesses'},shtnam, ...
         ['A' int2str(irow)]);
xlswrite(xlsnam,hdr,shtnam,['B' int2str(irow+1)]);
xlswrite(xlsnam,rnams,shtnam,['A' int2str(irow+2)]);
xlswrite(xlsnam,dat,shtnam,['B' int2str(irow+2)]);
%
irow = irow+10;
dat = cicthk;
xlswrite(xlsnam,{'95% CI of Cartilage Thicknesses'},shtnam, ...
         ['A' int2str(irow)]);
xlswrite(xlsnam,hdr,shtnam,['B' int2str(irow+1)]);
xlswrite(xlsnam,rnams,shtnam,['A' int2str(irow+2)]);
xlswrite(xlsnam,dat,shtnam,['B' int2str(irow+2)]);
%
% Write Thickness Differences Region Data to MS-Excel Spreadsheet
%
shtnam = 'Male Control Differences';   % Sheet name
%
irow = 1;
dat = ndthk;
xlswrite(xlsnam,{['Number of Points for Cartilage Thickness', ...
         ' Differences']},shtnam,['A' int2str(irow)]);
xlswrite(xlsnam,rnams,shtnam,['A' int2str(irow+1)]);
xlswrite(xlsnam,dat,shtnam,['B' int2str(irow+1)]);
%
irow = irow+9;
dat = mndthk;
xlswrite(xlsnam,{'Minimum Cartilage Thickness Differences'},shtnam, ...
         ['A' int2str(irow)]);
xlswrite(xlsnam,rnams,shtnam,['A' int2str(irow+1)]);
xlswrite(xlsnam,dat,shtnam,['B' int2str(irow+1)]);
%
irow = irow+9;
dat = mxdthk;
xlswrite(xlsnam,{'Maximum Cartilage Thickness Differences'},shtnam, ...
         ['A' int2str(irow)]);
xlswrite(xlsnam,rnams,shtnam,['A' int2str(irow+1)]);
xlswrite(xlsnam,dat,shtnam,['B' int2str(irow+1)]);
%
irow = irow+9;
dat = mdthk;
xlswrite(xlsnam,{'Average Cartilage Thickness Differences'},shtnam, ...
         ['A' int2str(irow)]);
xlswrite(xlsnam,rnams,shtnam,['A' int2str(irow+1)]);
xlswrite(xlsnam,dat,shtnam,['B' int2str(irow+1)]);
%
irow = irow+9;
dat = sdthk;
xlswrite(xlsnam,{'SD of Cartilage Thickness Differences'},shtnam, ...
         ['A' int2str(irow)]);
xlswrite(xlsnam,rnams,shtnam,['A' int2str(irow+1)]);
xlswrite(xlsnam,dat,shtnam,['B' int2str(irow+1)]);
%
irow = irow+9;
dat = cidthk;
xlswrite(xlsnam,{'95% CI of Cartilage Thickness Differences'}, ...
         shtnam,['A' int2str(irow)]);
xlswrite(xlsnam,rnams,shtnam,['A' int2str(irow+1)]);
xlswrite(xlsnam,dat,shtnam,['B' int2str(irow+1)]);
%
return