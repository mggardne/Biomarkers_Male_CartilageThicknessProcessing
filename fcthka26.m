%#######################################################################
%
%            * Femur Cartilage THicKnesses All 26 Program *
%
%          M-File which reads femur cartilage and subchondral bone MAT
%     files and calculates the cartilage thicknesses.  The cartilage
%     thickness data is saved to the MAT file:  fcthka.mat.
%
%     NOTES:  1.  The MAT data files must be in the "Biomarker MAT
%             files" directory.
%
%             2.  The cartilage and subchondral bone MAT files must end
%             with "sc.mat".
%
%             3.  MAT file fb_rnga.mat must be in the current directory.
%
%             4.  The M-files car_thk5.m, in_tri2d.m. nod2tri.m,
%             nod_norm.m, plane_fit.m, tri_fix2.m, tri_norm.m, tsect4.m
%             and xprod.m must be in the current path or directory.
%
%     08-Aug-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Get "Standard" Grid
%
load fb_rnga.mat;
%
% Make Figure Handles
%
close all;
%
hf1 = figure;
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
% Initialize Variables
%
% iprt = false;
iprt = true;
rad2deg = 180/pi;       % Radians to degrees
%
% Get Tibia CS File Directory
%
%
if ismac
  tdir = 'Biomarkers Tibia Bone Mat Files/';
else
  tdir = '..\Biomarkers Tibia Bone Mat Files';
end
tnams = dir(fullfile(tdir,'*CS.mat'));
tnams = char(tnams.name);
%
% Get Tibia Widths
%
nft = size(tnams,1);
tpw = zeros(nft,1);
for k = 1:nft
   fnamt = tnams(k,:);
   load(fullfile(tdir,fnamt));
   tpw(k) = max(xyzpt(:,2))-min(xyzpt(:,2));
end
tnams = tnams(:,1:5);
tpw_mn = mean(tpw);
%
if exist('fcthka26.mat','file')
    load fcthka26;
else
    cthk = zeros(nf,nq);               % Cartilage thicknesses
    xyzic = zeros(nf,nq,3);            % Cartilage intersection
    rq = zeros(nf,nq);                 % Radial coordinates
    zqs = zeros(nf,nq);                % Polar Z coordinates (scaled)
end
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
%    d = dir([fstr(1:8) '*.mat']);    % Check for modified data
%    fn = sortrows(char(d.name));
%    nfsz = size(fn,1);
%    fn = fn(nfsz,:);     % Use the most modified data
%
   load(fullfile(ddir,fnam));
%
% Get Cylindrical Coordinates
%
   [t,r,z] = cart2pol(xyzsb(:,1),xyzsb(:,3),xyzsb(:,2));
   id = find(t>pi/2);
   t(id) = t(id)-2*pi;
   td = t*rad2deg;      % Angles in degrees
%
% Check Triangle Normals and Make Orientations +R
% Not Necessary For Thickness Calculation, Add this Step to MK_TRI4F.M?
%
%    [nt,nz,nr] = tri_norm(trisb,[td z r]);
%
%    idn = find(nr<0);
%    if ~isempty(idn)
%      trisb(idn,:) = trisb(idn,[1 3 2]);
%    end
%
% Scale Polar "Z" Coordinates
%
   iz = strmatch(fstr(1:5),tnams);
   zsc = tpw(iz)./tpw_mn;
   zs = zsc*zq;
%
% Interpolate to Scaled "Standard" Grid
%
   F = TriScatteredInterp(td,z,r);
   r = F(tq,zs);
   tzrg = [tq zs r];
   it = in_tri2d(trisb,[td z],tzrg(:,1:2));
   tzrg(~it,:) = NaN;
   r(~it) = NaN;
   rq(kf,:) = r';
   zqs(kf,:) = zs';
%
% Back to Cartesian Coordinates
%
   [xg,zg,yg] = pol2cart(tzrg(:,1)/rad2deg,tzrg(:,3),tzrg(:,2));
   xyzg = [xg yg zg];
%
% Improve the Mesh
%
   trig = tri_fix2(trig,xyzg);
%
% Calculate Cartilage Thicknesses
%
   [ct,bi] = car_thk5(trisc,xyzsc,trig,xyzg,iprt,fstr,[],hf1);
%
% Save Thicknesses and Print Plot
%
   cthk(kf,:) = ct';
   xyzic(kf,:,:) = bi;
   if iprt
     if kf==1
       print('-dpsc2','-r300',hf1,'fcthka26.ps');
     else
       print('-dpsc2','-r300','-append',hf1,'fcthka26.ps');
     end
%      pause;
     clf(hf1);
   end
%
   fprintf(1,'File number %i completed!\n',kf);
%
end                     % File loop kf
%
% Save Data in MAT File
%
save fcthka26 cthk rq xyzic zqs
%
return