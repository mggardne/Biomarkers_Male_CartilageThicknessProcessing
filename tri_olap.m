function [ichk1,ichk2] = tri_olap(tri1,xy1,tri2,xy2,tol,iplt);
%TRI_OLAP Finds any intersecting sides (excluding the vertices) between
%         two triangular meshes.
%
%         ICHK1 = TRI_OLAP(TRI1,XY1,TRI2,XY2) For a triangular surface
%         mesh, TRI1, and X and Y coordinates, XY1, and a second 
%         triangular surface mesh, TRI2, and X and Y coordinates, XY1,
%         finds any triangle sides that intersect (excluding the
%         vertices) between the two triangular meshes.
%
%         NOTES:  1.  Surface should be almost planar in the XY plane.
%
%                 2.  M-file lisect4.m must be in the current path or
%                 directory.
%
%         07-Nov-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Check the Inputs
%
if (nargin<4)
  error(' *** ERROR in TRI_OLAP:  Not enough input arguments!');
end
%
if (nargin<5)||isempty(tol)
  tol = 1e-8;           % Default tolerance
end
%
if (nargin<6)
  iplt = false;
end
%
% Sides of the Triangles
%
s1 = [tri1 tri1(:,1)];
s2 = [tri2 tri2(:,1)];
n1 = size(s1,1);        % Number of sides 1
n2 = size(s2,1);        % Number of sides 2
%
% Initialize variables
%
z4 = zeros(4,1);
ichk1 = zeros(n1,1);
ichk2 = zeros(n2,1);
tol = tol/2;
%
% Loop through Sides Looking for Intersections
%
for k = 1:n1
   for l  = 1:3
      for m = 1:n2
         p1 = [xy1(s1(k,l),:) 0];      % Start of side
         v1 = [xy1(s1(k,l+1),:) 0]-p1; % Vector of side
%
% Shrink Side by 2*tol at Both Ends
%
         nv = v1./norm(v1);
         p1 = p1+2*tol*v1;             % Move start "in" by 2*tol
         v1 = v1-4*tol*v1;             % Reduce length by 4*tol
%
% Find Intersection
%
         pwl = [xy2(s2(m,:)',:) z4];   % Sides of triangle in second mesh
         ip = lisect4(p1,v1,pwl,tol);  % Find intersection
         if ~isempty(ip)
           if (iplt)
             hl = plot([p1(:,1); p1(:,1)+v1(:,1)], ...
                       [p1(:,2); p1(:,2)+v1(:,2)],'r-','LineWidth',3);
             hold on;
             hp = plot(pwl(:,1),pwl(:,2),'g-','LineWidth',3);
             hi = plot(ip(:,1),ip(:,2),'ko','LineWidth',2, ...
                       'MarkerSize',8);
             pause;
             delete(hl,hp,hi);
           end
           ichk1(k) = m;               % Triangle with intersection
           ichk2(m) = k;               % Triangle being intersected
         end
      end
   end
end
%
return