function [L, C, H] = lab2lch(Lab)
    % 输入:
    % Lab - N x 3 的矩阵, 每一行表示一个 (L, a, b) 颜色
    % 输出:
    % L - luminance (亮度)
    % C - chroma (色度)
    % H - hue (色相)

    % 提取各个分量
    L = Lab(:, 1);  % L 分量
    a = Lab(:, 2);  % a 分量
    b = Lab(:, 3);  % b 分量

    % 计算 Chroma
    C = sqrt(a.^2 + b.^2);

    % 计算 Hue
    H = atan2(b, a); % 返回弧度
    H = rad2deg(H);  % 转转换为度
    H(H < 0) = H(H < 0) + 360; % 将角度调整到 [0, 360)

    % 组合输出
    L = L;   % Luminance
    C = C;   % Chroma
    H = H;   % Hue
end