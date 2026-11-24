function [hp,ho,caxlim,axlim] = plt_cprt(xq,yq,zq,quad,xyo,ttxt, ...
                                         clim,atxt);
%PLT_CPRT Plots 3-D patch data and 2-D outline data with a title.  For
%         use with compartment cartilage thickness data.  See
%         cthkbrkd.m.
%
%         PLT_CPRT(XQ,YQ,ZQ,QUAD,XYO,TTXT) given the X, Y and Z
%         coordinates XQ, YQ and ZQ, four column quadrilateral
%         connectivity matrix QUAD, ordered X and Y coordinates of the
%         outline in a two column matrix XYO and a text string for a
%         title TTXT, plots the patches using the Z coordinate for color
%         coding the patches and the outline.
%
%         PLT_CPRT(XQ,YQ,ZQ,QUAD,XYO,TTXT,CLIM) given the range for
%         the color in a two element vector CLIM ([cmin cmax]), sets the
%         color axis limits.  See Matlab CAXIS command.
%
%         PLT_CPRT(XQ,YQ,ZQ,QUAD,XYO,TTXT,CLIM,ATXT) given the text
%         string ATXT, adds an X axis label with the input text.
%
%         [HP,HO] = PLT_CPRT(XQ,...) returns the graphic handles to the
%         patches HP and outline HO.
%
%         [HP,HO,CAXLIM,AXLIM] = PLT_CPRT(XQ,...) returns the limits of
%         the color axis CAXLIM and the limits of the axes AXLIM.
%
%         NOTES:  1.  See cthkbrkd.m.
%
%                 2.  Uses the 2-D view from VIEW(-90,90).
%
%         11-Jun-2013 * Mack Gardner-Morse
%

%#######################################################################
%
% Check for Inputs
%
if (nargin<6)
  error([' *** ERROR in PLT_CPRT:  PLT_CPRT requires six (6)', ...
         ' inputs!']);
end
%
% Plot Surface
%
hp = patch(xq(quad'),yq(quad'),zq(quad'),zq(quad'), ...
           'FaceColor','interp','EdgeColor','interp');
%
% Get View, Remove Tick Marks and Add Box
%
view(-90,90);
axis tight;
axis equal;
set(gca,'xtick',[]);
set(gca,'ytick',[]);
set(gca,'ztick',[]);
hold on;
box on;
%
% Plot Outline
%
ho = plot(xyo(:,1),xyo(:,2),'k-','LineWidth',3);
%
% Color Axis, Labels and Title
%
caxlim = caxis;
if nargin>6&&~isempty(clim)
  caxis(clim);
end
%
if nargin>7&&~isempty(atxt)
  xlabel(atxt,'FontSize',24,'FontWeight','bold');
end
%
title(ttxt,'FontSize',16,'FontWeight','bold');
%
axis tight;
axis equal;
axlim = axis;
%
return