%#######################################################################
%
%           * Femur Cartilage THicKnesses Plot 26 Program *
%
%          M-File which reads femur cartilage and subchondral bone MAT
%     files and plots the cartilage thicknesses.  The cartilage
%     thickness data is in the MAT file, fcthka26.mat.
%
%     NOTES:  1.  The MAT geometry files must be in the "Biomarker MAT
%             files" directory.
%
%             2.  The cartilage and subchondral bone MAT files must end
%             with "sc.mat".
%
%             3.  MAT files fb_rnga.mat and fcthka26.mat must be in the
%             current directory.
%
%     30-Nov-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Get "Standard" Grid
%
load fb_rnga.mat;
%
% Make Figure Handles and Set Color Axis
%
close all;
%
hf1 = figure;
hf2 = figure;
hf3 = figure;
%
% cax = [0.1743 8.6768];
% cax = [0.1743 6.1260];
% cax = [0.2390 11.6814];
cax = [0.2390 5.41];
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
% Load Cartilage Thickness Data
%
load fcthka26.mat;
%
% Initialize Variables
%
% iprt = false;
iprt = true;
rad2deg = 180/pi;       % Radians to degrees
%
% Initialize Variables
%
% iprt = false;
iprt = true;
rad2deg = 180/pi;       % Radians to degrees
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
%    d = dir(fullfile(ddir,[fstr(1:8) '*_sc.mat']));    % Check for modified data
%    fn = sortrows(char(d.name));
%    nfsz = size(fn,1);
%    fn = fn(nfsz,:);     % Use the most modified data
%
   load(fullfile(ddir,fnam));
%
% Get Cylindrical Coordinates
%
   r = rq(kf,:)';
   z = zqs(kf,:)';
   tzrg = [tq z r];
%
% Back to Cartesian Coordinates
%
   [xg,zg,yg] = pol2cart(tzrg(:,1)/rad2deg,tzrg(:,3),tzrg(:,2));
   xyzg = [xg yg zg];
%
% Plot Cartilage Mesh
%
   figure(hf1);
   orient landscape;
   hc1 = trimesh(trisc,xyzsc(:,1),xyzsc(:,2),xyzsc(:,3), ...
                 'LineWidth',0.25,'FaceColor','none','EdgeColor','b');
   hold on;
   view(130,20);
   axis equal;
%
% Plot Bone Mesh
%
   hb = trimesh(trisb,xyzsb(:,1),xyzsb(:,2),xyzsb(:,3), ...
                'LineWidth',0.25,'FaceColor','none','EdgeColor','k');
   axis equal;
%
   xlabel({'X (mm)'; ...
          '\leftarrow anterior / posterior \rightarrow'}, ...
          'FontSize',12,'FontWeight','bold');
   ylabel({'Y (mm)'; ...
          '\leftarrow medial / lateral \rightarrow'}, ...
          'FontSize',12,'FontWeight','bold');
   zlabel({'Z (mm)'; ...
          '\leftarrow inferior / superior \rightarrow'}, ...
          'FontSize',12,'FontWeight','bold');
   title({fstr; 'Cartilage and Bone Meshes'},'Interpreter','none', ...
         'FontSize',16,'FontWeight','bold');
%
% Get Thicknesses and Create Plots
%
   ct = cthk(kf,:)';
%
   figure(hf2);
   orient landscape;
%
   hp2 = patch(xg(quad'),yg(quad'),zg(quad'),ct(quad'), ...
               'FaceColor','interp','EdgeColor','b', ...
               'LineWidth',0.25);
   hold on;
   view(130,20);
   axis equal;
%
   caxis(cax);
%
   hcb = colorbar;
%
   xlabel({'X (mm)'; ...
          '\leftarrow anterior / posterior \rightarrow'}, ...
          'FontSize',12,'FontWeight','bold');
   ylabel({'Y (mm)'; ...
          '\leftarrow medial / lateral \rightarrow'}, ...
          'FontSize',12,'FontWeight','bold');
   zlabel({'Z (mm)'; ...
          '\leftarrow inferior / superior \rightarrow'}, ...
          'FontSize',12,'FontWeight','bold');
   title({fstr; 'Cartilage Thicknesses'},'Interpreter','none', ...
         'FontSize',16,'FontWeight','bold');
%
   figure(hf3);
   orient landscape;
%
   tg = tzrg(:,1);
   zg = tzrg(:,2);
   rg = tzrg(:,3);
%
   hp1 = patch(tg(quad'),zg(quad'),rg(quad'),ct(quad'), ...
                    'FaceColor','interp','EdgeColor','b', ...
                    'LineWidth',0.25);
   hold on;
   view(2);
%
   axis([tzrmn(1) tzrmx(1) tzrmn(2) tzrmx(2)]);
   grid on;
   caxis(cax);
%
   hcb = colorbar;
   xlabel({'\Theta (degrees)'; ...
           '\leftarrow posterior / anterior \rightarrow'}, ...
           'FontSize',12,'FontWeight','bold');
   ylabel({'Z (mm)'; ...
           '\leftarrow medial / lateral \rightarrow'}, ...
           'FontSize',12,'FontWeight','bold');
   zlabel('Radius (mm)','FontSize',12,'FontWeight','bold');
   title({fstr; 'Cartilage Thicknesses'},'Interpreter','none', ...
         'FontSize',16,'FontWeight','bold');
%
% Print Plots
%
   if iprt
     print('-dpsc2','-r300',hf1,[fstr '.ps']);
     print('-dpsc2','-r300','-append',hf2,[fstr '.ps']);
     print('-dpsc2','-r300','-append',hf3,[fstr '.ps']);
   end
%    pause;
   clf(hf1);
   clf(hf2);
   clf(hf3);
%
   fprintf(1,'File number %i completed!\n',kf);
%
end                     % File loop kf
%
return