function out=gama(img,gamma_value)
gamma=1/gamma_value;
img=img./max(img(:));
img=65535.0.*img;
img=img.^gamma;
out=img./max(img(:));%伽马校正