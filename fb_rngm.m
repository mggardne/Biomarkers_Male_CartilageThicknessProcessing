%#######################################################################
%
%                  * Femur Bone RaNGe Male Program *
%
%          M-File which reads the male femur data to get the femur
%     coordinate range and generate a "standard" quadrilateral mesh in
%     the cylindrical coordinate system.  The resulting "standard" mesh
%     is saved to MAT file fb_rngm.mat.
%
%     NOTES:  1.  The MAT data files must be in the
%             "BM_Male_Femur_MatFiles" directory.
%
%     14-Aug-2015 * Mack Gardner-Morse
%

%#######################################################################
%
% Get Directory and File Names
%
close all; clear all; clc;
ddir = 'BM_Male_Femur_MAT_Files';          % Data directory
d = dir(fullfile(ddir,'*EAbc7t.mat'));
% d = dir([ddir '\' '*EAbc7t.mat']);
ffnams = char(d.name);
ffnamss = ffnams(:,1:5);               % Subject ID and leg
%
% Load File Names and Flags
%
% [fnams,flags] = bmsubj_fil(7);
[fncase, flcase, fncont, flcont] = bmsubj_fil;
fnams = char(fncont(:)); % control knees
flags = [flcont; flcont; flcont];
nk = size(fnams,1);     % Total number of knees
%
idx = find(fnams(:,4)==' ');           % Index to single digit numbers
fnams(idx,:) = [repmat('0',size(idx,1),1) fnams(idx,1:3)];
%
idx = find(fnams(:,5)==' ');           % Index to double digit numbers
fnams(idx,:) = [repmat('0',size(idx,1),1) fnams(idx,1:4)];
%
idm = find(flags(:,1)); % Get males only
%
[fnamsm,~,idmf] = intersect(fnams(idm,:),ffnamss,'rows','stable');
nf = size(fnamsm,1);    % Number of files
ffnams = ffnams(idmf,:);
%
% Initialize Overall Minimums and Maximums
%
tzrmn = zeros(1,3);     % Minimums
tzrmx = zeros(1,3);     % Maximums
%
hpi = pi/2;             % Half pi
dpi = 2*pi;             % Double pi
%
% Loop through MAT Files
%
for kf = 1:nf           % Loop through MAT files
%
   fnam = ffnams(kf,:);                % File name
   idot = strfind(fnam,'.');
   fstr = fnam(1:idot-1);              % File name w/o extension
   ileg = strcmp(fstr(5),'L');         % True for left leg
%
% Load Data
%
   load(fullfile(ddir,fnam));
%
% Plot Bone Data
%
   figure;
   view(3);
   hold on;
   plt_datsl(datlmtbt,'b.-');
   axis equal;
   xlabel('X','FontSize',12,'FontWeight','bold');
   ylabel('Y','FontSize',12,'FontWeight','bold');
   zlabel('Z','FontSize',12,'FontWeight','bold');
   title({fstr;'Case Male'},'FontSize',24,'FontWeight','bold', ...
          'Interpreter','none');
%
% Reflect Right Knees
%
   if ~ileg
     [datlbt,datmbt,dattbt,datlmtbt] = coord_rx(datlbt,datmbt, ...
                                                dattbt,datlmtbt);    % Bone
%      [datlcat,datlcct,datlcst,datmcat,datmcct,datmcst,dattcar, ...
%        dattcct,dattcst,datlmtcat,datlmtcct,datlmtcst] = coord_rx( ...
%        datlcat,datlcct,datlcst,datmcat,datmcct,datmcst,dattcat, ...
%        dattcct,dattcst,datlmtcat,datlmtcct,datlmtcst);
   end
%
% Transform to Cylindrical Coordinate System
%
   xyz = cell2mat(datlmtbt);
%
   [th,r,z] = cart2pol(xyz(:,1),xyz(:,3),xyz(:,2));
   id = find(th>hpi);                  % Greater than pi/2
   th(id) = th(id)-dpi;                % Minus 2*pi
   tzr = [th,z,r];
%
% Get Minimums and Maximums
%
   tzrn = min(tzr);
   tzrx = max(tzr);
%
% Find Overall Minimums and Maximums
%
   itst = tzrn<tzrmn;
   tzrmn(itst) = tzrn(itst);
   itst = tzrx>tzrmx;
   tzrmx(itst) = tzrx(itst);
%
end
%
% Get Range and Make a Rectangular Grid
%
tzrmn(1) = tzrmn(1)*180/pi;            % Convert to degrees
tzrmx(1) = tzrmx(1)*180/pi;            % Convert to degrees
tzmn = floor(tzrmn(1:2));              % Get degrees/millimeters closest to -infinity
tzmx = ceil(tzrmx(1:2));               % Get degrees/millimeters closest to +infinity
%
t = (tzmn(1):2:tzmx(1))';              % Theta range in 2 degrees increments
nt = size(t,1);
% z = (tzmn(2):2:tzmx(2))';              % Z range in 2 mm increments
z = (tzmn(2):tzmx(2)+2)';              % Z range in 1 mm increments
nz = size(z,1);
[T,Z] = meshgrid(t,z);  % Rectangle grid of square quadrilaterals
tq = T(:);              % Grid points as a vector
zq = Z(:);              % Grid points as a vector
nq = size(tq,1);
%
quad = (1:nz-1)';
quad = [quad quad+nz quad+nz+1 quad+1];
quad = repmat(quad,nt-1,1);
addcol = repmat(nz*(0:nt-2),(nz-1)*4,1);
addcol = reshape(addcol,4,(nt-1)*(nz-1))';
quad = quad+addcol;
%
% Triangular Grid
%
ne = size(quad,1);      % Number of elements
%
trig = [quad(:,1:3) quad(:,1) quad(:,3:4)]';
trig = reshape(trig,3,2*ne)';
%
% Save Data
%
save fb_rngm ddir ffnams fnamsm nq quad tq zq trig tzrmn tzrmx;
%
return