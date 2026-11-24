load fcthkbrk26.mat;
npts = size(cthk,2);
%
if ismac
  idreg = xlsread('Partitions6_fe.xls');
else
  idreg = xlsread('Partitions6_fe.xlsx');
end
%
cthk_i = cthk(icase(:,1),:);           % Thicknesses for injured knees
cthk_u = cthk(icase(:,2),:);           % Thicknesses for uninjured knees
%
idvi = ~isnan(cthk_i);  % Valid thicknesses for injured knees
idvu = ~isnan(cthk_u);  % Valid thicknesses for uninjured knees
%
ddv = 2*idvi-idvu;
id2 = find(ddv==2);
ddv(id2) = 0;
id1 = find(ddv==-1);
ddv(id1) = 0;
nd = sum(ddv);
%
idp = find(nd>3);       % Points with n >25% of N
%
cthkwi = (cthk_i.*ddv)./ddv;
cthkwu = (cthk_u.*ddv)./ddv;
%
if ~ismac
  xnam = 'fcthkbm26.xlsx';
  for m = 1:6           % Six regions
     idr = find(idreg==m);
     id = intersect(idr,idp);
     xlswrite(xnam,id',m,'B1');
     xlswrite(xnam,cthkwi(:,id),m,'B2');
     xlswrite(xnam,cthkwu(:,id),m,'B17');
  end
end
%
cnam = 'fcthkbm26_';
for m = 1:6             % Six regions
   idr = find(idreg==m);
   id = intersect(idr,idp);
   [h,tt] = ttest(cthkwi(:,id),cthkwu(:,id));
   csvwrite([cnam int2str(m) '.csv'],[id' tt']);
end
%
return