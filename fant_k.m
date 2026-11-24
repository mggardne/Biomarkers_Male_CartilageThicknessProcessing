function [idk,idp,idn,idmn,kcut,rc,rc2,fdat] = fant_k(dat,klim,iplt);
%FANT_K   Finds the anterior regions in a MRI slice data cell array of
%         a femoral condyle.
%
%         IDK = FANT_K(DAT) given the MRI slice data cell array of a
%         femoral condyle, DAT, finds the anterior regions on the
%         slices using the curvature of the slice data in polar
%         coordinates and returns a cell array of indices to the
%         anterior regions for each slice, IDK.
%
%         IDK = FANT_K(DAT,KLIM) the cut-off curvature value is
%         specified by KLIM.  The default value is 0.1 (radius of
%         curvature = 10). 
%
%         [IDK,IDP,IDN,IDMN] = FANT_K(DAT) returns an index into IDK to
%         the positive curvature values in IDP, an index to the negative
%         curvatures in IDN and an index to the minimum curvature in
%         IDMN.
%
%         [IDK,IDP,IDN,IDMN,KCUT,RC,RC2,FDAT] = FANT_K(DAT,KLIM,IPLT) if
%         input scalar, IPLT, is true (or not equal to zero), generates
%         four subplots of each slice and save the plots to the
%         Postscript file, fant_k.ps.  Returns the curvature limits used
%         for each slice in a column vector, KCUT, the best fit circle
%         to all the slice data in a column vector, RC, the best fit
%         circle to the anterior region of the slice data in a column
%         vector, RC2, and polynomial fit data in a matrix, FDAT, where
%         the first column contains the order of the polynomial fit to
%         the polar coordinates, the second column contains the R^2
%         value of the fit, the third column contains the maximum
%         absolute fit error, the fourth column contains the mean fit
%         error and the fifth column contains the standard deviation of
%         the fit errors.
%
%         NOTES:  1.  The M-files circ_fit.m, circ_ft3.m, fitp.m,
%                 plane_fit.m and sl_info.m must be in the current path
%                 or directory.
%
%     06-Aug-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Check Inputs
%
if nargin<1
  error([' *** ERROR in FANT_K:  An input MRI femoral condyle ', ...
         ' data cell array is required!']);
end
%
if nargin<2||isempty(klim)
  klim = 0.1;           % Curvature limit
end
%
if nargin<3||isempty(iplt)
  iplt = false;
end
%
% Angles from 0 to 360 degrees in 2.5 degree Increments
%
th = (0:pi/72:2*pi)';
%
% Open Figure
%
if iplt
  hf1 = figure;
end
%
% Get Slices in Rows
%
dat = dat(:);           % Ensure slices are in rows
%
% Get Slice Information
%
nslice = sl_info(dat);
%
% Initialize Variables
%
h = zeros(4,1);         % Axis handles for the four subplots
idk = cell(nslice,1);
idp = cell(nslice,1);
idn = cell(nslice,1);
idmn = zeros(nslice,1);
fdat = zeros(nslice,5);
kcut = zeros(nslice,1);
rc = zeros(nslice,1);
rc2 = zeros(nslice,1);
%
% Loop through Slices
%
for k = 1:nslice
%
   xyz = dat{k};
   npt = size(xyz,1);
   [mval,idmn] = min(xyz(:,2));        % Minimum Y coordinate
   if idmn<npt/2
     ibeg = true;
   else
     ibeg = false;
   end
%
% Plot Data
%
   if iplt
     figure(hf1);
     orient landscape;
     clf;
     h(1) = subplot(2,2,1);
     hold on;
%       view(-45,35);
     view(-75,35);
%
     plot3(xyz(:,1),xyz(:,2),xyz(:,3),'b.-','LineWidth',0.5);
%
     axis equal;
     xlabel('X','FontSize',12,'FontWeight','bold');
     ylabel('Y','FontSize',12,'FontWeight','bold');
     zlabel('Z','FontSize',12,'FontWeight','bold');
   end
%
% Get Slice Data into 2-D Slice Plane
%
   [xyzc2,nv2,c2,r2] = plane_fit(xyz(:,1),xyz(:,2),xyz(:,3));
   xyzt = (xyz-repmat(xyzc2,size(xyz,1),1))*r2;
%
% Circle Fit of Entire Slice
%
   [rc(k),xc,yc] = circ_fit(xyzt(:,1),xyzt(:,2));
%
   if iplt
     h(2) = subplot(2,2,2);
     orient landscape;
     plot(xyzt(:,1),xyzt(:,2),'b.-','LineWidth',0.5);
     hold on;
     x = rc(k)*cos(th)+xc;
     y = rc(k)*sin(th)+yc;
     plot(x,y,'k-','LineWidth',0.5);
     axis equal;
     xlabel('X','FontSize',12,'FontWeight','bold');
     ylabel('Y','FontSize',12,'FontWeight','bold');
   end
%
% Convert to Polar Coordinates
%
   [th2,r] = cart2pol(xyzt(:,1),xyzt(:,2));
   na = size(th2,1);
%
% Make Angles (th2) Continuous
%
   dth2 = diff(th2);
   idb = find(abs(dth2)>pi);           % Find jump in angle
   if xor(idb<na/2,dth2(idb)<0)
     ida = find(th2<-pi/2);
     th2(ida) = th2(ida)+2*pi;         % Add 2*pi (360 degrees)
     rng = [-1 4];
   else
     ida = find(th2>pi/2);
     th2(ida) = th2(ida)-2*pi;         % Subtract 2*pi (360 degrees)
     rng = [-4 1];
   end
%
% Polynomial Fit of Polar Coordinates
% See Fit_errors.txt for measures of fit with different maximum
% polynomial orders (10-15).
%
   if na<12
     fit_ord = na-1;
   else
     fit_ord = 11;      % Max. order (11) picked so mxerr<1 (all, but 3) and sderr < 0.3 (all, but 1)
   end
   [b2,p2,df,R2,F,r2v,fv] = fitp(th2,r,fit_ord);
   rhat = polyval(b2,th2);
   err = rhat-r;
   mxerr = max(abs(err));
   sderr = std(err);
   fdat(k,:) = [fit_ord R2 mxerr mean(err) sderr];
%
% Plot Polar Coordinates and Fit
%
   if iplt
     h(3) = subplot(2,2,3);
     plot(th2,r,'b.-','LineWidth',0.5,'MarkerSize',6);
     hold on;
     plot(th2,rhat,'k-','LineWidth',0.5);
     xlabel('\Theta','FontSize',12,'FontWeight','bold');
     ylabel('R','FontSize',12,'FontWeight','bold');
     ttx = {[int2str(p2) ' Order Fit'];['Max Err = ' num2str(mxerr) ...
           ', R^2 = ' num2str(R2) ', SD Err = ' num2str(sderr)]};
     title(ttx,'FontSize',12,'FontWeight','bold');
   end
%
% Get Derivatives and Curvature
%
   b2d = polyder(b2);
   b2d2 = polyder(b2d);
%
   k2 = polyval(b2d2,th2)./(1+polyval(b2d,th2).^2).^1.5;
%
% Find Points within Limits
%
   nlim = 0;
   kcut(k) = klim;
   while nlim<4
        [aval,loc] = max(abs(rng));
        aval = rng(loc);
        aval = aval-sign(aval);        % +3 or -3 (~pi)
        idl = find(abs(k2)<kcut(k));
        nl = size(idl,1);
        idx = [0; find(abs(diff(idl))>1); nl];
        nx = size(idx,1);
        [mval,idmn] = min(abs(th2(idl)-aval));
        if idl(idmn)<npt/2&~ibeg|idl(idmn)>npt/2&ibeg % Check +/-3 is in anterior
          [mval,idmn] = min(abs(th2(idl))); % Use zero instead of +/-3 for anterior
        end
        [sid,ids] = sort([idx; idmn]);
        ie = find(ids==nx+1);
        ib = idx(ie-1)+1;
        ie = idx(ie);
        idk{k} = idl(ib:ie);
        idp{k} = find(k2(idk{k})>0);
        idn{k} = find(k2(idk{k})<0);
        [minval,idmn(k)] = min(k2(idk{k}));
        nlim = size(ib:ie,2);
        if nlim<4
          warning([' *** WARNING in FANT_K:  Increasing', ...
                   ' curvature cutoff!']);
          kcut(k) = kcut(k)+klim;
        end
   end
%
% Plot Curvature
%
   if iplt
     h(4) = subplot(2,2,4);
     plot(rng,[0 0],'k:','LineWidth',0.5);
     hold on;
     plot(rng,[klim klim],'r:','LineWidth',0.5);
     plot(rng,-[klim klim],'r:','LineWidth',0.5);
     plot(th2,k2,'b-','LineWidth',0.5);
     plot(th2(idk{k}),k2(idk{k}),'ro','LineWidth',0.5);
     axis([rng -0.5 0.5]);
     xlabel('\Theta','FontSize',12,'FontWeight','bold');
     ylabel('K','FontSize',12,'FontWeight','bold');
%
% Plot Identified Points on Other Subplots
%
     axes(h(1));
     h1 = plot3(xyz(idk{k},1),xyz(idk{k},2),xyz(idk{k},3),'go', ...
                'LineWidth',0.5);
%
     axes(h(2));
     h2 = plot(xyzt(idk{k},1),xyzt(idk{k},2),'ro','LineWidth',0.5);
   end
%
% Circle Fit and Plot using Identified Points
%
   [rc2(k),xc2,yc2] = circ_fit(xyzt(idk{k},1),xyzt(idk{k},2));
%
   x2 = rc2(k)*cos(th)+xc2;
   y2 = rc2(k)*sin(th)+yc2;
%
   if iplt
     plot(x2,y2,'r-','LineWidth',0.5);
     plot(xc2,yc2,'r+','LineWidth',0.5);
%
% Slice Number and Print Plots
%
     ht = suptitle(['Slice ' int2str(k)]);
     set(ht,'FontSize',24,'FontWeight','bold','Interpreter','none');
     if k==1
       print -dpsc2 fant_k.ps;
     else
       print -dpsc2 -append fant_k.ps;
     end
   end
end
%
return