function [varargout] = pol2xzpl(varargin);
%POL2XZPL Transforms polar coordinates (Theta-R) in MRI knee data cell
%         arrays to X-Z plane coordinates.
%
%         DATT = POL2XZPL(DAT) Transforms the polar coordinates (Theta-
%         R) in MRI knee data cell array, DAT, to X-Z coordinates.
%         The Cartesian coordinates are returned in a cell array, DATT.
%
%         [DATT1,DATT2,DATT3,...] = POL2XZPL(DAT1,DAT2,DAT3, ...)
%         returns additional cell arrays with the same Cartesian
%         transformation.
%
%         NOTES:  1.  Inputs must be a MRI knee data cell arrays with
%                 the coordinate matrices for each slice in rows in the
%                 cell array.
%
%                 2.  Note the Theta (radians), R and Z coordinates are
%                 transformed to the X, Z and Y coordinates.
%
%                 3.  See xypl2pol.m for the inverse transformation.
%
%                 4.  M-file sl_info.m must be in the current path or
%                 directory.
%
%         31-Jul-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Check Inputs
%
if nargin<1
  error([' *** ERROR in POL2XZPL:  At least one input MRI knee', ...
         ' data cell array is required!']);
end
%
% Check Outputs
%
if nargout~=nargin
  error([' *** ERROR in POL2XZPL:  Number of inputs do not match', ...
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
% Get All of the Coordinates
%
   trz = cell2mat(dat);
%
% Transform All of the Coordinates
%
   [x,z,y] = pol2cart(trz(:,1),trz(:,2),trz(:,3));
   xyz = [x y z];
%
% Reform Cell Arrays
%
   datt = cell(nslice,1);
   for l = 1:nslice
      datt{l} = xyz(isd(l)+1:isd(l+1),:);
   end
%
% Output Transformed Coordinates
%   
   varargout{k} = datt;
%
end
%
return