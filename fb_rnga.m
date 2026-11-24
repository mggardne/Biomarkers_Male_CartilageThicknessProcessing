%#######################################################################
%
%                   * Femur Bone RaNGe All Program *
%
%          M-File which reads the scaled femur data to get the femur
%     coordinate range and generate a "standard" quadrilateral mesh in
%     the cylindrical coordinate system.  The resulting "standard" mesh
%     is saved to MAT file fb_rnga.mat.
%
%     NOTES:  1.  The MAT file fscale3.mat must be in the current
%             directory.
%
%             2.  The MAT data files must be in the "Biomarker MAT
%             files" directory.
%
%     08-Aug-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Data Directory and File Names
%
if ismac
  ddir = '';
else
  ddir = 'Biomarker MAT files\';
end
d = dir(fullfile(ddir,'*EAbc7t.mat'));
fnams = deblank(char(d.name));
%
nf = size(fnams,1);     % Number of files
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
   fnam = fnams(kf,:);                 % File name
   idot = strfind(fnam,'.');
   fstr = fnam(1:idot-1);              % File name w/o extension
%
% Load Data
%
   load(fnam);
%
% Transform to Cylindrical Coordinate System
%
   xyzlb = cell2mat(datlb);
   xyzmb = cell2mat(datmb);
   xyztb = cell2mat(dattb);
%
   xyz = [xyzmb; xyztb; xyzlb];
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
tzmn = fix(tzrmn(1:2));                % Get degrees/millimeters closest to zero
tzmx = fix(tzrmx(1:2));                % Get degrees/millimeters closest to zero
%
t = (tzmn(1):2:tzmx(1))';              % Theta range in 2 degrees increments
nt = size(t,1);
% z = (tzmn(2):2:tzmx(2))';              % Z range in 2 mm increments
z = (tzmn(2):tzmx(2))';                % Z range in 1 mm increments
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
save fb_rnga nq quad tq zq trig tzrmn tzrmx
%
return