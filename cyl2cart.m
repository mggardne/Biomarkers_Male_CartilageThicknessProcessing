function [xyz,varargout] = cyl2cart(trz,ro,r,varargin);
%CYL2CART Transforms MRI knee data coordinate arrays back from a
%         cylinder coordinate transformation (see CYL_TRNF.M) to
%         Cartesian coordinates.
%
%         XYZ = CYL2CART(TRZ,RO,R) given the 3-D MRI knee data with
%         the angles (Theta in degrees), the radius (R) and Z
%         coordinates in the three columns of array, TRZ, the X, Y and Z
%         coordinates of the cylinder axis offset in the three (3)
%         element vector, RO, and the 3-D cylinder axis rotation matrix
%         in a 3x3 array, R, transforms the coordinates from a cylinder
%         coordinate system back to the original Cartesian coordinate
%         system which are returned in XYZ.
%
%         [XYZ,XYZ1,XYZ2, ...] = CYL2CART(TRZ,RO,R,TRZ1,TRZ2, ...)
%         given additional coordinate arrays, returns additional arrays
%         that have been transformed by the same transformation.
%
%         NOTES:  1.  Note the input coordinates are angles in degrees,
%                 radius and Z coordinates.
%
%                 2.  Note the rotation matrix, R, should be the
%                 original rotation matrix as returned by CYL_TRNF.M.
%                 This function uses the transpose of the rotation
%                 matrix.
%
%                 3.  Reverses the transformation in CYL_TRNF.M.  See
%                 CYL_TRNF.M.
%
%         08-Jul-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Check Inputs
%
if nargin<3
  error(' *** ERROR in CYL2CART:  At least three inputs are required!');
end
%
ro = ro(:)';            % Make a row vector
%
[npts,ncol1] = size(trz);
ncol2 = size(ro,2);
[nrow3,ncol3] = size(r);
%
if ncol1~=3||ncol2~=3||ncol3~=3
  error(' *** ERROR in CYL2CART:  The inputs must have 3 columns!');
end
%
if nrow3~=3
  error(' *** ERROR in CYL2CART:  The rotation matrix must have 3 rows!');
end
%
iloop = nargin-3;
for k = 1:iloop
   ncol = size(varargin{k},2);
   if ncol~=3
     error(' *** ERROR in CYL2CART:  The inputs must have 3 columns!');
   end
end
%
% Check Outputs
%
if nargout>nargin-2
  error(' *** ERROR in CYL2CART:  Too many output arguments!');
end
%
% Trap for Angles Greater Than 180 Degrees and Convert to Radians
%
idb = find(trz(:,1)>180);
%
deg2rad = pi/180;
trz(:,1) = trz(:,1)*deg2rad;
%
trz(idb,1) = trz(idb,1)-2*pi;
%
% Convert to Cartesian Coordinates
%
[x,y,z] = pol2cart(trz(:,1),trz(:,2),trz(:,3));
xyz = [x,y,z];
%
% De-Rotate and Add Axis Offset
%
romat = repmat(ro,npts,1);             % Axis offset matrix
xyz = xyz*r'+romat;
%
% Transform Additional Coordinate Arrays
%
for k = iloop:-1:1
%
% Get Coordinate Array
%
   trz1 = varargin{k};
   npt1 = size(trz1,1);
%
% Trap for Angles Greater Than 180 Degrees and Convert to Radians
%
   idb = find(trz1(:,1)>180);
%
   trz1(:,1) = trz1(:,1)*deg2rad;
%
   trz1(idb,1) = trz1(idb,1)-2*pi;
%
% Convert to Cartesian Coordinates
%
   [x1,y1,z1] = pol2cart(trz1(:,1),trz1(:,2),trz1(:,3));
   xyz1 = [x1,y1,z1];
%
% De-Rotate and Add Axis Offset
%
   romat = repmat(ro,npt1,1);          % Axis offset matrix
   xyz1 = xyz1*r'+romat;
%
% Output Transformed Coordinates
%   
   varargout{k} = xyz1;
%
end
%
return