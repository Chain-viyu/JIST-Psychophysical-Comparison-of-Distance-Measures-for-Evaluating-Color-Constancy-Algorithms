illu_RGB = REC_groundtruth;
A = illu_RGB;
nColBlocks = size(A, 2) / 3; 
B = reshape(A, [size(A,1), 3, nColBlocks]); 
B = permute(B, [1, 3, 2]);  
illu_RGB = reshape(B, [], 3); 
% A = illu_XYZ;
% nColBlocks = size(A, 2) / 3; 
% B = reshape(A, [size(A,1), 3, nColBlocks]); 
% B = permute(B, [1, 3, 2]);  
% illu_XYZ = reshape(B, [], 3); 
%% RGB2XYZ
% XYZ2Cam= [6347 -479 -972;-8297 15954 2480;-1968 2131 7649 ]/10000;
% RGB2XYZ = inv(XYZ2Cam); % 转换矩阵：根据不同RGB空间确定
n = size(illu_RGB,1); 
tic;
for i = 1:n
    rgb = illu_RGB(i,:)';
    xyz = rgb2xyz(rgb);
    illu_XYZ(i,:) = xyz';
end
time_RGB2XYZ = toc;
%% XYZ2LMS   D65
% XYZ2LMS = [0.4002 0.7075 -0.0807;-0.2280 1.1500 0.0612;0 0 0.9184];
n = size(illu_XYZ,1);
tic;
for i = 1:n
    xyz = illu_XYZ(i,:)';
    lms = xyz2lms(xyz);
    illu_LMS(i,:) = lms';
end
time_XYZ2LMS = toc;
%% XYZ2Lab   D65
tic;
for i = 1:n
    xyz = illu_XYZ(i,:)';
    lab = xyz2lab(xyz);
    illu_LAB(i,:) = lab';
end
time_XYZ2LAB = toc;
%% XYZ2Luv   D65
tic;
for i = 1:n
    xyz = illu_XYZ(i,:);
    luv = xyz2Luv(xyz);
    illu_Luv(i,:) = luv;
end
time_XYZ2LUV = toc;
%% Lab2Lch
% n = size(illu_LAB,1);
% illu_LCH = illu_LAB;
% for i = 1:r
%     lab = illu_LAB(i,:);
%     lch = lab2lch(lab);
%     illu_Lch(i,:) = lch;
% end
%% XYZ2JAB   D65
tic;
% for i = 1:n
%     xyz = illu_XYZ(i,:);
%     jab = XYZtoCAM16UCS(xyz);
%     illu_JAB(i,:) = jab;
% end
illu_JAB = XYZ_to_CAM16UCS(illu_XYZ);
time_XYZ2JAB = toc;
