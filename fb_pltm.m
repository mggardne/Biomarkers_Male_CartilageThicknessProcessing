%#######################################################################
%
%                   * Femur Bone PLoT Male Program *
%
%          M-File which reads the male femur data and plots the
%     transformed combined bone and cartilage data.
%
%     NOTES:  1.  The MAT data files must be in the "Biomarker MAT
%             files" directory.
%
%             2.  M-file plt_datsl.m must be in the path or directory.
%
%     18-Aug-2015 * Mack Gardner-Morse
%

%#######################################################################
%
% Get Directory and File Names
%
ddir = 'Biomarker MAT files';          % Data directory
d = dir(fullfile(ddir,'*EAbc7t.mat'));
ffnams = char(d.name);
ffnams = sortrows(ffnams);
ffnamss = ffnams(:,2:5);               % Subject ID and leg
nf = size(ffnams,1);
%
% Open Figure
%
hf = figure;
view(3);
hold on;
%
% Loop through MAT Files
%
for kf = 1:nf           % Loop through MAT files
%
   fnam = ffnams(kf,:);                % File name
   idot = strfind(fnam,'.');
   fstr = fnam(1:idot-1);              % File name w/o extension
%
% Load Data
%
   load(fullfile(ddir,fnam));
%
% Plot Combined Data
%
   plt_datsl(datlmtbt,'k.-',0.5,[0.5 0.5 0.5]);
   plt_datsl(datlmtcst,'r.-',0.5);
   plt_datsl(datlmtcat,'g.-',0.5,[0 0.5 0]);
   plt_datsl(datlmtcct,'b.-',0.5);
%
    axis equal 
    title (fstr,'fontsize',24,'fontweight','bold','interpreter','none');
    xlabel('X','fontsize',12,'fontweight','bold');
    ylabel('Y','fontsize',12,'fontweight','bold');
    zlabel('Z','fontsize',12,'fontweight','bold');
    pause;
%
   clf;
   view(3);
   hold on;
%
end
%
return