function [varargout] = xzpl2pol(varargin);
%XZPL2POL Transforms X-Z plane coordinates to polar coordinates (Theta-
%         R) in MRI knee data cell arrays.
%
%         DATT = XZPL2POL(DAT) Transforms the X-Z coordinates in MRI
%         knee data cell array, DAT, to polar coordinates (Theta-R).
%         The polar coordinates are returned in a cell array, DATT.
%
%         [DATT1,DATT2,DATT3,...] = XZPL2POL(DAT1,DAT2,DAT3, ...)
%         returns additional cell arrays with the same polar
%         transformation.
%
%         NOTES:  1.  Inputs must be a MRI knee data cell arrays with
%                 the coordinate matrices for each slice in rows in the
%                 cell array.
%
%                 2.  Note the X, Y and Z coordinates are transformed
%                 to the Theta (radians), R and Y coordinates.
%
%                 3.  Note that positive angles greater than 90 degrees
%                 (pi/2 radians and Z-axis) are offset by -2*pi radians
%                 (-360 degrees).
%
%                 4.  See pol2xypl.m for the inverse transformation.
%
%                 5.  M-file sl_info.m must be in the current path or
%                 directory.
%
%         31-Jul-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Check Inputs
%
if nargin<1
  error([' *** ERROR in XZPL2POL:  At least one input MRI knee', ...
         ' data cell array is required!']);
end
%
% Check Outputs
%
if nargout~=nargin
  error([' *** ERROR in XZPL2POL:  Number of inputs do not match', ...
        ' the number of outputs!']);
end
%
% Transform Cell Arrays
%
iloop = nargin;
for k = iloop:-1:1
%
% Get Cell Array
%
   dat = varargin{k};
%
% Get Slice Information
%
   [nslice,nsd,isd] = sl_info(dat);
%
% Get and Transform All of the Coordinates
%
   xyz = cell2mat(dat);
   [theta,r,z] = cart2pol(xyz(:,1),xyz(:,3),xyz(:,2));
%
% Trap for Angles Greater Than 90 degrees (pi/2 radians and Z-Axis)
%
   id = find(theta>pi/2);
   if ~isempty(id)
     theta(id) = theta(id)-2*pi;
   end
%
   trz = [theta r z];   % Combine coordinates in an array
%
% Reform Cell Arrays
%
   datt = cell(nslice,1);
   for l = 1:nslice
      datt{l} = trz(isd(l)+1:isd(l+1),:);
   end
%
% Output Transformed Coordinates
%   
   varargout{k} = datt;
%
end
%
return