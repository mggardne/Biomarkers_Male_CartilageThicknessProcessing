%#######################################################################
%
%
% Femur Cartilage THicKness Confidence Interval BioMarkers Male Program 
%
%          M-File which reads the femur cartilage thickness differences
%     for the biomarkers male control knees and plots the control 
%     cartilage thickness differences, calculates and plots the 95% 
%     confidence interval (CI) assuming a zero mean and plots the
%     biomarkers male case cartilage thickness differences that
%     are greater than the confidence interval.
%
%     NOTES:  1.  Control MAT files fcthkbrkbmm.mat and fb_rngm.mat
%             must be in the current subdirectory and case MAT files
%             ..\..\fcthkbrkm.mat and ..\..\fb_rngm.mat must be in
%             their directory.
%
%             2.  Requires the Matlab Statistics toolbox.
%
%     04-Oct-2016 * Mack Gardner-Morse
%

%#######################################################################
%
% Print Plots to PS File
%
iprt = false;
% iprt = true;
%
% PS Output Plot File Name
%
if iprt
  psfnam = 'fcthkcibmm.ps';
end
%
% Get Control "Standard" Grid
%
load fb_rngm.mat;
%
% Get the Control Femur Cartilage Thickness Differences
%
load fcthkbrkbmm.mat;
%
% Plot the Control Mean Differences
%
dthk = dthk_ctrl;
idn = find(dthkn_ctrl<2);
dthk(idn) = NaN;
%
figure;
orient landscape;
colormap jet;
%
hp = patch(tq(quad'),zq(quad'),dthk(quad'),dthk(quad'), ...
           'FaceColor','interp','EdgeColor','interp');
%
caxis([-0.5 0.5]);
hb = colorbar;
title({'Cartilage Thickness Differences'; 'Male Controls'}, ...
       'FontSize',16,'FontWeight','bold');
%
if iprt
  print('-dpsc2','-r300',psfnam);
end
%
% Calculate 95% CI
%
ci = NaN(nq,1);
idv = find(dthkn_ctrl>=2);
t = tinv(0.975,dthkn_ctrl(idv)-1);
ci(idv) = (t.*dthks_ctrl(idv))./sqrt(dthkn_ctrl(idv));
%
% Plot 95% CI
%
figure;
orient landscape;
colormap jet;
%
hp = patch(tq(quad'),zq(quad'),ci(quad'),ci(quad'), ...
           'FaceColor','interp','EdgeColor','interp');
%
caxis([0 0.8]);
hb = colorbar;
title('95% CI for Male Controls','FontSize',16,'FontWeight','bold');
%
if iprt
  print('-dpsc2','-r300','-append',psfnam);
end
%
% Get Case Grid
%
tq_ctrl = tq;
zq_ctrl = zq;
load('..\..\fb_rngm.mat');
%
tmin = max([min(tq_ctrl); min(tq)]);
tmax = min([max(tq_ctrl); max(tq)]);
%
zmin = max([min(zq_ctrl); min(zq)]);
zmax = min([max(zq_ctrl); max(zq)]);
%
% Interpolate Confidence Interval to Case Grid
%
cii = interp2(reshape(tq_ctrl,85,127),reshape(zq_ctrl,85,127), ...
              reshape(ci,85,127),tq,zq);
idt = find(tq>tmax|tq<tmin);
cii(idt) = NaN;         % Make sure any extrapolation is NaN
idq = find(zq>zmax|zq<zmin);
cii(idq) = NaN;         % Make sure any extrapolation is NaN
%
% Get the Case Femur Cartilage Thickness Differences
%
load('..\..\fcthkbrkm.mat');
dthk = dthk_case;
dthk(idt) = NaN;
dthk(idq) = NaN;
%
% Plot the Case Mean Differences
%
idn = find(dthkn_case<3);
dthk(idn) = NaN;
%
figure;
orient landscape;
colormap jet;
%
hp = patch(tq(quad'),zq(quad'),dthk(quad'),dthk(quad'), ...
           'FaceColor','interp','EdgeColor','interp');
%
caxis([-0.6 0.6]);
hb = colorbar;
title({'Cartilage Thickness Differences'; 'Male Cases'}, ...
       'FontSize',16,'FontWeight','bold');
%
if iprt
  print('-dpsc2','-r300','-append',psfnam);
end
%
% Plot the Case Mean Differences Greater Than the Control 95%
% Confidence Interval
%
cii(isnan(cii)) = Inf;
dthk(abs(dthk)<cii) = 0;
%
figure;
orient landscape;
colormap jet;
%
hp = patch(tq(quad'),zq(quad'),dthk(quad'),dthk(quad'), ...
           'FaceColor','interp','EdgeColor','interp');
%
caxis([-0.6 0.6]);
hb = colorbar;
title({'Cartilage Thickness Differences'; ...
       'Male Cases Greater Than 95% CI'}, ...
       'FontSize',16,'FontWeight','bold');
%
if iprt
  print('-dpsc2','-r300','-append',psfnam);
end
%
% Adjust Color Map
%
map = jet;
map(32:33,:) = repmat(0.7,2,3);
colormap(map);
caxis([-0.5 0.5]);
%
close(1:3);
%
% Get Femur Regions
%
load ..\..\fcthkbm_m_regs.mat
%
% Add Regions
%
hold on;
hl1 = plot([-95; 20],[-0.5; -0.5],'k-','LineWidth',2);     % Lateral-medial boundary
hl2 = plot([-145; -145],[-42; -12],'k-','LineWidth',2);    % Posterior medial boundary
hl3 = plot([-145; -145],[6; 37],'k-','LineWidth',2);       % Posterior lateral boundary
%
idla = id1;             % Lateral anterior (trochlea)
idlc = id3;             % Lateral center
ir3 = nod2tri(idla,trig,2);            % Anterior triangles
ir2 = nod2tri(idlc,trig,2);            % Center triangles
bid2 = meshbnd4(trig(ir2,:));          % Center boundary
bid3 = meshbnd4(trig(ir3,:));          % Anterior boundary
%
tzs2 = sortrows([tq(bid2) zq(bid2)],2);
for k = 0:40            % Loop through the z coordinates (every mm)
   id = find(tzs2(:,2)==k);
   tz2(k+1,:) = [max(tzs2(id,1)) k];   % Maximum of center region
end
%
tzs3 = sortrows([tq(bid3) zq(bid3)],2);
for k = 0:40            % Loop through the z coordinates (every mm)
   id = find(tzs3(:,2)==k);
   tz3(k+1,:) = [min(tzs3(id,1)) k];   % Minimum of anterior region
end
tzl = (tz2+tz3)./2;     % Region boundary between the two boundaries
hl4 = plot(tzl(1:35,1),tzl(1:35,2),'k-','LineWidth',2);    % Lateral boundary
%
idma = id2;             % Medial anterior (trochlea)
idmc = id4;             % Medial center
ir6 = nod2tri(idma,trig,2);            % Anterior triangles
ir5 = nod2tri(idmc,trig,2);            % Center triangles
bid5 = meshbnd4(trig(ir5,:));          % Center boundary
bid6 = meshbnd4(trig(ir6,:));          % Anterior boundary
%
tzs5 = sortrows([tq(bid5) zq(bid5)],2);
for k = -42:-1          % Loop through the z coordinates (every mm)
   id = find(tzs5(:,2)==k);
   tz5(abs(k),:) = [max(tzs5(id,1)) k];% Maximum of center region
end
%
tzs6 = sortrows([tq(bid6) zq(bid6)],2);
for k = -42:-1          % Loop through the z coordinates (every mm)
   id = find(tzs6(:,2)==k);
   tz6(abs(k),:) = [min(tzs6(id,1)) k];% Minimum of anterior region
end
tzm = (tz5+tz6)./2;     % Region boundary between the two boundaries
hl5 = plot(tzm(1:36,1),tzm(1:36,2),'k-','LineWidth',2);    % Medial boundary
%
% Add Grid Points
%
idp = find(dthkn_case>2);
np = size(idp,1);
hp = plot3(tq(idp),zq(idp),repmat(2,np,1),'k.','LineWidth',1, ...
           'MarkerSize',6);
%
% Add Labels
%
axlim = axis;
axis off;
text(axlim(1)+45,0,'Lateral \rightarrow','FontSize',16,'FontWeight', ...
     'bold','HorizontalAlignment','center','Rotation',90);
text(sum(axlim(1:2))/2+7,axlim(3)+4,'Anterior \rightarrow', ...
     'FontSize',16,'FontWeight','bold','HorizontalAlignment','center');
axis tight;
%
% Save to JPEG File
%
clear c* d*;
print -djpeg95 -r600 fcthkcibmm.jpg
%
return