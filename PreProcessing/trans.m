function out=trans(img,flag)
if(strcmp(flag,'1D'))
    XYZ2Cam = [6806 -179 -1020;-8097 16415 1687;-3267 4236 7690 ]/10000;
elseif(strcmp(flag,'5D'))
    XYZ2Cam= [6347 -479 -972;-8297 15954 2480;-1968 2131 7649 ]/10000; 
else
    error(' No data.' );
end
sRGB2XYZ = [0.4124564 0.3575761 0.1804375;0.2126729 0.7151522 0.0721750;0.0193339 0.1191920 0.9503041];
sRGB2Cam = XYZ2Cam * sRGB2XYZ;
sRGB2Cam = sRGB2Cam./ repmat( sum( sRGB2Cam,2),1,3); % normalize each rows of sRGB2Cam to 1 sRGB2Cam矩阵的每行都归一化
Cam2sRGB = (sRGB2Cam)^-1;
out=apply_cmatrix(img, Cam2sRGB);%将把得到的RGBtoSRGB的矩阵关系应用到原图像中
out=max(0,min(out,1)); 