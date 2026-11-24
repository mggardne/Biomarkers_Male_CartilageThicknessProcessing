%#######################################################################
%
%                        * Tibia_CS_Save Program *
%
%         Program to read and plot tibia coordiante system data, determine
%         the axes and origin 
%         11-Nov-2013 * Daniel Sturnick
%                       
%
%#######################################################################
% Get Directory
%
% fdir = uigetdir;
% fdir = [fdir '\'];
  fdir = 'bm male tibia cs';

%
% Get CSV Files in Directory
%
d = dir(fullfile(fdir, '*AX_EA.csv'));
nams = char(d.name);
[nfiles,nc] = size(nams);
%
% Reorder Files So 10s, 100s, etc. Are Sorted Properly
%
idx = zeros(nfiles,1);
for k = 1:nfiles
   id = strfind(nams(k,:),'_');
   idx(k) = id(1);
end
idr = 1;
nam2 = ' ';
nam2 = nam2(ones(nfiles,nc));
for k = 2:max(idx)
   id = find(idx==k);
   nr = size(id,1);
   nam2(idr:idr+nr-1,:) = sortrows(nams(id,:));
   idr = idr+nr;
end
nams = nam2;
clear id idr idx k nam2 nr;
%
% Let User Select CSV Data File(s)
%
ok = 0;
while (ok==0)
     [filesel,ok] = listdlg('ListString',nams,'Name', ...
     'ROI Axial CSV Data Files','PromptString', ...
     'Select a file for plotting','SelectionMode','multiple');
%      'Select a file for plotting','SelectionMode','single');
end
%
fnams = nams(filesel,:);
ifiles = 1;
nfiles = size(fnams,1);
hf = figure; 
% Loop through Knees
%
for k = ifiles:nfiles
%
   ks = int2str(k);     % Index as a string
%
% File Names
%
   fnam = deblank(fullfile(fdir,fnams(k,:)));         % File name without trailing blanks
%
   fnam1 = fnam%
% Get knee information
%
   idu = strfind(fnam(1,:),'_');
   num_knee = str2double(fnam(1,1:idu(1)-1));
   if strcmp(fnam(idu(1)+1),'R');
     leg = true;        % Right leg
   else
     leg = false;       % Left leg
   end
   knum = fnam(1,1:idu(1)+1);
   while size(knum,2)<5
       knum = ['0' knum];
   end
   %[subj,cas,inj,sex,sur,prev,ar] = subj_inf(knum);
%
% Get Tibial Coordinate System
%
   figure(hf);
   [xyzc,xyzr] = tibia_cs6(fnam1,leg,true);
   roi = rd_roi3(fnam1);
   roinams = lower(char(roi.name));
%
% Get Proximal Tibia Located In Tibia CS
%
   idc = strmatchn('prox_tibia',roinams,'exact');
   xyz = cell2mat(roi(idc).data);
   xyz = xyz - repmat(xyzc,size(xyz,1),1);
   xyz = xyz*xyzr;
%
%  Give variables more explicit names
%
   xyzpt = xyz;
   roics = roi;
%
% Save Tibia CS Info
%
save([knum '_TibiaCS'],'roics','xyzpt','xyzc','xyzr','leg');
clf(hf);
   
end







