function h = ax_arrows(vlen,r,alen)
%AX_ARROWS Plots cylinders as axis arrows for three directions.
%
%         H = AX_ARROWS(VLEN,R) returns the handles H to the cylinders
%         given the arrow lengths, VLEN, and arrow radius, R.  If VLEN
%         is a scalar, all the arrows have the same length.  H is a
%         three by two matrix of handles with the first column is the
%         stem of the three arrows and the second column is the head of
%         the arrow.
%
%         AX_ARROWS(VLEN,R,ALEN) the length of the arrow heads in ALEN.
%
%         27-Apr-2020 * Mack Gardner-Morse
%

%#######################################################################
%
% Check for Inputs
%
if (nargin<2)
  error(' *** ERROR:  AX_ARROWS requires two input arguments.');
end
%
if size(vlen(:),1)<3
  vlen = repmat(vlen(1),3,1);
end
%
if (nargin<3)
  alen = 7*r;
end
%
% Translation of Arrow Head
%
th = vlen(:)-alen(:);
%
% Create Arrow Stem and Head Cylinders
%
[x3,y3,z3] = cylinder(repmat(r,4,1),36);         % Stem
[xh3,yh3,zh3] = cylinder(2*r:-2*r/4:0,36);       % Head
xh3 = [zeros(1,37); xh3];
yh3 = [zeros(1,37); yh3];
zh3 = [zh3(1,:); zh3];
zh3 = zh3*alen;
%
x1 = (vlen(1)-0.99*alen)*z3;
y1 = x3;
z1 = y3;
%
xh1 = zh3+th(1);
yh1 = xh3;
zh1 = yh3;
%
x2 = x3;
y2 = (vlen(2)-0.99*alen)*z3;
z2 = y3;
%
xh2 = xh3;
yh2 = zh3+th(2);
zh2 = yh3;
%
z3 = (vlen(3)-0.99*alen)*z3;
zh3 = zh3+th(3);
%
% Plot Arrows
%
h(3,2) = surfl(xh3,yh3,zh3);
hold on;
h(3,1) = surfl(x3,y3,z3);
%
h(2,2) = surfl(xh2,yh2,zh2);
h(2,1) = surfl(x2,y2,z2);
%
h(1,2) = surfl(xh1,yh1,zh1);
h(1,1) = surfl(x1,y1,z1);
%
set(h,'EdgeColor','none','FaceColor','r');
%
return