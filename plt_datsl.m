function p = plt_datsl(dat,cmstr,lw,colr,lbl)
% PLT_DATSL Plots roi dat files one slice at a time in 3D
%
%        P = PLT_DATSL(DAT) given a cell array containing three(3) column
%        matrices with slice coordinate point data in the cell array, DAT,
%        returns a 3D plot with a default black line for each slice.
%
%        P = PLT_DATSL(DAT,CMSTR) given a cell array containing three(3) column
%        matrices with slice coordinate point data in the cell array, DAT,
%        returns a 3D plot with a marker and color designation of CMSTR.
%
%        P = PLT_DATSL(DAT,CMSTR,lw) adds a designated line width to the
%        integer, lw.
%
%        P = PLT_DATSL(DAT,CMSTR,lw,colr) adds a designated RGB color
%        to the 1x3 vector, colr.
%
%
%        25July2012 Daniel R. Sturnick
%
%#######################################################################
if (nargin<2)
    cmstr = 'k';
end
if (nargin<3)
    lw = .5;
    cl = false;
elseif (nargin<4)
    cl = false;
else
    cl = true;
end
%
if (nargin<5)
  lbl = false;
end
%
if iscell(dat)
  p = [];
  nslice = size(dat,1);
  for s = 1:nslice
     xyz = dat{s};
     if cl
         l = plot3(xyz(:,1),xyz(:,2),xyz(:,3),cmstr,'LineWidth',lw, ...
             'MarkerSize',10,'Color',colr);
     else
         l = plot3(xyz(:,1),xyz(:,2),xyz(:,3),cmstr,'LineWidth',lw, ...
             'MarkerSize',10);
     end
%
     p = [p; l];
%
     if lbl
       t = text(xyz(1,1),xyz(1,2),xyz(1,3),int2str(s),'FontSize', ...
                12,'FontWeight','bold');
%                 12,'FontWeight','bold','Color','r');
       p = [p; t];
     end
  end
else
  fprintf(1,'No slices to plot\n');
  p = NaN;
end
return