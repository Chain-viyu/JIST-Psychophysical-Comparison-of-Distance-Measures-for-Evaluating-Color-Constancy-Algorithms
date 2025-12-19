function Luv = xyz2Luv(XYZ)
    % D65 白点
    Xn = 95.047;
    Yn = 100.000;
    Zn = 108.883;

    % 计算相对组件
    X = XYZ(1);
    Y = XYZ(2);
    Z = XYZ(3);
    
    % 计算 u', v' 的参考白点
    Un = (4 * Xn) / (Xn + 15 * Yn + 3 * Zn);
    Vn = (9 * Yn) / (Xn + 15 * Yn + 3 * Zn);

    % 计算 L*, u*, v*
    L = 116 * f(Y / Yn) - 16;
    U = (4 * X) / (X + 15 * Y + 3 * Z);
    V = (9 * Y) / (X + 15 * Y + 3 * Z);
    
    u_prime = 13 * L * (U - Un);
    v_prime = 13 * L * (V - Vn);
    
    Luv = [L, u_prime, v_prime];
end

function f_val = f(t)
    if t > 0.008856
        f_val = t^(1/3);
    else
        f_val = 7.787 * t + 16/116;
    end
end
