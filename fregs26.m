%#######################################################################
%
%               * Femur REGionS from 26 Knees Program *
%
%          M-File which reads the standard grid and plots the trochlea
%     regions from the MS-Excel spreadsheet "Partitions6_fe.xlsx".
%
%     NOTES:  1.  MAT files fb_rnga.mat and M-files meshbnd4.m and
%            nod2tri.m must be in the current directory.
%
%             2.  The MS-Excel spreadsheet, Partitions6_fe.xlsx, must
%             be in the current path or directory.
%
%     25-Nov-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Initialize Variables
%
iplt = true;
% iprt = false;
iprt = true;
%
% MS-Excel Spreadsheet Name
%
xnam = 'Partitions6_f.xlsx';
%
% Get "Standard" Grid
%
load fb_rngf.mat;
%
% Get Unique Z Values in the Lateral and Medial Compartments
%
tol = 1e-8;
% zu = (min(zq):max(zq))';               % Works for integer zq
zs = sort(zq);
izu = find(diff(zs)>tol);
zu = zs([izu; izu(end)+1]);            % Unique Z values
nu = size(zu,1);
%
% Posterior and Medial/Lateral Cutoffs
%
tmin = -145;            % Angle (theta) cutoff (-150, -145, or -140)
y0 = 0;                 % Y cutoff (-1, 0, or 1)
%
% Get Indices to the Posterior and Medial/Lateral Regions
%
ipos = find(tq<=tmin);  % Posterior
idl = find(zq>=y0);     % Lateral
idm = find(zq<y0);      % Medial
%
% Plot Grid
%
figure;
orient landscape;
hg = plot(tq,zq,'k.','MarkerSize',6,'LineWidth',0.5);
hold on;
axis tight;
xlabel({'\Theta (degrees)';['\leftarrow posterior / anterior', ...
       ' \rightarrow']},'FontSize',12,'FontWeight','bold');
ylabel({'Z (mm)';'\leftarrow medial / lateral \rightarrow'}, ...
       'FontSize',12,'FontWeight','bold');
title({'Trochlea Boundaries for'; '26 Knees'},'FontSize',16, ...
      'FontWeight','bold');
%
% Outside Boundary
%
bido = meshbnd4(trig);
%
% Data Directory and File Names
%
ddir = 'BM_Female_Femur_MAT_Files';
d = dir(fullfile(ddir,'*EAbc7t.mat'));
fnams = char(d.name);
nf = size(fnams,1);     % Number of files
%
% Plot Colors and Symbols
%
clr = [0 0 1; 0 1 0; 1 0 0; 0 1 1; 1 0 1; 1 1 0; 0 0 0; 0 0.5 0; ...
       0.5 0 0; 0 0 0.5; 0.5 0 0.5; 0.5 0.5 0.5; 0 0.5 0.5];
clr = [clr; flipud(clr)];
sym = ['o'; 'x'; '+'; 's'; '^'; 'v'; 'p'; '*'; '<'; '>'; 'd'; 'h'; ...
       's'];
sym = [sym; sym];
%
% Loop through File Names
%
hb = zeros(nf,1);
bid = cell(nf,1);
%
for kf = 1:nf           % Loop through file names
%
   fnam = fnams(kf,:);                 % File name
   idot = strfind(fnam,'.');
   fstr = fnam(1:idot-1);              % File name w/o extension
   fs = fstr(1:5);
%
% Indices for Regions
% Lateral anterior (trochlea) = 3 and medial anterior (trochlea) = 6
%
   idreg = xlsread(xnam,fs);
   idtl = find(idreg==3);              % Lateral trochlea
   idtm = find(idreg==6);              % Medial trochlea
%
% Get Trochlea Boundary
%
   irl = nod2tri(idtl,trig,2);
   irm = nod2tri(idtm,trig,2);
   ir = nod2tri([idtl; idtm],trig,2);
   bidt = meshbnd4(trig(ir,:));
   bide = setdiff(bidt,bido);
   bid{kf} = bide;
%
% Plot Boundary
%
   hb(kf) = plot(tq(bide),zq(bide),['k' sym(kf)],'Color',clr(kf,:), ...
                 'LineWidth',0.5);
%
end
%
% Index for Unique Values of Z
%
idz = zeros(nu,nq/nu);
for kz = 1:nu
   zuc = zu(kz);
   idz(kz,:) = find(zq>zuc-tol&zq<zuc+tol)';
end
%
% Get Average Cutoff Angle
%
iant = [];              % Anterior (Trochlea)
tc = zeros(nu,1);
for kz = 2:nu-1
   idt = zeros(nf,1);
   id = idz(kz,:)';
   for kf = 1:nf
      idts = intersect(id,bid{kf});
      idt(kf) = idts(1);
   end
   tc(kz) = mean(tq(idt));
   idx = find(tq(id)>tc(kz));
   iant = [iant; id(idx)];
end
%
tc(1) = tc(2);          % Theta cutoff for first Z values
tc(nu) = tc(nu-1);      % Theta cutoff for last Z values
%
id = idz(1,:)';
idx = find(tq(id)>tc(1));
iant = [iant; id(idx)]; % Anterior index for first Z values
%
id = idz(nu,:)';
idx = find(tq(id)>tc(nu));
iant = [iant; id(idx)]; % Anterior index for last Z values
%
% Plot Anterior Points
%
hga = plot(tq(iant),zq(iant),'r.','MarkerSize',6,'LineWidth',0.5);
%
% Legend
%
hl = legend(hb,fnams(:,1:5));
set(hl,'Interpreter','none','Location','East');
%
if iprt
  print('-dpsc2','-r300','fregs26.ps');
end
%
% Get Remaining Indices to the Six (6) Regions
%
ictr = true(nq,1);
ictr(iant) = false;
ictr(ipos) = false;
ictr = find(ictr);      % Center
%
idl_pos = intersect(idl,ipos);         % Lateral posterior region
idl_ctr = intersect(idl,ictr);         % Lateral center region
idl_ant = intersect(idl,iant);         % Lateral anterior region
%
idm_pos = intersect(idm,ipos);         % Medial posterior region
idm_ctr = intersect(idm,ictr);         % Medial center region
idm_ant = intersect(idm,iant);         % Medial anterior region
%
% Create Index for the Six Regions (1-6)
%
id = ones(nq,1);
id(idl_pos) = 1;
id(idl_ctr) = 2;
id(idl_ant) = 3;
id(idm_pos) = 4;
id(idm_ctr) = 5;
id(idm_ant) = 6;
%
% Write Index to Spreadsheet
%
lbl = mat2cell([repmat('Pt ',nq,1) int2str((1:nq)')],ones(nq,1));
xlswrite(xnam,lbl,'Average','A1');
xlswrite(xnam,id,'Average','B1');
%
% Plot Regions
%
if iplt
  figure;
  plot(tq(idl_ant),zq(idl_ant),'ro','MarkerSize',4,'LineWidth',0.5);
  hold on;
  plot(tq(idm_ant),zq(idm_ant),'mo','MarkerSize',4,'LineWidth',0.5);
  plot(tq(idl_ctr),zq(idl_ctr),'gs','MarkerSize',4,'LineWidth',0.5);
  plot(tq(idm_ctr),zq(idm_ctr),'bs','MarkerSize',4,'LineWidth',0.5);
  plot(tq(idl_pos),zq(idl_pos),'y^','MarkerSize',4,'LineWidth',0.5);
  plot(tq(idm_pos),zq(idm_pos),'c^','MarkerSize',4,'LineWidth',0.5);
  axis tight;
  xlabel({'\Theta (degrees)';['\leftarrow posterior / anterior', ...
         ' \rightarrow']},'FontSize',12,'FontWeight','bold');
  ylabel({'Z (mm)';'\leftarrow medial / lateral \rightarrow'}, ...
         'FontSize',12,'FontWeight','bold');
  title('Average of 26 Femurs','FontSize',16,'FontWeight','bold');
  if iprt
    print('-dpsc2','-r300','-append','fregs26.ps');
  end
end
%
return