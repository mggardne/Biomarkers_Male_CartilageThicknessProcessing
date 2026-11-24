function [varargout] = coord_rx(varargin);
%COORD_RX Reflects MRI knee data cell arrays about the X-axis.  Assumes
%         the coordinates are in a femur coordinate system with the
%         X-axis in the anterior or posterior (AP) direction.  For
%         reflecting the right (or left) knee data onto the left (or
%         right) knee data.
%
%         DATR = COORD_RX(DAT) Reflects the coordinates in MRI knee
%         data cell array, DAT, about the X-axis (X_r = -X) and returns
%         the reflected coordinates in a cell array, DATR.
%
%         [DAT1R,DAT2R,DAT3R,...] = COORD_RX(DAT1,DAT2,DAT3, ...)
%         returns additional cell arrays with the same reflection about
%         the X-axis.
%
%         NOTES:  1.  Inputs must be a MRI knee data cell arrays with
%                 the coordinate matrices for each slice in rows in the
%                 cell array.
%
%                 2.  M-file sl_info.m must be in the current path or
%                 directory.
%
%         28-Jul-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Check Inputs
%
if nargin<1
  error([' *** ERROR in COORD_RX:  At least one input MRI knee', ...
         ' data cell array is required!']);
end
%
% Check Outputs
%
if nargout~=nargin
  error([' *** ERROR in COORD_RX:  Number of inputs do not match', ...
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
% Get and Reflect All of the Coordinates
%
   xyz = cell2mat(dat);
   xyzr = [-xyz(:,1) xyz(:,2:3)];
%
% Reform Cell Arrays
%
   datt = cell(nslice,1);
   for l = 1:nslice
      datt{l} = xyzr(isd(l)+1:isd(l+1),:);
   end
%
% Output Transformed Coordinates
%   
   varargout{k} = datt;
%
end
%
return