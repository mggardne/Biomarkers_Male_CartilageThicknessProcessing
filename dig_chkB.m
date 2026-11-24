%#######################################################################
%
%                * DIGitization CHecK for Ben Program *
%
%          M-File which reads MRI knee data cell arrays and checks the
%     digitization between two time points.
%
%     NOTES:  1.  Uses MAT files in "Ben Reliability Timepoint?"
%             directories where ? equals either 1 or 2 for the two
%             time points.
%
%             2.  M-file circ_fit.m, circ_ft3.m, cyl_trnf.m, dig_rdif.m,
%             in_tri2d.m, mk_tri3.m, mk_tri4.m plane_fit.m and sl_info.m
%             must be in the current path or directory.
%
%     03-July-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Data Directories and File Names
%
ddirs = 'Ben Reliability Timepoint ';
fnams = [ '012_R_BAbc.mat'
          '014_R_BAbc.mat'
          '015_L_BAbc.mat'
          '018_R_BAbc.mat'
          '020_R_BAbc.mat'
          '026_R_BAbc.mat'
          '029_L_BAbc.mat'
          '032_R_BAbc.mat'
          '034_R_BAbc.mat'
          '036_R_BAbc.mat'
          '039_L_BAbc.mat'
          '042_R_BAbc.mat'
          '044_R_BAbc.mat'
          '046_R_BAbc.mat'
          '048_R_BAbc.mat' ];
%
nf = size(fnams,1);     % Number of files
%
% Variable Names
%
icomp = ['l'; 'm'];
ityp = ['b'; 'c'];
%
ivar = 'dat';
vars = { 'datlb'
         'datlc'
         'datmb'
         'datmc'
         'dattb'
         'dattc1'
         'dattc2' };
%
nv = size(vars,1);      % Number of variables
%
tvars = strrep(vars,'at','');          % Transformed variable names
%
% Spreadsheet Columns for Headers and Row Offset
%
rcol = (66:5:66+5*(nv-1))';
idr = find(rcol>90);
rcol(idr) = rcol(idr)-26;
rcol = [char(rcol) repmat(' ',nv,1)];
rcol(idr,:) = [repmat('A',size(idr,1),1) rcol(idr,1)];
rcol = cellstr(rcol);   % Spreadsheet columns
roff = 2;               % Spreadsheet row offset
%
% Write Headers to MS-Excel Spreadsheet
%
% xnam = 'dig_chkB.xlsx';
xnam = 'zx.xlsx';
xlswrite(xnam,{'Knee'},1,'A1');
for kv = 1:nv
   xlswrite(xnam,vars(kv),1,[rcol{kv} '1']);
end
xlswrite(xnam,{'Num'},1,'A2');
hdr = {'Mean','SD','Min','Max','AbsAvg'};
hdr = repmat(hdr,1,nv);
xlswrite(xnam,hdr,1,'B2');
%
% Loop through MAT Files
%
% for kf = 1:nf           % Loop through MAT files
for kf = 2              % Loop through MAT files
%
   fnam = fnams(kf,:);
   idot = strfind(fnam,'.');
   fstr = fnam(1:idot-1);              % File name w/o extension
%
% Read Data Files from Both Directories
%
   for kt = 1:2            % Time points 1 and 2
%
      ddir = [ddirs int2str(kt) '\'];
      load([ddir fnam]);
%
% Save Variables
%
      for kv = 1:nv
         var = vars{kv};
         eval([var int2str(kt) '=' var ';']);
      end
%
   end
%
% Convert to Cylindrical Coordinates Using Bone Data at Time Point 2
%
   [dlb2,dmb2,dlb1,dlc1,dmb1,dmc1,dtb1,dtc11,dtc21,dlc2,dmc2,dtb2, ...
   dtc12,dtc22] = cyl_trnf(datlb2,datmb2,datlb1,datlc1,datmb1, ...
   datmc1,dattb1,dattc11,dattc21,datlc2,datmc2,dattb2,dattc12,dattc22);
%
% Find Radial Differences
%
   data = zeros(1,5*nv);
%    for kv = 1:nv
%    for kv = nv-1:nv
   for kv = [2 4 6 7];
      idx = 5*kv;
      idx = idx-4:idx;
      tvar = tvars{kv};
      [davg,dstd,dmin,dmax,daavg] = eval(['dig_rdif(' tvar '1,' tvar ...
                                          '2,true);']);
%
% Save Summary Statistics
%
      data(idx) = [davg,dstd,dmin,dmax,daavg];
%
% Save Plots
%
      var = vars{kv};
      ht = get(gca,'Title');
      tstr = get(ht,'String');
      tstr = {[fstr ' - ' var]; tstr};
      set(ht,'String',tstr);
%       hlx = get(gca,'XLabel');
%       hly = get(gca,'YLabel');
%       set(hlx,'String','Angle (degrees)');
%       set(hly,'String','Radius (mm)');
      if kv==1
        print('-dpsc2',['dig_chkB_' fstr '.ps']);
      else
        print('-dpsc2','-append',['dig_chkB_' fstr '.ps']);
      end
%
%       pause;
%       close;            % Close figure
%
   end
%
% Write Summary Statistics
%
   irow = kf+roff;
   xlswrite(xnam,{fstr},1,['A' int2str(irow)]);
   xlswrite(xnam,data,1,['B' int2str(irow)]);
%
end
%
return