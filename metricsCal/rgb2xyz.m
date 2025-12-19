function xyz_e = rgb2xyz(rgb_e, camera)
%RGB2XYZ 将相机rawRGB转换为XYZ (2度视场)
%   输入:
%       rgb_e: n×3 RGB矩阵，范围[0,1]
%       camera: '5D'或'1D'，指定相机型号（默认'5D'）
%   输出:
%       xyz_e: n×3 XYZ矩阵

    % 参数检查和默认值
    if nargin < 2
        camera = '5D';
    end
    
    % 选择转换矩阵
    switch camera
        case '5D'
            XYZ2Cam = [6347 -479 -972; -8297 15954 2480; -1968 2131 7649] / 10000;
        case '1D'
            XYZ2Cam = [0.6806 -0.0179 -0.1020; -0.8097 1.6415 0.1687; -0.3267 0.4236 0.7690];
        otherwise
            error('相机型号必须为''5D''或''1D''');
    end
    
    % 转换
    n = size(rgb_e, 1);
    xyz_e = zeros(n, 3);
    
    for i = 1:n
        rgb = 255 * rgb_e(i, :)';
        xyz = XYZ2Cam \ rgb;
        xyz = xyz / xyz(2) * 100;  % 归一化Y=100
        xyz_e(i, :) = xyz';
    end
end