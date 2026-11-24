%#######################################################################
%
%              * DIGitization CHecK of Trochlea Program *
%
%          M-File which reads MRI knee data cell arrays and checks
%     between the sagittal and axial digitization.  The program uses
%     digitization data from two time points.
%
%     NOTES:  1.  Uses MAT files in "Ben Reliability Timepoint?"
%             directories where ? equals either 1 or 2 for the two
%             time points.
%
%             2.  M-file circ_fit.m, circ_ft3.m, comb_dat.m, cyl2cart.m,
%             cyl_trnf.m, dig_rdif.m, in_tri2d.m, mk_tri3.m, mk_tri4.m,
%             plane_fit.m, plt_datsl.m, sl_dir.m and sl_info.m must be
%             in the current path or directory.
%
%     07-July-2014 * Mack Gardner-Morse
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
roff = 4;               % Spreadsheet row offset
%
% Conversion from Degrees to Radians
%
deg2rad = pi/180;
%
% Write Headers to MS-Excel Spreadsheet
%
% xnam = 'dig_chkt.xlsx';
xnam = 'zx.xlsx';
htxt = 'Radial Digitization Differences (mm) between Axial and ';
htxt = [htxt 'Sagittal Digitizations at Time Point 1'];
xlswrite(xnam,{htxt},1,'A1');
xlswrite(xnam,{'Knee'},1,'A2');
xlswrite(xnam,{'Trochlea Cartilage'},1,'B2');
xlswrite(xnam,{'Num'},1,'A3');
hdr = {'Mean','SD','Min','Max','AbsAvg'};
xlswrite(xnam,hdr,1,'B3');
%
% Loop Through Time Points
%
for kt = 1:2            % Time points 1 and 2
%
   ddir = [ddirs int2str(kt) '\'];
   data = zeros(nf,5);
%
% Loop through MAT Files
%
   for kf = 1:nf        % Loop through MAT files
%
% Read Data Files from Directories
%
      fnam = fnams(kf,:);              % File name
      idot = strfind(fnam,'.');
      fstr = fnam(1:idot-1);           % File name w/o extension
%
      load([ddir fnam]);
%
% Convert to Cylindrical Coordinates Using Bone Data at Time Point 2
%
      [dlb,dmb,dlc,dmc,dtc1,dtc2,ro,r] = cyl_trnf(datlb,datmb,datlc, ...
                                                  datmc,dattc1,dattc2);
%
% Combine Sagittal Data DAT Files
%
      dts = comb_dat(dlc,dmc,dtc1);
%
% Find Radial Differences
%
      [davg,dstd,dmin,dmax,daavg,dr] = dig_rdif(dtc2,dts,true);
%
% Save Summary Statistics
%
      data(kf,:) = [davg,dstd,dmin,dmax,daavg];
%
% Update Title for Current File and Time
%
      ht = get(gca,'Title');
      tstr = get(ht,'String');
      tstr = {[fstr ' - Time ' int2str(kt)]; tstr};
      set(ht,'String',tstr);
%
%       pause;
      close;            % Close figure
%
%  Transform Sagittal Data Back
%
      idg = ~isnan(dr); % Trochlea (good - non NaN) values
      idp = find(dr>0); % Positive radial differences
      idn = find(dr<0); % Negative radial differences
      [val,idmx] = max(dr);            % Maximum radial differences
      [val,idmn] = min(dr);            % Minimum radial differences
      idp = setdiff(idp,idmx);
      idn = setdiff(idn,idmn);
%
      trzs = cell2mat(dts);            % Condyle coordinates
      trzs2 = trzs;
      trzs2(:,2) = trzs2(:,2)+dr;      % Intersection points
%
% Convert to Cartesian Coordinates
%
      [xyzs,xyzs2] = cyl2cart(trzs,ro,r,trzs2);
%
% Trochlea Mesh
%
      trit = mk_tri4(dattc2);
      xyzt = cell2mat(dattc2);
%
% Plot Original Data
%
      figure;
      orient landscape;
      hm = trimesh(trit,xyzt(:,1),xyzt(:,2),xyzt(:,3),'EdgeColor', ...
                   [0.75 0.75 0.75],'FaceColor','none','LineWidth',0.5);
      axis equal;
      hold on;
%
% Plot Sagittal Data
%
      plt_datsl(datlc,'k-',0.5,[0.45 0.45 0.45]);
      plt_datsl(datmc,'k-',0.5,[0.45 0.45 0.45]);
      plt_datsl(dattc1,'k-',0.5,[0.45 0.45 0.45]);
%
% Plot Radial Differences
%
      plot3([xyzs(idn,1) xyzs2(idn,1)]',[xyzs(idn,2) ...
            xyzs2(idn,2)]',[xyzs(idn,3) xyzs2(idn,3)]','r-', ...
            'Color',[0.5 0 0],'LineWidth',2);
%
      plot3([xyzs(idp,1) xyzs2(idp,1)]',[xyzs(idp,2) ...
            xyzs2(idp,2)]',[xyzs(idp,3) xyzs2(idp,3)]','b-', ...
            'Color',[0 0 0.5],'LineWidth',2);
%  
      plot3([xyzs(idmn,1) xyzs2(idmn,1)]',[xyzs(idmn,2) ...
            xyzs2(idmn,2)]',[xyzs(idmn,3) xyzs2(idmn,3)]','r-', ...
            'LineWidth',3);
%
      plot3([xyzs(idmx,1) xyzs2(idmx,1)]',[xyzs(idmx,2) ...
            xyzs2(idmx,2)]',[xyzs(idmx,3) xyzs2(idmx,3)]','b-', ...
            'LineWidth',3);
%
% Plot Labels
%
      axis tight;
      axis equal;
%
      axlim = axis;
      txtc = axlim([1 4 6]);
      txtc = [0.98 0.98 1.05].*(txtc<0).*txtc+ ...
             [1.02 1.02 0.95].*(txtc>0).*txtc;
      text(txtc(1),txtc(2),txtc(3),{['Mean Difference = ', ...
           num2str(davg) ' mm']; ['SD = ' num2str(dstd) ' mm']; ...
           ['Minimum Difference = ' num2str(dmin) ' mm']; ...
           ['Maximum Difference = ' num2str(dmax) ' mm']}, ...
           'FontSize',12,'FontWeight','bold');
%
      xlabel('X (mm)','FontSize',12,'FontWeight','bold');
      ylabel('Y (mm)','FontSize',12,'FontWeight','bold');
      zlabel('Z (mm)','FontSize',12,'FontWeight','bold');
      title(tstr,'FontSize',16,'FontWeight','bold', ...
            'Interpreter','none');
%
% Save Plot
%
      if kf==1
        print('-dpsc2',['dig_chkt_' int2str(kt) '.ps']);
      else
        print('-dpsc2','-append',['dig_chkt_' int2str(kt) '.ps']);
      end
%
%       pause;
      close;            % Close figure
%
   end
%
% Write Summary Statistics
%
   if kt==2
     htxt2 = htxt;
     htxt2(end) = '2';
     irow = (kt-1)*kf+roff+1;
     xlswrite(xnam,{htxt2},1,['A' int2str(irow)]);
     irow = irow+1;
     xlswrite(xnam,{'Knee'},1,['A' int2str(irow)]);
     xlswrite(xnam,{'Trochlea Cartilage'},1,['B' int2str(irow)]);
     irow = irow+1;
     xlswrite(xnam,{'Num'},1,['A' int2str(irow)]);
     xlswrite(xnam,hdr,1,['B' int2str(irow)]);
   end
   irow = (kt-1)*kf+kt*roff;
   xlswrite(xnam,cellstr(fnams(:,1:idot-1)),1,['A' int2str(irow)]);
   xlswrite(xnam,data,1,['B' int2str(irow)]);
%
end
%
return