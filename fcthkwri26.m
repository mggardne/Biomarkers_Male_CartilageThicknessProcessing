%#######################################################################
%
%            * Femur Cartilage THicKness WRIte 26 Program *
%
%          M-File which reads the cartilage thicknesses for 26
%     biomarkers study femurs and writes out the female cartilage
%     thicknesses to six MS-Excel spreadsheets, fcthkbm_f_ant_lat.xlsx,
%     fcthkbm_f_ant_med.xlsx, fcthkbm_f_ctr_lat.xlsx,
%     fcthkbm_f_ctr_med.xlsx, fcthkbm_f_pos_lat.xlsx and
%     fcthkbm_f_pos_med.xlsx.
%
%     NOTES:  1.  MAT files fb_rnga.mat and fcthka26.mat must be in the
%             current directory.
%
%             2.  MS-Excel files Biomark_MRI_StudyKey.xlsx and
%             Partitions6_fe.xlsx must also be in the current directory.
%
%             3.  MS-Excel files with Femur-Tibia Orientation Data and
%             Subject Demographics have not yet been incorporated.
%
%             4.  M-files get_subj.m and bmsubj_fil.m must be in the
%             current path or directory.
%
%             5.  All 26 femurs are female case femurs.
%
%     30-Nov-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Get "Standard" Grid
%
load fb_rngf.mat;
npts = size(tq,1);
lbl = mat2cell([repmat('Pt ',npts,1) int2str((1:npts)')],ones(npts,1))';
%
% Data Directory and File Names
%
if ismac
  ddir = 'BM_Female_Femur_MAT_Files';
else
  ddir = 'Biomarker MAT files\';
end
d = dir(fullfile(ddir,'*EAbc7tsc.mat'));
fnams = deblank(char(d.name));
nf = size(fnams,1);     % Number of files
%
% Load Cartilage Thickness Data
%
load fcthkf.mat;
%
% Get Number of Knees (Femurs)
%
nc = 2;                                % Left/right
nknee = size(fnams,1);
nsets = nknee/nc;
%
ida = (1:nknee)';                      % Index to all 26 knees (femurs)
ids = ida(1:2:nknee);                  % Index to the 13 sets of knees
%
% Load File Names and Flags (Days not yet implemented)
%
[fnam2,flags] = bmsubj_fil(7);
fnam1 = char(fnam2(:,1));
fnam2 = char(fnam2(:,2));
% days = cell2mat(days(ids));
days = NaN(nknee,1);
%
% Get Matching File IDs
%
[idn,idnum] = get_subj(fnams(ids,:));
[idn1,idnum1] = get_subj(fnam1);
[idn2,idnum2] = get_subj(fnam2);
idxs = zeros(nsets,1);
for k = 1:nsets
   id = find(idnum1==idnum(k));
   if isempty(id)
     id = find(idnum2==idnum(k));
   end
   idxs(k) = id;
end
%
% Flags for Sex
%
sex = flags(idxs,1);
idf = find(sex==0);
isex = zeros(2,nsets);
isex = isex(:,idf);
isex = isex(:);
idfall = [(1:2:nknee); (2:2:nknee)];
% idmall = idfall;
idfall = idfall(:,idf);
idfall = idfall(:);
%
% idmales = find(sex==1);
% idmall = idmall(idmales,:);
% idmall = idmall(:);
%
[idn,idnum] = get_subj(fnams(ida,:));
leg = ones(nknee,1);
leg(strmatch('R',fnams(ida,5))) = 0;
%
% Get Injured (0) or Uninjured (1) Sides
%
[fs,idfs] = sort([idnum1(idxs) idnum2(idxs)]');
inj = idfs(:)-1;        % Injured = 0, Uninjured = 1
%
% Get Matching Pairs of Knees (Femurs)
%
idmtch = (1:nsets);
idmtch = [idmtch; idmtch];
idmtch = idmtch(:);
%
% Get Demographics
%
% demog = xlsread('Subject Demographics.xlsx');
% kid = demog(:,2);
% dahw = demog(:,12:15);
% [tf,idx] = ismember(idnum,kid);
% dahw = dahw(idx,:);
% ahw = dahw(:,2:4);
ahw = NaN(nknee,3);
%
% Get Relative Femur-Tibia Orientation
%
% pos = xlsread('Femur-Tibia Orientation Data.xlsx','Data','B2:J353');
% kid2 = pos(:,1);
% [tf,idx2] = ismember(idnum,kid2);
% rp = pos(:,6:9);
% rp = rp(idx2,:);
rp = NaN(nknee,4);
%
% Find Valid Thickness Data
%
idv = find(cthk(:,1)~=0);              % Index to valid thicknesses
%
idf = intersect(idf,idv);
idfall = intersect(idfall,idv);
% idmales = intersect(idmales,idv);
% idmall = intersect(idmall,idv);
%
% Convert NaNs to -1
%
id = isnan(cthk);
cthk(id) = -1;
%
% Indices for Regions
%
idreg = xlsread('Partitions6_fe.xlsx');
%
% Write Out to Six MS-Excel Spreadsheets for Female Subjects
% fcthkbm_f_ant_lat.xlsx, fcthkbm_f_ant_med.xlsx,
% fcthkbm_f_ctr_lat.xlsx, fcthkbm_f_ctr_med.xlsx, 
% fcthkbm_f_pos_lat.xlsx, and fcthkbm_f_pos_med.xlsx
%
[idn,idnum] = get_subj(fnams(idfall,:));
fnams = cellstr(fnams(ida,:));
ext_nams = ['pos'; 'ctr'; 'ant'];
cmprt_nams = ['lat'; 'med'];
%
nfemales = size(idfall,1);
nfstr = int2str(nfemales+1);           % Last row in sheet (number of females +1 for title line)
nfsets = size(idf,1);
%
% nmales = size(idmall,1);
% nmstr = int2str(nmales+1);             % Last row in sheet (number of males +1 for title line)
% nmsets = size(idmales,1);
%
lends = ['BMG'; 'AZB'; 'CHI'; 'BXH'; 'BMI'; 'CRM' ];  % Last (end) columns for data (Found experimentally.)
%
for k = 1:3             % Regions (1 => Posterior, 2 => Central, 3 => Anterior
   xlsnamfr = ['fcthkbm_f_' ext_nams(k,:)];
%    xlsnammr = ['fcthkbm_m_' ext_nams(k,:)];
   for l = 1:2          % Compartments (1 => Lateral, 2 => Medial)
      xlsnamf = [xlsnamfr '_' cmprt_nams(l,:) '.xlsx'];
%       xlsnamm = [xlsnammr '_' cmprt_nams(l,:) '.xlsx'];
%
      m = k+(l-1)*3;
      idp = find(idreg==m);
%
% Write Out Female Data
%
      if nfemales>0
        xlswrite(xlsnamf,lbl(idp),1,['Q1:' lends(m,:) '1']);    % Labels
        xlswrite(xlsnamf,fnams(idfall),1,'A2');  % Filename
        xlswrite(xlsnamf,idnum(idfall),1,'B2');  % ID
        xlswrite(xlsnamf,idmtch(idfall),1,'C2'); % Match
        xlswrite(xlsnamf,leg(idfall),1,'D2');    % Leg
        xlswrite(xlsnamf,isex,1,'E2'); % Sex
        xlswrite(xlsnamf,repmat(zeros(nfsets,1),nc,1),1,'F2');  % Case/Cntrl (Case=0)
        xlswrite(xlsnamf,days(idfall),1,'G2');   % Days
        xlswrite(xlsnamf,inj,1,'H2');  % Inj/Uninj
        xlswrite(xlsnamf,repmat(l-1,nfemales,1),1,'I2');   % Compartment
        xlswrite(xlsnamf,rp(idfall,:),1,'J2');   % Relative positions (Flexion, Rotation, AP Trans, ML Trans)
        xlswrite(xlsnamf,ahw(idfall,:),1,'N2');  % Age, Ht, Wt
        xlswrite(xlsnamf,cthk(idfall,idp),1,['Q2:' lends(m,:) nfstr]);
      end
   end
end
%
return