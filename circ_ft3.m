function [r,xc,yc,zc,rot] = circ_ft3(x,y,z,iplt);
%CIRC_FT3 Fits a circle to X, Y and Z point coordinate data.
%
%         [R,XC,YC,ZC] = CIRC_FT3(X,Y,Z) given the X, Y and Z
%         coordinates of a set of three points, calculates a least
%         squares fit of a circle to the points.  The radius, R, and
%         the coordinates of the center of the circle (XC, YC, ZC) are
%         returned.
%
%         [R,XC,YC,ZC,ROT] = CIRC_FT3(X,Y,Z) returns the rotation
%         matrix ROT to rotate the points into the XY plane.
%
%         NOTES:  1.  This program assumes the points lay in a plane.
%
%                 2.  Must have at least three (3) points.
%
%                 3.  The M-files circ_fit.m and plane_fit.m must be in
%                 the current path or directory.
%
%                 4.  See CCircle.odt or CCircle.pdf for derivation.
%
%         05-Feb-2012 * Mack Gardner-Morse
%

%#######################################################################
%
% Check for Inputs
%
if (nargin<3)
  error([' *** ERROR in CIRC_FT3:  The X, Y and Z coordinates of ', ...
         'the points to be fit are required as inputs!']);
end
%
if (nargin<4)
  iplt = false;
end
%
% Get Data Matrix
%
x = x(:);
y = y(:);
z = z(:);
xyz = [x y z];
np = size(xyz,1);
%
% Rotate Points into a Plane
%
[pp,nvec,c,rot] = plane_fit(x,y,z);
roff = repmat(pp,np,1);
xyzr = (xyz-roff)*rot;
%
% Fit Circle
%
[r,xc,yc] = circ_fit(xyzr(:,1),xyzr(:,2));
xyzc = [xc yc mean(xyzr(:,3))];
xyzc = xyzc*rot'+roff(1,:);
xc = xyzc(:,1);
yc = xyzc(:,2);
zc = xyzc(:,3);
%
% Plot Circle
%
if iplt
  ang = (0:pi/36:2*pi)';
  xyzp = r*[cos(ang) sin(ang) zeros(73,1)];
  idz = find(abs(xyzp)<1e-14);
  xyzp(idz) = 0;
  xyzp = xyzp*rot'+repmat(xyzc,73,1);
  hf = figure;
  ht = plot3([x; x(1)],[y; y(1)],[z; z(1)],'bo-','LineWidth',2);
  hold on;
  hc = plot3(xyzp(:,1),xyzp(:,2),xyzp(:,3),'g-','Color',[0 0.5 0], ...
       'LineWidth',2);
  hcc = plot3(xyzc(:,1),xyzc(:,2),xyzc(:,3),'rs','LineWidth',2);
  axis equal;
  xlabel('X','FontSize',12,'FontWeight','bold');
  ylabel('Y','FontSize',12,'FontWeight','bold');
  zlabel('Z','FontSize',12,'FontWeight','bold');
  pause
  delete(hf);
end
%
return