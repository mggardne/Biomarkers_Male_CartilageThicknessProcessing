%#######################################################################
%
%                    * Femur COMBine Female Program *
%
%          M-File which preprocesses the male biomarkers femur
%     data by combining the different compartment data, combining the
%     axial, coronal and sagittal data and generating meshes and
%     coordinates for the bone and cartilage data.  The data is saved
%     to MAT files *sc.mat.
%
%     NOTES:  1.  MAT files *EAbc7t.mat must be in the directory
%             "BM_Male_Femur_MatFiles".  The MAT file fb_rngm.mat must
%             be in the current path or directory.
%
%             2.  The M-files comb_dat.m, combmsha.m, combmshc.m,
%             comp_msh.m, in_tri2d.m, mk_tri4.m, mk_tri4f.m,
%             plane_fit.m, pol2xzpl.m, sl_dir.m, sl_info.m, tri_fix2.m
%             and xzpl2pol.m must be in the current path or directory.
%
%             3.  Assumes the bone data is already combined (line 73).
%
%     18-Aug-2015 * Mack Gardner-Morse
%

%#######################################################################
cl
%
% Plots?
%
iplt = true;
if iplt
  hf1 = figure;
  hf2 = figure;
  hf3 = figure;
end
% iplt = false;
iplt2 = false;          % Debugging plots
%
% Convert Radians to Degrees
%
rad2deg = 180/pi;  
%
% Data Directory and File Names
%
if ismac
  ddir = 'BM_Male_Femur_MAT_Files';
else
  ddir = '..\Male_CartBoneData_Processing';
end
d = dir(fullfile(ddir,'*EAbc7t.mat'));
fnams = deblank(char(d.name));
%
nf = size(fnams,1);     % Number of files
%
% Get Standard Grid
%
load fb_rngm.mat;
%
% Loop through MAT Files
%
% keyboard;
% for kf = 1:nf           % Loop through MAT files
for kf = 1:1            % Loop through MAT files
% for kf = 7:7
% for kf = 12:nf          % Loop through MAT files
% for kf = 10:10
% for kf = [5 12:nf]      % Loop through MAT files
% for kf = 20:20
%
%
   fnam = fnams(kf,:);                 % File name
   idot = strfind(fnam,'.');
   fstr = fnam(1:idot-1);              % File name w/o extension
%
% Load Data
%
   load(fullfile(ddir,fnam));
%
% Combined Bone Data
%
   datsb = datlmtbt;  % Existing combined data in MAT file
%
% Reverse X-Axis for Right Knees
%
   [nsl,ns,is] = sl_info(datsb);
   if leg
     for ks = 1:nsl
        datsb{ks}(:,1) = -datsb{ks}(:,1);
     end
   end
%
% Get Mesh and Coordinates
%
   trisb = mk_tri4f(datsb);
   xyzsb = cell2mat(datsb);
%
   trisb = tri_fix2(trisb,xyzsb);
%
% Catch Rogue Points
%
%   if strmatch(knum,'026_R')
%     xyz = datlcss{5};
%     xyz = [xyz(end,:); xyz(1:end-1,:)];   % Put last point first
%     datlcss{5} = xyz;
%   end
% Coronal and Sagittal Data
%
   [xyza,tria] = combmsha(datlcat,datmcat,dattcat);
   [xyzc,tric] = combmshc(datlcct,datmcct,dattcct);
   datsc = comb_dat(datlcst,datmcst,dattcst);
%
% Reverse X-Axis for Right Knees
%
   [nsl,ns,is] = sl_info(datsc);
   if leg
     xyza(:,1) = -xyza(:,1);
     xyzc(:,1) = -xyzc(:,1);
     for ks = 1:nsl
        datsc{ks}(:,1) = -datsc{ks}(:,1);
     end
   end
%
   tris = mk_tri4f(datsc);             % Sagittal digitization
   xyzs = cell2mat(datsc);
%
% Plot Separate Digitizations
%
   if iplt2
     figure;
     orient landscape;
     hma = trimesh(tria,xyza(:,1),xyza(:,2),xyza(:,3), ...
                  'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.5 0.5 0.5]);
     axis equal;
     xlabel('X (mm)','FontSize',12,'FontWeight','bold');
     ylabel('Y (mm)','FontSize',12,'FontWeight','bold');
     zlabel('Z (mm)','FontSize',12,'FontWeight','bold');
     title([fstr ' - Axial'],'Interpreter','none','FontSize',16, ...
           'FontWeight','bold');
%
     figure;
     orient landscape;
     hmc = trimesh(tric,xyzc(:,1),xyzc(:,2),xyzc(:,3), ...
                  'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.5 0.5 0.5]);
     axis equal;
     xlabel('X (mm)','FontSize',12,'FontWeight','bold');
     ylabel('Y (mm)','FontSize',12,'FontWeight','bold');
     zlabel('Z (mm)','FontSize',12,'FontWeight','bold');
     title([fstr ' - Coronal'],'Interpreter','none','FontSize',16, ...
           'FontWeight','bold');
%
     figure;
     orient landscape;
     hms = trimesh(tris,xyzs(:,1),xyzs(:,2),xyzs(:,3), ...
                  'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.5 0.5 0.5]);
     axis equal;
     xlabel('X (mm)','FontSize',12,'FontWeight','bold');
     ylabel('Y (mm)','FontSize',12,'FontWeight','bold');
     zlabel('Z (mm)','FontSize',12,'FontWeight','bold');
     title([fstr ' - Sagittal'],'Interpreter','none','FontSize',16, ...
           'FontWeight','bold');
   end
%
% Convert to Cylindrical Coordinates
%
   [thetaa,ra,za] = cart2pol(xyza(:,1),xyza(:,3),xyza(:,2));
   id = find(thetaa>pi/2);             % Trap for Angles Greater Than 90 degrees (pi/2 radians)
   if ~isempty(id)
     thetaa(id) = thetaa(id)-2*pi;
   end
   thetaa = thetaa*rad2deg;
   trza = [thetaa ra za];              % Combine coordinates in an array
%
   [thetac,rc,zc] = cart2pol(xyzc(:,1),xyzc(:,3),xyzc(:,2));
   id = find(thetac>pi/2);             % Trap for Angles Greater Than 90 degrees (pi/2 radians)
   if ~isempty(id)
     thetac(id) = thetac(id)-2*pi;
   end
   thetac = thetac*rad2deg;
   trzc = [thetac rc zc];              % Combine coordinates in an array
%
   [datsct] = xzpl2pol(datsc);
   trzs = cell2mat(datsct);            % Sagittal digitization
   trzs(:,1) = trzs(:,1)*rad2deg;
%
% Plot Separate Digitizations in Theta-Z
%
   if iplt2
     figure;
     orient landscape;
     hma = trimesh(tria,trza(:,1),trza(:,3),trza(:,2), ...
                  'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.5 0.5 0.5]);
     axis equal;
     xlabel('\Theta (degrees)','FontSize',12,'FontWeight','bold');
     ylabel('Z (mm)','FontSize',12,'FontWeight','bold');
     zlabel('R (mm)','FontSize',12,'FontWeight','bold');
     title([fstr ' - Axial'],'Interpreter','none','FontSize',16, ...
           'FontWeight','bold');
%
     figure;
     orient landscape;
     hmc = trimesh(tric,trzc(:,1),trzc(:,3),trzc(:,2), ...
                  'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.5 0.5 0.5]);
     axis equal;
     xlabel('\Theta (degrees)','FontSize',12,'FontWeight','bold');
     ylabel('Z (mm)','FontSize',12,'FontWeight','bold');
     zlabel('R (mm)','FontSize',12,'FontWeight','bold');
     title([fstr ' - Coronal'],'Interpreter','none','FontSize',16, ...
           'FontWeight','bold');
%
     figure;
     orient landscape;
     hms = trimesh(tris,trzs(:,1),trzs(:,3),trzs(:,2), ...
                  'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.5 0.5 0.5]);
     axis equal;
     xlabel('\Theta (degrees)','FontSize',12,'FontWeight','bold');
     ylabel('Z (mm)','FontSize',12,'FontWeight','bold');
     zlabel('R (mm)','FontSize',12,'FontWeight','bold');
     title([fstr ' - Sagittal'],'Interpreter','none','FontSize',16, ...
           'FontWeight','bold');
   end
%
% Interpolate the Cartilage Data to the Standard Grid
% Use scatteredInterpolant?
%
   tgrida = TriScatteredInterp(trza(:,[1 3]),trza(:,2),'linear');
   ra = tgrida([tq zq]);               % Get interpolated radii
   ita = in_tri2d(tria,trza(:,[1 3]),[tq zq]);   % Find radii within original area (no extrapolation)
   ra(~ita) = 0;        % Set all radii outside of the mesh to zero (0)
%
   tgridc = TriScatteredInterp(trzc(:,[1 3]),trzc(:,2),'linear');
   rc = tgridc([tq zq]);               % Get interpolated radii
   itc = in_tri2d(tric,trzc(:,[1 3]),[tq zq]);   % Find radii within original area (no extrapolation)
   rc(~itc) = 0;        % Set all radii outside of the mesh to zero (0)
%
   tgrids = TriScatteredInterp(trzs(:,[1 3]),trzs(:,2),'linear');
   rs = tgrids([tq zq]);               % Get interpolated radii
   its = in_tri2d(tris,trzs(:,[1 3]),[tq zq]);   % Find radii within original area (no extrapolation)
   rs(~its) = 0;        % Set all radii outside of the mesh to zero (0)
%
   rq = (ra+rc+rs)./(ita+itc+its);
%
% Get Cartilage Mesh and Coordinates
%
   it = ita|itc|its;
   rq(~it) = -1;        % Missing radii assigned to -1
   idx = find(it);
   ir = nod2tri(idx,trig,2);
   trisc = trig(ir,:);
   [trzsc,trisc] = comp_msh([tq rq zq],trisc);   % Compress nodes
%
   trz = trzsc;
   trz(:,1) = trz(:,1)./rad2deg;
   [x,z,y] = pol2cart(trz(:,1),trz(:,2),trz(:,3));
   xyzsc = [x y z];
%
   trisc = tri_fix2(trisc,xyzsc);      % Not necessary?  Check of mesh
%
% Save Data
%
   fsav = fullfile(ddir,[fstr 'sc.mat']);
   save(fsav,'datsb','datsc','trisb','trisc','trzsc', ...
        'xyzsb','xyzsc');
%
   fprintf(1,'File number %i completed!\n',kf);
%
% Plot Combined Cartilage Mesh
%
   if iplt
     figure(hf1);
     orient landscape;
     view(2);
     hold on;
     hap = plot3(trza(:,1),trza(:,3),trza(:,2),'b.','MarkerSize',4, ...
                 'LineWidth',0.5);
     hcp = plot3(trzc(:,1),trzc(:,3),trzc(:,2),'g.','MarkerSize',4, ...
                 'LineWidth',0.5,'Color',[0 0.5 0]);
     hsp = plot3(trzs(:,1),trzs(:,3),trzs(:,2),'r.','MarkerSize',4, ...
                 'LineWidth',0.5);
     hmp = trimesh(trisc,trzsc(:,1),trzsc(:,3),trzsc(:,2), ...
                   'FaceColor',[0.7 0.7 0.7],'EdgeColor', ...
                   [0.5 0.5 0.5],'LineWidth',0.25);
     xlabel('\Theta (degrees)','FontSize',12,'FontWeight','bold');
     ylabel('Z (mm)','FontSize',12,'FontWeight','bold');
     zlabel('R (mm)','FontSize',12,'FontWeight','bold');
     title(fstr,'Interpreter','none','FontSize',16,'FontWeight','bold');
%     axis([-225 50 -50 40]);
     print('-dpsc2','-r300',[fstr '_sc.ps']);
%
     figure(hf2);
     orient landscape;
     view(3);
     hold on;
     ha = plot3(xyza(:,1),xyza(:,2),xyza(:,3),'b.','MarkerSize',4, ...
                'LineWidth',0.5);
     hc = plot3(xyzc(:,1),xyzc(:,2),xyzc(:,3),'g.','MarkerSize',4, ...
                'LineWidth',0.5,'Color',[0 0.5 0]);
     hs = plot3(xyzs(:,1),xyzs(:,2),xyzs(:,3),'r.','MarkerSize',4, ...
                'LineWidth',0.5);
     hm = trimesh(trisc,xyzsc(:,1),xyzsc(:,2),xyzsc(:,3), ...
                  'FaceColor',[0.7 0.7 0.7],'EdgeColor', ...
                  [0.5 0.5 0.5],'LineWidth',0.25);
     axis equal;
     xlabel('X (mm)','FontSize',12,'FontWeight','bold');
     ylabel('Y (mm)','FontSize',12,'FontWeight','bold');
     zlabel('Z (mm)','FontSize',12,'FontWeight','bold');
     title(fstr,'Interpreter','none','FontSize',16,'FontWeight','bold');
%      axis([-36 38 -48 40 -34 16]);
     print('-dpsc2','-r300','-append',[fstr '_sc.ps']);
%          
     figure(hf3);
     orient landscape;
     view(3);
     hold on;
     hm = trimesh(trisc,xyzsc(:,1),xyzsc(:,2),xyzsc(:,3), ...
                  'FaceColor',[0.7 0.7 0.7],'EdgeColor', ...
                  [0.5 0.5 0.5],'LineWidth',0.25);
     hb = trimesh(trisb,xyzsb(:,1),xyzsb(:,2),xyzsb(:,3), ...
                  'FaceColor',[0 0.5 0],'EdgeColor', ...
                  [0.5 0.5 0.5],'LineWidth',0.25);
     axis equal;
     xlabel('X (mm)','FontSize',12,'FontWeight','bold');
     ylabel('Y (mm)','FontSize',12,'FontWeight','bold');
     zlabel('Z (mm)','FontSize',12,'FontWeight','bold');
     title([fstr ' Combined'],'Interpreter','none','FontSize',16, ...
           'FontWeight','bold');
%      axis([-36 38 -48 40 -34 16]);
     print('-dpsc2','-r300','-append',[fstr '_sc.ps']);
%
%       pause;
%
     clf(hf1);
     clf(hf2);
     clf(hf3);
%
   end
end
%
return