function [datlt,datmt,varargout] = cyl_trnf(datl,datm,varargin);
%CYL_TRNF Transforms MRI knee data cell arrays by a cylinder coordinate
%         transformation.
%
%         [DATLT,DATMT] = CYL_TRNF(DATL,DATM) given the MRI knee data
%         cell arrays for the lateral condyle, DATL, and medial condyle,
%         DATM, transforms the coordinates to a cylinder coordinate
%         system based on circle fits of the center slice in each
%         condyle.  The centers of the circles defines the long axis (Z-
%         axis) and the MRI Z-axis defines the X-axis.  After rotation
%         into this coordinate system, the X and Y coordinates are
%         transformed into the polar coordinate system.  The resulting
%         coordinates are angles (in degrees), radius and Z coordinates.
%         The transformed coordinates are returned in cell arrays,
%         DATLT and DATMT, for the lateral and medial condyles,
%         respectively.
%
%         [DATLT,DATMT,DAT1T,DAT2T,DAT3T,...] = CYL_TRNF(DATL,DATM,DAT1,
%         DAT2,DAT3,...) returns additional cell arrays that have been
%         transformed by the same cylindrical transformation defined by
%         the lateral and medial cell arrays.  For example, the lateral
%         and medial bone condyle cell arrays can form the basis for
%         transforming the other bone and cartilage cell arrays.
%
%         [DATLT,DATMT,...,RO,RMAT] = CYL_TRNF(DATL,DATM,...) returns
%         the coordinate offset (center of the cylindrical projection),
%         RO, and the rotation matrix for the cylindrical axis, RMAT.
%
%         NOTES:  1.  Inputs must be a MRI knee data cell arrays with
%                 the coordinate matrices for each slice in rows in the
%                 cell array.
%
%                 2.  M-files circ_fit.m, circ_ft3.m, plane_fit.m and
%                 sl_info.m must be in the current path or directory.
%
%         02-Jul-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Check Inputs
%
if nargin<2
  error([' *** ERROR in CYL_TRNF:  At least two input MRI knee', ...
         ' data cell arrays are required!']);
end
%
if ~iscell(datl)||~iscell(datm)
  error(' *** ERROR in CYL_TRNF:  Inputs must be cell arrays!');
end
%
iloop = nargin-2;
for k = 1:iloop
   dat = varargin{k};
   if ~iscell(dat)
     error(' *** ERROR in CYL_TRNF:  Inputs must be cell arrays!');
   end
end
%
% Check Outputs
%
if nargout>nargin+2
  error(' *** ERROR in CYL_TRNF:  Too many output arguments!');
end
%
% Get Slices in Rows
%
datl = datl(:);         % Ensure slices are in rows
datm = datm(:);         % Ensure slices are in rows
%
% Get Slice Information
%
[nslicel,nsl,isl] = sl_info(datl);
[nslicem,nsm,ism] = sl_info(datm);
%
% Get Coordinates for the Middle of Each Condyle
%
nslh = round(nslicel/2);
xyzlh = datl{nslh};
%
nsmh = round(nslicem/2);
xyzmh = datm{nsmh};
%
% Fit Whole Slice Data in Approximate Middle of Each Condyle
%
[rl,xl,yl,zl] = circ_ft3(xyzlh(:,1),xyzlh(:,2),xyzlh(:,3));
[rm,xm,ym,zm] = circ_ft3(xyzmh(:,1),xyzmh(:,2),xyzmh(:,3));
%
% Get Rotation Matrix Using MRI Z Coordinate
%
ro = mean([xl yl zl; xm ym zm]);       % New origin
zv = [xl-xm yl-ym zl-zm];
zv = zv./norm(zv);
xv = [0 0 1];
yv = cross(zv,xv);
yv = yv./norm(yv);
xv = cross(yv,zv);
xv = xv./norm(xv);
%
r = [xv; yv; zv]';      % Rotation matrix
%
% Get and Rotate All of the Coordinates
%
xyzl = cell2mat(datl);
xyzm = cell2mat(datm);
%
nl = size(xyzl,1);
nm = size(xyzm,1);
%
roffl = repmat(ro,nl,1);
rxyzl = (xyzl-roffl)*r;
%
roffm = repmat(ro,nm,1);
rxyzm = (xyzm-roffm)*r;
%
% Convert to Polar Coordinates
%
[thl,rl] = cart2pol(rxyzl(:,1),rxyzl(:,2));
[thm,rm] = cart2pol(rxyzm(:,1),rxyzm(:,2));
%
% Trap for Angles at 180 degrees (pi)
%
idl = find(thl<0);
if ~isempty(idl)
  thl(idl) = 2*pi+thl(idl);
end
%
idm = find(thm<0);
if ~isempty(idm)
  thm(idm) = 2*pi+thm(idm);
end
%
% Cylinderical (Polar) Coordinates
%
rad2deg = 180/pi;
txyzl = [thl*rad2deg,rl,rxyzl(:,3)];
txyzm = [thm*rad2deg,rm,rxyzm(:,3)];
%
% Reform Cell Arrays
%
datlt = cell(nslicel,1);
for k = 1:nslicel
   datlt{k} = txyzl(isl(k)+1:isl(k+1),:);
end
%
datmt = cell(nslicem,1);
for k = 1:nslicem
   datmt{k} = txyzm(ism(k)+1:ism(k+1),:);
end
%
% Return Coordinate Offset and Rotation Matrix
% (Center of Cylinder and Cylinder Axis)
%
if nargout==nargin+2
  varargout{iloop+2} = r;
end
%
if nargout>nargin
  varargout{iloop+1} = ro;
end
%
% Transform Additional Cell Arrays
%
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
% Get and Rotate All of the Coordinates
%
   xyz = cell2mat(dat);
%
   nd = size(xyz,1);
%
   roff = repmat(ro,nd,1);
   rxyz = (xyz-roff)*r;
%
% Convert to Polar Coordinates
%
   [thd,rd] = cart2pol(rxyz(:,1),rxyz(:,2));
%
% Trap for Angles at 180 degrees (pi)
%
   idd = find(thd<0);
   if ~isempty(idd)
     thd(idd) = 2*pi+thd(idd);
   end
%
% Cylinderical Coordinates
%
   txyz = [thd*rad2deg,rd,rxyz(:,3)];
%
% Reform Cell Arrays
%
   datt = cell(nslice,1);
   for l = 1:nslice
      datt{l} = txyz(isd(l)+1:isd(l+1),:);
   end
%
% Output Transformed Coordinates
%   
   varargout{k} = datt;
%
end
%
return