%#######################################################################
%
%     **** Cartilage THiCKness FEMur TIBia POSition  Program ****
%
%          M-File which loads the new biomarkers femur to compare the
%     relative position/orientation of the tibia relative to the femur at
%     the time of MRI data acquisition.
%
%     NOTES:  1.  Scaled MAT files *_sc.mat must be in the directory
%             "Biomarker MAT files".  The MAT files fscale3e.mat and
%             fb_rnga.mat must be in the current path or directory.
%
%             2.  The M-files comb_dat.m, comp_msh.m in_tri2d.m,
%             mk_tri4.m, mk_tri4f.m, plane_fit.m, pol2xzpl.m, sl_dir.m,
%             sl_info.m, tri_fix2.m and xzpl2pol.m must be in the
%             current path or directory.
%
%     11-Nov-2014 * Mack Gardner-Morse
%
%#######################################################################
%
% Plots?
%
iplt = true;
% iplt = false;
iplt2 = false;          % Debugging plots
%
% Convert Radians to Degrees
%
rad2deg = 180/pi;  
%
load fcthkbrk26.mat;
iinj = inj;
%
% Data Directory and File Names
%
load fscale3e.mat;
d = dir('*EAbc7t.mat');
fnams = deblank(char(d.name));

tdir = 'Biomarkers Tibia Bone Mat Files/';
%
nf = size(fnams,1);     % Number of files
%
% Get Standard Grid
%
load fb_rnga.mat;
%
% Load figures
%
hf1 = figure;
hf2 = figure;
%
% Initialize output variables
%
fnums = zeros(nf,1);
ap = zeros(nf,1);
ml = zeros(nf,1);
si = zeros(nf,1);
ir = zeros(nf,1);
vv = zeros(nf,1);
fe = zeros(nf,1);
%
% Loop through MAT Files
%
for kf = 1:nf           % Loop through MAT files
% for kf = [1]          % Loop through MAT files
%
   fnam = fnams(kf,:);                 % File name
   idot = strfind(fnam,'.');
   idu = strfind(fnam,'_');
   fnum = str2double(fnam(1:idu(1)-1));
   fstr = fnam(1:idot-1);              % File name w/o extension
%
% Load Femur Data
%
%   d = dir([fstr(1:8) '*t.mat']);    % Check for modified data
%   fn = sortrows(char(d.name));
%   nfsz = size(fn,1);
%   fn = fn(nfsz,:);     % Use the most recent modified data
%
   load(fnam);
%
% Rename Femur Cordinate System Variables
%
   xyzaxf = xyzax;
   xyzof = xyzo;
%
%  Load Tibia Data 
%
   fnamt = strrep(fnam,'EAbc7t','TibiaCS');
   fnamt = [tdir fnamt];
%
   load(fnamt);
%
%  Rename Tibia Coordinate System Variables
%
   xyzaxt = [xyzr(:,1)'; xyzr(:,2)'; xyzr(:,3)'];
   xyzot = xyzc;
   if leg
       xyzaxt(1,:) = -1*xyzaxt(1,:);
       xyzaxf(1,:) = -1*xyzaxf(1,:);  
   end
%
% Plot Cordinate System Axes
%
   figure(hf1);
   hold on;
   axis equal;
   xcf = repmat(xyzof(1),3,1);
   ycf = repmat(xyzof(2),3,1);
   zcf = repmat(xyzof(3),3,1);
%  
   xct = repmat(xyzot(1),3,1);
   yct = repmat(xyzot(2),3,1);
   zct = repmat(xyzot(3),3,1);
%
   plot3(xcf,ycf,zcf,'go','MarkerSize',9,'LineWidth',2);
   hf = quiver3(xcf,ycf,zcf,xyzaxf(:,1),xyzaxf(:,2),xyzaxf(:,3),50,'b');
   set(hf,'LineWidth',3);
%
   plot3(xct,yct,zct,'ro','MarkerSize',9,'LineWidth',2);
   ht = quiver3(xct,yct,zct,xyzaxt(:,1),xyzaxt(:,2),xyzaxt(:,3),50,'k');
   set(ht,'LineWidth',3);
%
   xyzpt = xyzpt*xyzaxt + repmat(xyzot,size(xyzpt,1),1);%*xyzaxt';
   plot3(xyzpt(:,1),xyzpt(:,2),xyzpt(:,3),'k.-');
   plt_datsl(datlmtb,'b-');
   view(3);
%
   [dataxt_trf,datpt_trf,datot_trf,dataxf_trf,datof_trf] = coord_tf(xyzof,xyzaxf',{xyzaxt},{xyzpt},{xyzot},{xyzaxf},{xyzof});
%   xyzaxt_trf = dataxt_trf{:};
   xyzpt_trf = datpt_trf{:};
   xyzot_trf = datot_trf{:};
%   xyzaxf_trf = dataxf_trf{:};
   xyzof_trf = datof_trf{:};
%
    xyzaxt_trf = zeros(3);
    xyzaxt_trf(1,:) = (xyzaxt(1,:))*xyzaxf';
    xyzaxt_trf(1,:) = xyzaxt_trf(1,:)./norm(xyzaxt_trf(1,:));
    xyzaxt_trf(2,:) = (xyzaxt(2,:))*xyzaxf';
    xyzaxt_trf(2,:) = xyzaxt_trf(2,:)./norm(xyzaxt_trf(2,:));
    xyzaxt_trf(3,:) = (xyzaxt(3,:))*xyzaxf';
    xyzaxt_trf(3,:) = xyzaxt_trf(3,:)./norm(xyzaxt_trf(3,:));
%
    xyzaxf_trf = [1 0 0; 0 1 0; 0 0 1];     
%   
   xcf = repmat(xyzof_trf(1),3,1);
   ycf = repmat(xyzof_trf(2),3,1);
   zcf = repmat(xyzof_trf(3),3,1);
%  
   xct = repmat(xyzot_trf(1),3,1);
   yct = repmat(xyzot_trf(2),3,1);
   zct = repmat(xyzot_trf(3),3,1);
%
   figure(hf2)
   hold on;
   plot3(xcf,ycf,zcf,'go','MarkerSize',9,'LineWidth',2);
   hf = quiver3(xcf,ycf,zcf,xyzaxf_trf(:,1),xyzaxf_trf(:,2),xyzaxf_trf(:,3),50,'b');
   set(hf,'LineWidth',3);
%
   plot3(xct,yct,zct,'ro','MarkerSize',9,'LineWidth',2);
   ht = quiver3(xct,yct,zct,xyzaxt_trf(:,1),xyzaxt_trf(:,2),xyzaxt_trf(:,3),50,'k');
   set(ht,'LineWidth',3);
   axis equal;
   view([0 0 1]);
   xlabel('X (Anterior-Posterior)');
   ylabel('Y (Medial-Lateral');
   zlabel('Z (Inferior-Superior)');
%
%  Save Position of Tibia Relative to Femur
%
   ap(kf) = xyzot_trf(1);
   %if leg
   %    ap(kf) = -1*ap(kf);
   %end
   ml(kf) = xyzot_trf(2);
   si(kf) = xyzot_trf(3);
%   
%  Save Orientation of the Tibia Relative to Femur   
%  
   fnums(kf) = fnum;
   xaxt = xyzaxt_trf(:,1);
   %if leg
   %    xaxt = -1*xaxt;
   %end
   yaxt = xyzaxt_trf(:,2);
   zaxt = xyzaxt_trf(:,3);
   irot = atan2(yaxt(2),yaxt(1)) - atan2(1,0);
   ir(kf) = irot*rad2deg;
   flex = atan2(1,0) - atan2(zaxt(3),zaxt(1));
   fe(kf) = flex*rad2deg;
   vval = atan2(zaxt(3),zaxt(2)) - atan2(1,0);
   vv(kf) = vval*rad2deg;   
   pause;
   clf(hf1);
   clf(hf2);
   
end
%
res = {ap ml si ir fe vv};
match = 1:13;
csvnam1 = 'cthick_femtib_pos_data.csv';
csvnam2 = 'cthick_femtib_pos_diffs.csv';
csvnam3 = 'cthick_femtib_pos_stats.csv';
hdr_txt1 = {'fnam' 'ap' 'ml' 'si' 'ir' 'fe' 'vv'};
hdr_txt2 = {'match' 'knum_inj' 'ap_inj' 'ml_inj' 'si_inj' 'ir_inj' 'fe_inj' 'vv_inj' ...
    'knum_uninj' 'ap_uninj' 'ml_uninj' 'si_uninj' 'ir_uninj' 'fe_uninj' 'vv_uninj' ...
    'ap_diff' 'ml_diff' 'si_diff' 'ir_diff' 'fe_diff' 'vv_diff'};
hdr_txt3 = {'' 'ap_inj' 'ml_inj' 'si_inj' 'ir_inj' 'fe_inj' 'vv_inj' ...
    'ap_uninj' 'ml_uninj' 'si_uninj' 'ir_uninj' 'fe_uninj' 'vv_uninj' ...
    'ap_diff' 'ml_diff' 'si_diff' 'ir_diff' 'fe_diff' 'vv_diff'};
fid = fopen(csvnam1,'w');
fid2 = fopen(csvnam2,'w');
fid3 = fopen(csvnam3,'w');
nc = size(hdr_txt1,2);
for k = 1:nc-1
     fprintf(fid,'"%s",',hdr_txt1{k});
end
fprintf(fid,'"%s"\n',hdr_txt1{nc});
nc = size(hdr_txt2,2);
for k = 1:nc-1
     fprintf(fid2,'"%s",',hdr_txt2{k});
end
fprintf(fid2,'"%s"\n',hdr_txt2{nc});
nc = size(hdr_txt3,2);
for k = 1:nc-1
     fprintf(fid3,'"%s",',hdr_txt3{k});
end
fprintf(fid3,'"%s"\n',hdr_txt3{nc});
res1 = [fnums res{:}];
dlmwrite(csvnam1,res1,'-append');
%
resm = [res{:}];
res_f_case_inj = resm(find(iinj),:);
res_f_case_uninj = resm(find(~iinj),:);
pdiffs = {res_f_case_inj-res_f_case_uninj};
res2 = [match' fnums(find(iinj)) res_f_case_inj fnums(find(~iinj)) res_f_case_uninj pdiffs{:}];
dlmwrite(csvnam2,res2,'-append');
%
res3 = [res_f_case_inj res_f_case_uninj pdiffs{:}];
stdev = std(res3);
mx = max(res3);
mn = min(res3);
ave = mean(res3);
stats = [ave; mx; mn; stdev];
%
[h,p] = ttest(res_f_case_inj,res_f_case_uninj,0.05,'both');
%
dlmwrite(csvnam3,stats,'-append');
dlmwrite(csvnam3,p,'-append');

fclose all;
%
save cthick_femtib_pos ap ml si ir fe vv fnums;
