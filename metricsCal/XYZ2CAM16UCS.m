function JABMh = XYZ2CAM16UCS(XYZ,XYZw,La,Yb,surround)
%%% CAM16-UCS developed by MUHAMMAD SAFDAR on 2017.03.14, Email: msafdar87@hotmail.com %%%

% XYZ范围为0-100
scale=XYZw(2)./100;
XYZw=XYZw./scale;
XYZ=XYZ./scale;  %% scale

[J,Q,C,M,s,h,H]= CAM16_frwd(XYZ,XYZw,La,Yb,surround);
JMh = [J' M' h'];
JABMh = JMh2Jab(JMh);

end

function [J,Q,C,M,S,h,H]= CAM16_frwd(XYZ,XYZw,La,Yb,Surround)
%%% XYZ is test XYZ [nx3]
%%% XYZw is test white  [1x3]
%%% La is adaptive luminance; La should be calculated as (Lw*Yb)/Yw, 
%%%   where Lw is the luminance of reference white in cd/m2 unit, Yb is 
%%%   the luminance factor of the background and  Yw is the luminance factor of the reference white. 
%%% Yb is background luminance factor (typically 20%; Yb=20)
%%% Surround conditions give c (impact of surround), Nc (chromatic induction factor), and F (factor of degree of adaptation), 
%%% Default viewing condition corresponds to ISO 3664 P1 set-up


if nargin>2
else La=2000/(5*pi);
end % luminance of adapted white point
if nargin>3
else Yb=20;end % luminance of background (typically 20)
if nargin>4
   if strcmp(Surround,'avg'); c=0.69;  Nc=1;    F=1;   end % average surround
   if strcmp(Surround,'dim'); c=0.59;  Nc=0.9;  F=0.9; end % dim surround
   if strcmp(Surround,'dark');c=0.525; Nc=0.8;  F=0.8; end % dark surround
   if strcmp(Surround,'T1');  c=0.46;  Nc=0.9;  F=0.9; end % ISO 3664 T1 surround
else                          c=0.69;  Nc=1;    F=1; % ISO 3664 P1, average surround
end

% step 0
M_CAT16 =     [0.401288 0.650173 -0.051461; -0.250268 1.204414 0.045854; -0.002079 0.048952 0.953127];
RGBw = M_CAT16*XYZw';

D_pre =  F * (1- (1/3.6)*exp((-La-42)/92)); % D is degree of adaptation; If D is greater than one or less than zero,set it to one or zero accordingly.
if D_pre<0
    D = 0;
elseif D_pre>1
    D = 1;
else
    D = D_pre;
end

Dr = D*(XYZw(2)/RGBw(1)) + 1 - D;
Dg = D*(XYZw(2)/RGBw(2)) + 1 - D;
Db = D*(XYZw(2)/RGBw(3)) + 1 - D;

k = 1/(5*La+1);
Fl = 0.2*(k^4)*(5*La) + 0.1*((1-k^4)^2)*((5*La)^(1/3));
n = Yb/XYZw(2);
z = 1.48+sqrt(n);
Nbb = 0.725*(1/n)^0.2;
Ncb = Nbb;

RGBwc(1) = Dr*RGBw(1);
RGBwc(2) = Dg*RGBw(2);
RGBwc(3) = Db*RGBw(3);

RGBaw(1) = (400*(Fl*RGBwc(1)/100)^0.42)/(27.13+(Fl*RGBwc(1)/100)^0.42)+0.1;
RGBaw(2) = (400*(Fl*RGBwc(2)/100)^0.42)/(27.13+(Fl*RGBwc(2)/100)^0.42)+0.1;
RGBaw(3) = (400*(Fl*RGBwc(3)/100)^0.42)/(27.13+(Fl*RGBwc(3)/100)^0.42)+0.1;

Aw = (2*RGBaw(1) + RGBaw(2) + RGBaw(3)/20 - 0.305)*Nbb;

% step 1; Calculate cone responses
RGB = M_CAT16*XYZ';

% step 2; Complete the color adaptation
RGBc(1,:) = Dr*RGB(1,:);
RGBc(2,:) = Dg*RGB(2,:);
RGBc(3,:) = Db*RGB(3,:);

% step 3; Calculate post-adaptation cone responses

for i=1:size(XYZ,1)
if RGBc(1,i)>= 0 
    RGBa(1,i) = ( 400*( Fl*RGBc(1,i)/100).^0.42)./(27.13+( Fl*RGBc(1,i)/100).^0.42)+0.1;
else
    RGBa(1,i) = (-400*(-Fl*RGBc(1,i)/100).^0.42)./(27.13+(-Fl*RGBc(1,i)/100).^0.42)+0.1;
end
if RGBc(2,i)>= 0 
    RGBa(2,i) = ( 400*( Fl*RGBc(2,i)/100).^0.42)./(27.13+( Fl*RGBc(2,i)/100).^0.42)+0.1;
else
    RGBa(2,i) = (-400*(-Fl*RGBc(2,i)/100).^0.42)./(27.13+(-Fl*RGBc(2,i)/100).^0.42)+0.1;
end
if RGBc(3,i)>= 0 
    RGBa(3,i) = ( 400*( Fl*RGBc(3,i)/100).^0.42)./(27.13+( Fl*RGBc(3,i)/100).^0.42)+0.1;

else
    RGBa(3,i) = (-400*(-Fl*RGBc(3,i)/100).^0.42)./(27.13+(-Fl*RGBc(3,i)/100).^0.42)+0.1;
end
end
% step 4; Calculate hue angle (h)
a = RGBa(1,:) - 12*RGBa(2,:)/11 + RGBa(3,:)/11;
b = (RGBa(1,:) + RGBa(2,:) - 2*RGBa(3,:))/9;

for j = 1:size(XYZ,1)
h(j) = car2pol([a(j), b(j)]); % croma and hue
h(j) = (h(j)<0).*(h(j)+360) +(1-(h(j)<0)).*h(j); % To make sure hbetween 0 and 360 degree

% step 5; Calculate hue composition (H) and eccentricity
ehH = [ 20.14   90.00   164.25   237.53  380.14;
        0.8     0.7     1.0      1.2     0.8;
        0.0    100.0    200.0    300.0   400.0 ];
hh = h(j);
hh = (1-(hh<20.14)).*hh + (hh<20.14).*(360+hh);
ii =(hh>=20.14)+(hh>=90)+(hh>=164.25)+(hh>=237.53)+(hh>=380.14);

H(j)  = ehH(3,ii)+100.0*( (hh-ehH(1,ii))/ehH(2,ii) )/ ( (hh-ehH(1,ii))/ehH(2,ii) + (ehH(1,ii+1)-hh)/ehH(2,ii+1) );
et = (cos(2+h(j)*pi/180)+3.8)/4;

% step 6; Calculate chromatic response (A)
A(j) = (2*RGBa(1,j) + RGBa(2,j) + RGBa(3,j)/20 - 0.305)*Nbb;

% step 7; Calculate lightness (J)
J(j)= 100*(A(j)/Aw)^(c*z);

% step 8; Calculate brightness (Q)
Q(j) = (4/c)*((J(j)/100).^0.5)*(Aw + 4)*(Fl^0.25);

% step 9; Calculate  chroma (C)
t(j) = ((Nc*Ncb*50000/13)*(et.*(a(j).^2+b(j).^2).^0.5)) / (RGBa(1,j)+ RGBa(2,j)+21*RGBa(3,j)/20);
C(j) = (t(j).^0.9).*((J(j)/100).^0.5)*(1.64-0.29^n)^0.73;

% step 13; calculate colorfulness (M)
M(j) = C(j)*Fl^0.25;

% step 14; Calculate saturation (s)
S(j) = 100*(M(j)./Q(j)).^0.5;
end

end 

function JABMh = JMh2Jab(JMh)
J = JMh(:,1);
M = JMh(:,2);
h = JMh(:,3);
%%% JMh is a [Nx3] vector
%%% JAB is a [Nx3] vector

c1 = 0.007; c2 = 0.0228; % Uniform Colour Spaces Based on CIECAM02 Colour Appearance Model by Luo et al.2002

Jp = []; ap = []; bp = []; Mp = [];
for i=1:length(J)
Jp(i) = ((1+100*c1)*J(i))/(1+c1*J(i));
Mp(i) = (1/c2)*log(1+c2*M(i));
ap(i) = Mp(i) * cos(h(i)*pi/180);
bp(i) = Mp(i) * sin(h(i)*pi/180);
end
Jp = Jp'; ap = ap'; bp = bp'; Mp = Mp';
JAB = [Jp, ap, bp];
JABMh = [Jp, ap, bp, Mp, h];
end

function [h] = car2pol(ab)
% function [h] = cartopol(ab)
% converts a, b  to hue angle h
% ab must be a row or column matrix 2 by 1 or 1 by 2

dim = size(ab);
if (dim(1) == 1)||(dim(2) == 1)
ab = ab(:)'; % force to be a row matrix
else
disp('ab must be a row matrix');
return;
end
if (dim(2)~=2)
disp('ab must be 2 by 1 or 1 by 2');
return;
end

% compute the angular term
if (ab(1) == 0) && (ab(2)>0)
h = 90;
elseif (ab(1) == 0) && (ab(2)<0)
h = 270;
elseif (ab(1)<0) && (ab(2) == 0)
h = 180;
elseif (ab(1)>0) && (ab(2) == 0)
h=0;
elseif (ab(1) == 0) && (ab(2) == 0)
h=0;
else
h = atan(abs(ab(2))/abs(ab(1)));
h = 180*h/pi; % convert from radians to degrees
if ((ab(1)>0) && (ab(2)>0))
h = h + 0; % first quadrant
elseif ((ab(1)<0) && (ab(2)>0))
h = 180 - h; % second quadrant
elseif ((ab(1)<0) && (ab(2)<0))
h = 180 + h; % third quadrant
else
h = 360 - h; % fourth quadrant
end
end

end