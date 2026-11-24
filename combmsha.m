function [xyza,tria] = combmsha(datl,datm,datt);
%COMBMSHA Combines the axial lateral and medial condyle and trochlea
%         MRI knee data into a single triangle based mesh.
%
%         [XYZA,TRIA] = COMBMSHA(DATL,DATM,DATT) given the data cell
%         arrays containing three (3) columns matrices with slice
%         coordinate point data for the lateral condyle, DATL, medial
%         condyle, DATM, and trochlea, DATT, returns the three (3)
%         columns matrix of the combined coordinates, XYZA, and the
%         three (3) columns matrix of the triangular mesh connectivity
%         (elements in rows), TRIA.
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
  error(' *** ERROR in COMBMSHA:  No or not enough input data!');
end
%
% Get Slice Information
%
[nl,nsll,isll] = sl_info(datl);
[nm,nslm,islm] = sl_info(datm);
[nt,nslt,islt] = sl_info(datt);
%
% Get Coordinates
%
xyzl = cell2mat(datl);
xyzm = cell2mat(datm);
xyzt = cell2mat(datt);
%
% Get Anterior X Direction (Trochlea-Condyles)
%
antx = mean(xyzt(:,1))-mean([xyzl(:,1);xyzm(:,1)]);
%
% Divide Condyle Points into Anterior and Posterior Slices
%
apl = false(nl,1);      % Anterior (true)/posterior (false)
for k = 1:nl
   if antx>0
     if mean(datl{k}(:,1))>0
       apl(k) = true;
     end
   else
     if mean(datl{k}(:,1))<0
       apl(k) = true;
     end
   end
end
idal = find(apl);
nal = size(idal,1);
%
datla = datl(apl);
datlp = datl(~apl);
%
apm = false(nm,1);      % Anterior (true)/posterior (false)
for k = 1:nm
   if antx>0
     if mean(datm{k}(:,1))>0
       apm(k) = true;
     end
   else
     if mean(datm{k}(:,1))<0
       apm(k) = true;
     end
   end
end
idam = find(apm);
nam = size(idam,1);
%
datma = datm(apm);
datmp = datm(~apm);
%
% Get New Slice Information
%
[nlp,nsllp,isllp] = sl_info(datlp);
[nmp,nslmp,islmp] = sl_info(datmp);
[nla,nslla,islla] = sl_info(datla);
[nma,nslma,islma] = sl_info(datma);
islmp = islmp+isllp(nlp+1);
islla = islla+islmp(nmp+1);
islma = islma+islla(nla+1);
islt = islt+islma(nma+1);
%
% Get Directions Within the Data Cell Arrays
%
if nal>1
  slvl = sl_dir(datla); % Direction of slices within lateral compartment
end
if nam>1
  slvm = sl_dir(datma); % Direction of slices within medial compartment
end
slvt = sl_dir(datt);    % Direction of slices within trochlea
%
% Get and Combine Coordinates
%
xyzlp = cell2mat(datlp);               % Posterior
xyzmp = cell2mat(datmp);               % Posterior
xyzla = cell2mat(datla);               % Anterior
xyzma = cell2mat(datma);               % Anterior
%
xyza = [xyzlp; xyzmp; xyzla; xyzma; xyzt];  % Lateral->medial and posterior->anterior
%
% Get Triangular Mesh For Each Region
%
trilp = mk_tri4(datlp);
trimp = mk_tri4(datmp)+islmp(1);       % Global IDs
trila = mk_tri4(datla)+islla(1);       % Global IDs
trima = mk_tri4(datma)+islma(1);       % Global IDs
trit = mk_tri4(datt)+islt(1);          % Global IDs
%
% Get Slices Next to Adjacent Regions
%
vz = [0 0 1]';
%
if nal>0
  if nal==1||slvl*vz<0  % Get most anterior slice
    idl = 1;            % Use first slice
  else
    idl = nla;          % Use last slice
  end
end
%
if nam>0
  if nam==1||slvm*vz<0  % Get most anterior slice
    idm = 1;            % Use first slice
  else
    idm = nma;          % Use last slice
  end
end
%
if slvt*vz<0            % Get most posterior slice
  idt = nt;             % Use last slice
else
  idt = 1;              % Use first slice
end
%
% Connect Lateral Compartment and Trochlea Regions in the YZ Plane
%
idxt = islt(idt)+1:islt(idt+1);
yzt = xyza(idxt,2:3);   % Trochlea slice
%
if nal>0
  idxl = islla(idl)+1:islla(idl+1);
  yzl = xyza(idxl,2:3); % Lateral compartment slice
%
  if yzl(1,1)>yzl(nslla(idl),1)
    ymx = yzl(1,1)-(yzl(3,1)-yzl(1,1));
    ymn = yzl(nslla(idl),1)-(yzl(nslla(idl)-2,1)-yzl(nslla(idl),1));
  else
    ymx = yzl(nslla(idl),1)-(yzl(nslla(idl)-2,1)-yzl(nslla(idl),1));
    ymn = yzl(1,1)-(yzl(3,1)-yzl(1,1));
  end
  idy = find(yzt(:,1)>ymn&yzt(:,1)<ymx);         % Limit trochlea points
%
  trilt = delaunay([yzl(:,1); yzt(idy,1)],[yzl(:,2); yzt(idy,2)]);
  nte = size(trilt,1);
%
  irl = nod2tri(1:nslla(idl),trilt,2);                % Edge triangles
  irt = nod2tri(nslla(idl)+(1:nslt(idt)),trilt,2);    % Edge triangles
  ir = true(nte,1);
  ir(irl) = false;      % Remove edge triangles
  ir(irt) = false;      % Remove edge triangles
  trilt = trilt(ir,:);
%
  ilt = trilt>nslla(idl);              % Trochlea IDs
  trilt(ilt) = trilt(ilt)-nslla(idl)+idxt(idy(1))-1;  % Global IDs
  ill = trilt<=nslla(idl);             % Lateral IDs
  trilt(ill) = trilt(ill)+islla(idl);  % Global IDs
else
  trilt = [];
end
%
% Connect Medial Compartment and Trochlea Regions in the YZ Plane
%
if nam>0
  idxm = islma(idm)+1:islma(idm+1);
  yzm = xyza(idxm,2:3); % Medial compartment slice
%
  if yzm(1,1)>yzm(nslma(idm),1)
    ymx = yzm(1,1)-(yzm(3,1)-yzm(1,1));
    ymn = yzm(nslma(idm),1)-(yzm(nslma(idm)-2,1)-yzm(nslma(idm),1));
  else
    ymx = yzm(nslma(idm),1)-(yzm(nslma(idm)-2,1)-yzm(nslma(idm),1));
    ymn = yzm(1,1)-(yzm(3,1)-yzm(1,1));
  end
  idy = find(yzt(:,1)>ymn&yzt(:,1)<ymx);         % Limit trochlea points
%
  trimt = delaunay([yzm(:,1); yzt(idy,1)],[yzm(:,2); yzt(idy,2)]);
  nte = size(trimt,1);
%
  irm = nod2tri(1:nslma(idm),trimt,2);                % Edge triangles
  irt = nod2tri(nslma(idm)+(1:nslt(idt)),trimt,2);    % Edge triangles
  ir = true(nte,1);
  ir(irm) = false;      % Remove edge triangles
  ir(irt) = false;      % Remove edge triangles
  trimt = trimt(ir,:);
%
  ilt = trimt>nslma(idm);              % Trochlea IDs
  trimt(ilt) = trimt(ilt)-nslma(idm)+idxt(idy(1))-1;  % Global IDs
  ilm = trimt<=nslma(idm);             % Medial IDs
  trimt(ilm) = trimt(ilm)+islma(idm);  % Global IDs
else
  trimt = [];
end
%
% Combine Mesh Data
%
tria = [trilp; trimp; trila; trilt; trima; trimt; trit];
%
return