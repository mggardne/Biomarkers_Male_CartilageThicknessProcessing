function [t,ip] = car_thk5(trib,xyzb,tric,xyzc,iplt,fstr,cmprt,hf1,hf2);
%CAR_THK5 Finds cartilage thicknesses at all the points on the
%         interpolated grid cartilage surface.
%
%         T = CAR_THK5(TRIB,XYZB,TRIC,XYZC) given the subchondral
%         bone triangle connectivity and coordinates matrices TRIB and
%         XYZB, and cartilage triangle connectivity and coordinates
%         matrices TRIC and XYZC, determines the cartilage thicknesses
%         at all the points on the cartilage surface.  The thicknesses
%         are based on the cartilage surface normals.
%
%         [T,IP] = CAR_THK5(TRIB,...) returns the intersection points
%         with the subchondral bone surface IP in a three column matrix
%         for the X, Y and Z coordinates of the points.
%
%         CAR_THK5(TRIB,XYZB,TRIC,XYZC,IPLT,FSTR,CMPRT) if IPLT is true
%         and given a title string FSTR and a logical compartment flag
%         (false for lateral, true for medial) CMPRT, plots the
%         cartilage surface color coded by cartilage thicknesses in a
%         figure.
%
%         CAR_THK5(TRIB,XYZB,TRI,XYZ,IPLT,FSTR,CMPRT,HF1) plots the
%         cartilage surface color coded by cartilage thicknesses in the
%         figure with figure handle HF1.
%
%         NOTES:  1.  The M-files nod2tri.m, nod_norm.m, tsect4.m and
%                 xprod.m must be in the current path or directory.

%                 2.  tsect4.m uses a very strict definition of
%                 intersection.  An alternate is tsect3.m which finds
%                 intersections to within a tolerance.
%
%         04-Sep-2013 * Mack Gardner-Morse
%

%#######################################################################
%
% Check for Inputs
%
if (nargin<4)
  error([' *** ERROR in CAR_THK5:  CAR_THK5 requires four (4)', ...
         ' inputs!']);
end
%
if (nargin<5)||isempty(iplt)
  iplt = false;
end
%
if (nargin<6)||isempty(fstr)
  fstr = '';
end
%
% Compartment Names
%
if (nargin<7)||isempty(cmprt)
  cmprt = false;
  txtcmpt = '';
else
  if cmprt
    txtcmpt = 'Medial';
  else
    txtcmpt = 'Lateral';
  end
end
%
% Open Figure
%
if iplt&&(nargin<8)
  hf1 = figure;
  orient landscape;
else
  figure(hf1);
  orient landscape;
end
% Thickness plot in polar coordinates
if iplt&&(nargin<9)
  hf2 = figure;
  orient landscape;
else
  figure(hf2);
  orient landscape;
end
%
% Get State of Warnings
%
swrn = warning('query','backtrace');
% warning('off','backtrace');
warning('off','all');
%
% Plot Cartilage and Bone Surfaces
%
if iplt
%
  figure(hf1);
  subplot(1,2,1);
  hc1 = trimesh(tric,xyzc(:,1),xyzc(:,2),xyzc(:,3), ...
                'LineWidth',0.25,'FaceColor','none','EdgeColor','b');
  hold on;
  xlabel('X','FontSize',12,'FontWeight','bold');
  ylabel('Y','FontSize',12,'FontWeight','bold');
  zlabel('Z','FontSize',12,'FontWeight','bold');
  title({[fstr ' ' txtcmpt]; ...
        'Cartilage and Bone Meshes'},'Interpreter','none', ...
        'FontSize',16,'FontWeight','bold');
%
% Plot Bone Surface
%
  hb = trimesh(trib,xyzb(:,1),xyzb(:,2),xyzb(:,3), ...
               'LineWidth',0.25,'FaceColor','none','EdgeColor','k');
  if cmprt
    view(-40,60);
  end
  axis equal;
end
%
% Get Cartilage Surface Normals at the Nodes
%
nnv = nod_norm(tric,xyzc);
%
% Loop through the Cartilage Points
%
nb = size(xyzb,1);
nc = size(xyzc,1);
xyzi = NaN(nc,3);
for k = 1:nc
   pt = xyzc(k,:);                     % Cartialge point
%
   if ~isnan(pt(:,3))                  % Make sure z coordinate exists
%
     linv = nnv(k,:);                  % Cartilage normal vector
%
% Find Nodes and Connected Triangles Close (<12 mm) to the Cartilage Points
%
     r = xyzb-repmat(pt,nb,1);
     r = sum(r.*r,2);
     idb = find(r<144);                % Bone nodes within 12 mm of cartilage
     idt = nod2tri(idb,trib);          % Triangles connected to these bone nodes
     ntri = size(idt,1);
%
% Find the Bone Intersection with Cartilage Normal
%
     for l = 1:ntri     % Bone surface triangles
        it = trib(idt(l),:)';          % Nodes in triangle
%         xt = xyzb(it,1);
%         yt = xyzb(it,2);
%         zt = xyzb(it,3);
        v1 = xyzb(it(1),:);
        v2 = xyzb(it(2),:);
        v3 = xyzb(it(3),:);
        [xyzit,il,ierr] = tsect4(v1,v2,v3,pt,linv);
        if il
          xyzi(k,:) = xyzit';          % Intersection point
          break;
        end
        if l==ntri
          warning(sprintf(['  CAR_THK5 is not able to ', ...
                  'find subchondral bone below and normal to ', ...
                  'cartilage point %i in %s compartment in %s.'], ...
                  k,lower(txtcmpt),fstr));
        end
     end
   end
end
%
% Get Cartilage Thicknesses
%
dp = xyzc-xyzi;
cthk = sqrt(sum(dp.*dp,2));
%
% Plot the Points for the Cartilage Thicknesses
%
if iplt
%
  figure(hf1);
  subplot(1,2,2);
  hc2 = trimesh(tric,xyzc(:,1),xyzc(:,2),xyzc(:,3), ...
                'LineWidth',0.25,'FaceColor','none','EdgeColor','b');
  hold on;
%
  idx = find(~isnan(cthk));
  it = nod2tri(idx,tric,2);
  hs = trisurf(tric(it,:),xyzc(:,1),xyzc(:,2), ...
               xyzc(:,3),cthk,'FaceColor','interp', ...
               'EdgeColor','b','LineWidth',0.25);
  if cmprt
    view(-40,60);
  end
  axis equal;
%
  if min(cthk)<0
    caxis([min(cthk) max(cthk)]);
  else
    caxis([0 max(cthk)]);
  end
  hcb = colorbar;
  xlabel('X','FontSize',12,'FontWeight','bold');
  ylabel('Y','FontSize',12,'FontWeight','bold');
  zlabel('Z','FontSize',12,'FontWeight','bold');
  title({[fstr ' ' txtcmpt]; ...
        'Cartilage Thicknesses'},'Interpreter','none', ...
        'FontSize',16,'FontWeight','bold');
    colormap(hf2,jet);
%
% Additional polar plot
%
  figure(hf2);
  [thp,rdp,zp] = cart2pol(xyzc(:,1),xyzc(:,3),xyzc(:,2));
  id = find(thp>pi/2);
  thp(id) = thp(id)-2*pi;
  thp = thp*180/pi;
%   keyboard;
  hc2 = trimesh(tric,thp,zp,rdp, ...
                'LineWidth',0.25,'FaceColor','none','EdgeColor','b');
  hold on;
%
  idx = find(~isnan(cthk));
  it = nod2tri(idx,tric,2);
  hs = trisurf(tric(it,:),thp,zp,rdp,cthk,'FaceColor','interp', ...
               'EdgeColor','b','LineWidth',0.25);
  if cmprt
    view(-40,60);
  end
  axis equal;
%
    colormap(hf2,jet);
    caxis([0 5]);

   hcb = colorbar;
  view(2)
  xlabel('T','FontSize',12,'FontWeight','bold');
  ylabel('R','FontSize',12,'FontWeight','bold');
  zlabel('Z','FontSize',12,'FontWeight','bold');
  title({[fstr ' ' txtcmpt]; ...
        'Cartilage Thicknesses'},'Interpreter','none', ...
        'FontSize',16,'FontWeight','bold');
  
end
%
% Return Thicknesses and Intersection Points
%
t = cthk;
ip = xyzi;
%
% Restore Warnings
%
warning(swrn);
%
return