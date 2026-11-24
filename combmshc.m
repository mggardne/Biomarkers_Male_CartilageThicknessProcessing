function [xyzc,tric] = combmshc(datl,datm,datt);
%COMBMSHC Combines the coronal lateral and medial condyle and trochlea
%         MRI knee data into a single triangle based mesh.
%
%         [XYZC,TRIC] = COMBMSHC(DATL,DATM,DATT) given the data cell
%         arrays containing three (3) columns matrices with slice
%         coordinate point data for the lateral condyle, DATL, medial
%         condyle, DATM, and trochlea, DATT, returns the three (3)
%         columns matrix of the combined coordinates, XYZC, and the
%         three (3) columns matrix of the triangular mesh connectivity
%         (elements in rows), TRIC.
%
%         NOTES:  1.  To insure the correct ordering of the slices,
%                 the input cell arrays must be input in the correct
%                 order (lateral, medial and trochlea).
%
%                 2.  The function assumes all the slices are in order
%                 within the data cell arrays.
%
%                 3.  The M-files mk_tri4.m, nod2tri.m, plane_fit.m,
%                 sl_dir.m and sl_info.m must be in the current path or
%                 directory.
%
%         12-Nov-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Check for Inputs
%
if (nargin<3)
  error(' *** ERROR in COMBMSHC:  No or not enough input data!');
end
%
% Get Slice Information
%
[nl,nsll,isll] = sl_info(datl);
[nm,nslm,islm] = sl_info(datm);
[nt,nslt,islt] = sl_info(datt);
islm = islm+isll(nl+1);
islt = islt+islm(nm+1);
%
% Get and Combine Coordinates
%
xyzl = cell2mat(datl);
xyzm = cell2mat(datm);
xyzt = cell2mat(datt);
xyzc = [xyzl; xyzm; xyzt];
%
% Get Direction Between the Centers of the Condyles and the Center of
% the Trochlea
%
rmcon = (mean(xyzl)+mean(xyzm))/2;
rmtro = mean(xyzt);
vx = rmtro-rmcon;       % Anterior direction
%
% Get Directions Within the Data Cell Arrays
%
slvl = sl_dir(datl);    % Direction of slices within lateral compartment
slvm = sl_dir(datm);    % Direction of slices within medial compartment
slvt = sl_dir(datt);    % Direction of slices within trochlea
%
% Get Triangular Mesh For Each Region
%
tril = mk_tri4(datl);
trim = mk_tri4(datm)+islm(1);          % Global IDs
trit = mk_tri4(datt)+islt(1);          % Global IDs
%
% Get Slices Next to Adjacent Regions
%
if slvl*vx'<0           % Get most anterior slice
  idl = 1;              % Use first slice
else
  idl = nl;             % Use last slice
end
%
if slvm*vx'<0           % Get most anterior slice
  idm = 1;              % Use first slice
else
  idm = nm;             % Use last slice
end
%
if slvt*vx'<0           % Get most posterior slice
  idt = nt;             % Use last slice
else
  idt = 1;              % Use first slice
end
%
% Connect Lateral Compartment and Trochlea Regions in the XY Plane
%
idxl = isll(idl)+1:isll(idl+1);
idxt = islt(idt)+1:islt(idt+1);
xyl = xyzc(idxl,1:2);   % Lateral compartment slice
xyt = xyzc(idxt,1:2);   % Trochlea slice
%
xd = xyl(nsll(idl),:)-xyl(1,:);
ang = atan(xd(1)./xd(2));
r = [cos(ang) -sin(ang); sin(ang) cos(ang)];     % Rotation matrix
xylr = xyl*r';          % Rotated coordinates
xytr = xyt*r';          % Rotated coordinates
if xylr(1,2)>xylr(nsll(idl),2)
  ymx = xylr(1,2)-(xylr(3,2)-xylr(1,2));
  ymn = xylr(nsll(idl),2)-(xylr(nsll(idl)-2,2)-xylr(nsll(idl),2));
else
  ymx = xylr(nsll(idl),2)-(xylr(nsll(idl)-2,2)-xylr(nsll(idl),2));
  ymn = xylr(1,2)-(xylr(3,2)-xylr(1,2));
end
idx = find(xytr(:,2)>ymn&xytr(:,2)<ymx);         % Limit trochlea points
%
trilt = delaunay([xylr(:,1); xytr(idx,1)],[xylr(:,2); xytr(idx,2)]);
nte = size(trilt,1);
%
irl = nod2tri(1:nsll(idl),trilt,2);              % Edge triangles
irt = nod2tri(nsll(idl)+(1:nslt(idt)),trilt,2);  % Edge triangles
ir = true(nte,1);
ir(irl) = false;        % Remove edge triangles
ir(irt) = false;        % Remove edge triangles
trilt = trilt(ir,:);
%
ilt = trilt>nsll(idl);  % Trochlea IDs
trilt(ilt) = trilt(ilt)-nsll(idl)+idxt(idx(1))-1;% Global IDs
ill = trilt<=nsll(idl); % Lateral IDs
trilt(ill) = trilt(ill)+isll(idl);     % Global IDs
%
% Connect Medial Compartment and Trochlea Regions in the XY Plane
%
idxm = islm(idm)+1:islm(idm+1);
xym = xyzc(idxm,1:2);   % Medial compartment slice
%
xd = xym(nslm(idm),:)-xym(1,:);
ang = atan(xd(1)./xd(2));
r = [cos(ang) -sin(ang); sin(ang) cos(ang)];     % Rotation matrix
xymr = xym*r';          % Rotated coordinates
xytr = xyt*r';          % Rotated coordinates
if xymr(1,2)>xymr(nslm(idm),2)
  ymx = xymr(1,2)-(xymr(3,2)-xymr(1,2));
  ymn = xymr(nslm(idm),2)-(xymr(nslm(idm)-2,2)-xymr(nslm(idm),2));
else
  ymx = xymr(nslm(idm),2)-(xymr(nslm(idm)-2,2)-xymr(nslm(idm),2));
  ymn = xymr(1,2)-(xymr(3,2)-xymr(1,2));
end
idx = find(xytr(:,2)>ymn&xytr(:,2)<ymx);         % Limit trochlea points
%
trimt = delaunay([xymr(:,1); xytr(idx,1)],[xymr(:,2); xytr(idx,2)]);
nte = size(trimt,1);
%
irm = nod2tri(1:nslm(idm),trimt,2);              % Edge triangles
irt = nod2tri(nslm(idm)+(1:nslt(idt)),trimt,2);  % Edge triangles
ir = true(nte,1);
ir(irm) = false;        % Remove edge triangles
ir(irt) = false;        % Remove edge triangles
trimt = trimt(ir,:);
%
ilt = trimt>nslm(idm);  % Trochlea IDs
% keyboard;
trimt(ilt) = trimt(ilt)-nslm(idm)+idxt(idx(1))-1;% Global IDs
ilm = trimt<=nslm(idm); % Medial IDs
trimt(ilm) = trimt(ilm)+islm(idm);     % Global IDs
%
% Combine Mesh Data
%
tric = [tril; trilt; trim; trimt; trit];
%
return