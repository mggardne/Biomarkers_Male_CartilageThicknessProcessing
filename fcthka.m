%#######################################################################
%
%             * Femur Cartilage THicKnesses All Program *
%
%          M-File which reads femur cartilage and subchondral bone MAT
%     files and calculates the cartilage thicknesses.  The cartilage
%     thickness data is saved to the MAT file:  fcthka.mat.
%
%     NOTES:  1.  The MAT data files must be in the "Biomarker MAT
%             files" directory.
%
%             2.  The cartilage and subchondral bone MAT files must end
%             with "_sc.mat".
%
%             3.  MAT files fb_rnga.mat and fscale3.mat must be in the
%             current directory.
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
load fscale3.mat;
%
nf = size(fnams,1);     % Number of files
%
% Initialize Variables
%
d = dir('*EAbc7t.mat');
fnams = deblank(char(d.name));
nf = size(fnams,1);
% iprt = false;
iprt = true;
rad2deg = 180/pi;       % Radians to degrees
%
if exist('fcthka','file')
    load fcthka;
else
    cthk = zeros(nf,nq);    % Cartilage thicknesses
    xyzic = zeros(nf,nq,3); % Cartilage intersection
    rq = zeros(nf,nq);      % Radial coordinates
end
%
% Loop through MAT Files
%
for kf = 14:nf           % Loop through MAT files
%
   fnam = fnams(kf,:);                 % File name
   idot = strfind(fnam,'.');
   fstr = fnam(1:idot-1);              % File name w/o extension
%
% Load Data
%
   d = dir([fstr(1:8) '*.mat']);    % Check for modified data
   fn = sortrows(char(d.name));
   nfsz = size(fn,1);
   fn = fn(nfsz,:);     % Use the most modified data
%
   load(fn);
%
% Get Cylindrical Coordinatesdddd
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
% Interpolate to "Standard" Grid
%
   F = TriScatteredInterp(td,z,r);
   r = F(tq,zq);
   tzrg = [tq zq r];
   it = in_tri2d(trisb,[td z],tzrg(:,1:2));
   tzrg(~it,:) = NaN;
   r(~it) = NaN;
   rq(kf,:) = r';
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
       print('-dpsc2','-r300',hf1,'fcthka.ps');
     else
       print('-dpsc2','-r300','-append',hf1,'fcthka.ps');
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
save fcthka cthk rq xyzic
%
return