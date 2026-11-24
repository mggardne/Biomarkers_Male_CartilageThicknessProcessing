%#######################################################################
%
%                     * Femur SLice CHecK Program *
%
%          M-File which reads the biomarkers subchondral bone and
%     cartilage MAT files, transform the data to the femur coordinate
%     system and checks that the cartilage data digitized in the
%     sagittal plane is ordered properly.  Slices not properly ordered
%     are sorted based on the angle coordinate (theta) and saved to MAT
%     files "*m.mat".  The orginal and modified slice data is plotted
%     on screen for verification (original is plotted in blue and the
%     modified is plotted in black).
%
%     NOTES:  1.  Only checks the cartilage digitized in the sagittal
%             plane cell arrays (datlc, datmc and dattc1).
%
%             2.  The MAT data files must be in the "Biomarker MAT
%             files" directory.
%
%             3.  The M-files cyl_fit.m, cyl_plt.m, dist2cyl.m,
%             f_cs_14.m, plt_datsl.m, pt2line.m, pts2lin.m, sl_info.m
%             and tri_area.m  must be in the current path or directory.
%
%             4.  Requires the Matlab optimization toolbox.
%
%     19-Aug-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Data Directory and File Names
%
ddir = 'Biomarker MAT files';
d = dir(fullfile(ddir,'*_BAbc.mat'));
fnams = char({d.name}');
nf = size(fnams,1);
%
% Get Modified Files' IDs
%
idf = xlsread(fullfile(ddir,'Edited Knees.xlsx'));
nfix = size(idf,1);
idfs = char(strrep(cellstr(int2str(idf)),' ','0'));
%
idxf = zeros(nfix,1);
for k = 1:nfix
   idxf(k) = strmatch(idfs(k,:),fnams(:,1:3));
end
%
% Constants
%
hpi = pi/2;             % Half pi
dpi = 2*pi;             % Double pi
%
% Loop through MAT Files
%
hf1 = figure;
hf2 = figure;
hf3 = figure;
%
for k = 1:nfix          % Loop through MAT files
%
   kf = idxf(k);
   fnam = fnams(kf,:);                 % File name
   idot = strfind(fnam,'.');
   fstr = fnam(1:idot-1);              % File name w/o extension
%
% Load Data
%
   load(fullfile(ddir,fnam));
%
% Transform to Femur Coordinate System
%
   [xyzo,xyzax] = f_cs_14(datlb,datmb,datfs,datcp,false);
   [datlct,datmct,dattct] = coord_tf(xyzo,xyzax',datlc,datmc,dattc1);
%
% Get Slice Information
%
   [nlc,nslc,islc] = sl_info(datlct);
   [nmc,nsmc,ismc] = sl_info(datmct);
   [ntc,nstc,istc] = sl_info(dattct);
%
% Transform to Cylindrical Coordinate System
%
   xyzlc = cell2mat(datlct);
   xyzmc = cell2mat(datmct);
   xyztc = cell2mat(dattct);
%
   [tlc,rlc,zlc] = cart2pol(xyzlc(:,1),xyzlc(:,3),xyzlc(:,2));
   id = find(tlc>hpi);                 % Greater than pi/2
   tlc(id) = tlc(id)-dpi;              % Minus 2*pi
%
   [tmc,rmc,zmc] = cart2pol(xyzmc(:,1),xyzmc(:,3),xyzmc(:,2));
   id = find(tmc>hpi);                 % Greater than pi/2
   tmc(id) = tmc(id)-dpi;              % Minus 2*pi
%
   [ttc,rtc,ztc] = cart2pol(xyztc(:,1),xyztc(:,3),xyztc(:,2));
   id = find(ttc>hpi);                 % Greater than pi/2
   ttc(id) = ttc(id)-dpi;              % Minus 2*pi
%
% Check Sagittal Cartilage Slices
%
   ilat = true;
   for l = 1:nlc
      idx = islc(l)+1:islc(l+1);
      t = tlc(idx);
      r = rlc(idx);
      z = zlc(idx);
      dt = diff(t);
      dts = sign(dt);
      ddts = diff(dts);
      if any(ddts~=0)
        ilat = false;
        ids = find(ddts~=0);
        signd = dts(ids);
        [ts,idxs] = sort(t);
        dts = diff(ts);
        if sign(dts(1))~=signd(1)
          ts = flipud(ts);
          idxs = flipud(idxs);
        end
        tlc(idx) = ts;
        rlc(idx) = r(idxs);
        zlc(idx) = z(idxs);
      end      
   end
%
   imed = true;
   for l = 1:nmc
      idx = ismc(l)+1:ismc(l+1);
      t = tmc(idx);
      r = rmc(idx);
      z = zmc(idx);
      dt = diff(t);
      dts = sign(dt);
      ddts = diff(dts);
      if any(ddts~=0)
        imed = false;
        ids = find(ddts~=0);
        signd = dts(ids);
        [ts,idxs] = sort(t);
        dts = diff(ts);
        if sign(dts(1))~=signd(1)
          ts = flipud(ts);
          idxs = flipud(idxs);
        end
        tmc(idx) = ts;
        rmc(idx) = r(idxs);
        zmc(idx) = z(idxs);
      end      
   end
%
   itro = true;
   for l = 1:ntc
      idx = istc(l)+1:istc(l+1);
      t = ttc(idx);
      r = rtc(idx);
      z = ztc(idx);
      dt = diff(t);
      dts = sign(dt);
      ddts = diff(dts);
      if any(ddts~=0)
        itro = false;
        ids = find(ddts~=0);
        signd = dts(ids);
        [ts,idxs] = sort(t);
        dts = diff(ts);
        if sign(dts(1))~=signd(1)
          ts = flipud(ts);
          idxs = flipud(idxs);
        end
        ttc(idx) = ts;
        rtc(idx) = r(idxs);
        ztc(idx) = z(idxs);
      end      
   end
%
% Save Files Requiring Changes
%
   if any(~[ilat; imed; itro])
%
% Transform Back to Cartesian Coordinate System
%
     [xyzlc(:,1),xyzlc(:,3),xyzlc(:,2)] = pol2cart(tlc,rlc,zlc);
     [xyzmc(:,1),xyzmc(:,3),xyzmc(:,2)] = pol2cart(tmc,rmc,zmc);
     [xyztc(:,1),xyztc(:,3),xyztc(:,2)] = pol2cart(ttc,rtc,ztc);
%
% Reform Cell Arrays
%
     for l = 1:nlc
        datlct{l} = xyzlc(islc(l)+1:islc(l+1),:);
     end
%
     for l = 1:nmc
        datmct{l} = xyzmc(ismc(l)+1:ismc(l+1),:);
     end
%
     for l = 1:ntc
        dattct{l} = xyztc(istc(l)+1:istc(l+1),:);
     end
%
% Transform Back to MRI Coordinate System
%
     figure(hf1);
     hold on;
     plt_datsl(datlc,'b.-',1);
     view(-170,15);
     title({fstr;'Lateral'},'Interpreter','none','FontSize',16, ...
           'FontWeight','bold');
%
     figure(hf2);
     hold on;
     plt_datsl(datmc,'b.-',1);
     view(-170,15);
     title({fstr; 'Medial'},'Interpreter','none','FontSize',16, ...
           'FontWeight','bold');
%
     figure(hf3);
     hold on;
     plt_datsl(dattc1,'b.-',1);
     view(-170,15);
     title({fstr;'Trochlea'},'Interpreter','none','FontSize',16, ...
           'FontWeight','bold');
%
     [datlc,datmc,dattc1] = tf_coord(xyzax,xyzo,datlct,datmct, ...
                                     dattct);
%
     figure(hf1);
     hold on;
     plt_datsl(datlc,'k.-',1);
     pause;
     clf;
%
     figure(hf2);
     hold on;
     plt_datsl(datmc,'k.-',1);
     pause;
     clf;
%
     figure(hf3);
     hold on;
     plt_datsl(dattc1,'k.-',1);
     pause;
     clf;
%
% Save in New MAT Files
%
     save(fullfile(ddir,[fstr 'm.mat']),'datlc','datmc','dattc1');
%
   end
%
end