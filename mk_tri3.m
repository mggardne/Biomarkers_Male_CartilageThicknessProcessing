function [tri,nt] = mk_tri3(dat,iplt);
%MK_TRI3 Makes a triangular mesh by projecting the 3-D data onto a
%        fitted plane.
%
%        [TRI,NT] = MK_TRI3(DAT) given a three (3) columns matrix with
%        coordinate point data, DAT, returns the three (3) column
%        triangle connectivity matrix, TRI.  The number of returned
%        triangles, NT, may also be returned.
%
%        NOTES:  1.  The M-files plane_fit.m and plane_plt.m must be in
%                the current path or directory.
%
%                2.  Must have at least three data points.
%
%        25-June-2010 * Mack Gardner-Morse
%

%#######################################################################
%
% Check for Inputs
%
if (nargin<2)
  iplt = false;
end
%
if (nargin<1)
  error(' *** ERROR in MK_TRI3:  No input data!');
end
%
[npts,ncol] = size(dat);
if ncol~=3
  error(' *** ERROR in MK_TRI3:  Data must have three columns!');
end
%
% Fit Plane
%
x = dat(:,1);
y = dat(:,2);
z = dat(:,3);
[cntr,nv,coeff,r,s,pct,res] = plane_fit(x,y,z);
%
% Get Points on the Plane
%
xyz = dat-res;
%
% Rotate Plane
%
xyzm = repmat(cntr,npts,1);
xyzr = xyz-xyzm;
xyzr = xyzr*r;
%
% Delaunay Triangulation
%
xr = xyzr(:,1);
yr = xyzr(:,2);
tri = delaunay(xr,yr);
nt = size(tri,1);
%
% Graphical Check of Algorithm
%
if iplt
  mnmx = [min([dat; xyz]); max([dat; xyz])];
  [xp,yp,zp] = plane_plt(cntr,nv,mnmx,12);
  above = (dat-xyzm)*nv>0;
  below = ~above;
%
  figure;
  surf(xp,yp,zp,'FaceColor','none','EdgeColor','k','LineWidth',1);
  hold on;
  plot3(x,y,z,'b.','LineWidth',1,'MarkerSize',8);
  plot3([xyz(above,1) dat(above,1)]',[xyz(above,2) dat(above,2)]', ...
        [xyz(above,3) dat(above,3)]','r-');
  plot3([xyz(below,1) dat(below,1)]',[xyz(below,2) dat(below,2)]', ...
        [xyz(below,3) dat(below,3)]','g-','Color',[0 0.5 0]);
  axis equal;
  view(3);
  xlabel('X (mm)','FontSize',12,'FontWeight','bold');
  ylabel('Y (mm)','FontSize',12,'FontWeight','bold');
  zlabel('Z (mm)','FontSize',12,'FontWeight','bold');
  title('Fitted Plane','FontSize',16,'FontWeight','bold');
%
  figure;
  xyz = xyz-xyzm;
  plot3(xyz(:,1),xyz(:,2),xyz(:,3),'b.','LineWidth',1,'MarkerSize',8);
  hold on;
  plot3(xyzr(:,1),xyzr(:,2),xyzr(:,3),'k.','LineWidth',1, ...
        'MarkerSize',8);
  axis equal;
  view(3);
  xlabel('X (mm)','FontSize',12,'FontWeight','bold');
  ylabel('Y (mm)','FontSize',12,'FontWeight','bold');
  zlabel('Z (mm)','FontSize',12,'FontWeight','bold');
  title('Rotated Plane','FontSize',16,'FontWeight','bold');
%
  figure;
  trimesh(tri,xr,yr,xyzr(:,3),'FaceColor','none','EdgeColor','k');
  axis equal;
  view(3);
  xlabel('X (mm)','FontSize',12,'FontWeight','bold');
  ylabel('Y (mm)','FontSize',12,'FontWeight','bold');
  zlabel('Z (mm)','FontSize',12,'FontWeight','bold');
  title('Mesh with 2-D Coordinates','FontSize',16,'FontWeight','bold');
%
  figure;
  trimesh(tri,x,y,z,'FaceColor','none','EdgeColor','k');
  axis equal;
  view(3);
  xlabel('X (mm)','FontSize',12,'FontWeight','bold');
  ylabel('Y (mm)','FontSize',12,'FontWeight','bold');
  zlabel('Z (mm)','FontSize',12,'FontWeight','bold');
  title('Mesh with Original Data','FontSize',16,'FontWeight','bold');
%
end
%
return