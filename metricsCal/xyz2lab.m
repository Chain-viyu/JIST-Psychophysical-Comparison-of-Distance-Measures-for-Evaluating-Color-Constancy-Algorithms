function Lab = xyz2lab(XYZ)
    % D65 白点
    Xn = 95.047;
    Yn = 100.000;
    Zn = 108.883;
    
    % 相对值计算
    Xr = XYZ(1) / Xn;
    Yr = XYZ(2) / Yn;
    Zr = XYZ(3) / Zn;

    % 计算 f 函数
    f_Yr = getF(Yr);
    f_Xr = getF(Xr);
    f_Zr = getF(Zr);

    % Lab 值计算
    L = 116 * f_Yr - 16;
    a = 500 * (f_Xr - f_Yr);
    b = 200 * (f_Yr - f_Zr);

    Lab = [L, a, b];
end

function f = getF(t)
    if t > 0.008856
        f = t^(1/3);
    else
        f = 7.787 * t + 16/116;
    end
end