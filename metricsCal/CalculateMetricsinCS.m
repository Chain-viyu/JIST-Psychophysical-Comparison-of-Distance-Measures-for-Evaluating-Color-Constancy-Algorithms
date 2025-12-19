function [all_metrics, time_matrix] = CalculateMetricsinCS(GT_RGB, E_RGB, InputType)
% Calculate Metrics in CS 计算颜色恒常性算法的多种误差指标
%   输入:
%       GT_RGB: 实际场景光源 n×3 矩阵
%       E_RGB: 算法估计光源 n×3 矩阵
%   输出:
%       all_metrics: 结构体，包含各颜色空间的指标
%       time_matrix: 6×5矩阵，每行对应一个颜色空间，每列对应一个指标的总时间(转换+计算)

%% 数据重组
A = GT_RGB;
nColBlocks = size(A, 2) / 3;
B = reshape(A, [size(A,1), 3, nColBlocks]);
B = permute(B, [1, 3, 2]);
GT_RGB = reshape(B, [], 3);

A = E_RGB;
nColBlocks = size(A, 2) / 3;
B = reshape(A, [size(A,1), 3, nColBlocks]);
B = permute(B, [1, 3, 2]);
E_RGB = reshape(B, [], 3);

%% 初始化时间矩阵
time_matrix = zeros(6, 5);  % 6个颜色空间 × 5个指标
space_names = {'RGB', 'XYZ', 'LMS', 'LAB', 'Luv', 'JAB'};

%% RGB2XYZ ('1D'or'5D')
n = size(GT_RGB, 1);
GT_XYZ = zeros(n, 3);
E_XYZ = zeros(n, 3);

t_rgb2xyz = tic;
% 检查 InputType 是否为序号列表
if isvector(InputType) && ~ischar(InputType)
    % fprintf('使用 InputType (序号列表) 进行 RGB 到 XYZ 转换。\n');

    for i = 1:n
        % 使用 ismember 检查当前序号 i 是否在 InputType 列表中
        if ismember(i, InputType)
            % 如果 i 在列表中，使用 '1D' 模型
            GT_XYZ(i,:) = rgb2xyz(GT_RGB(i,:), '1D');
            E_XYZ(i,:) = rgb2xyz(E_RGB(i,:), '1D');
        else
            % 如果 i 不在列表中，使用 '5D' 模型
            GT_XYZ(i,:) = rgb2xyz(GT_RGB(i,:), '5D');
            E_XYZ(i,:) = rgb2xyz(E_RGB(i,:), '5D');
        end
    end
    % 保留原始 'original' 逻辑作为备选，或者您可以删除此 else 块
elseif ischar(InputType) && strcmp(InputType, 'original')
    fprintf('使用原始逻辑 (1-48 为 1D，49-n 为 5D) 进行 RGB 到 XYZ 转换。\n');
    for i = 1:n
        if i <= 48
            GT_XYZ(i,:) = rgb2xyz(GT_RGB(i,:), '1D');
            E_XYZ(i,:) = rgb2xyz(E_RGB(i,:), '1D');
        else % i >= 49
            GT_XYZ(i,:) = rgb2xyz(GT_RGB(i,:), '5D');
            E_XYZ(i,:) = rgb2xyz(E_RGB(i,:), '5D');
        end
    end
else
    fprintf('InputType 格式错误或未定义 n。\n');
end

time_rgb2xyz = toc(t_rgb2xyz);

%% 转换所有颜色空间
t_xyz2lms = tic;
GT_LMS = zeros(n, 3);
E_LMS = zeros(n, 3);
for i = 1:n
    GT_LMS(i,:) = xyz2lms(GT_XYZ(i,:));
    E_LMS(i,:) = xyz2lms(E_XYZ(i,:));
end
time_xyz2lms = toc(t_xyz2lms);

t_xyz2lab = tic;
GT_LAB = zeros(n, 3);
E_LAB = zeros(n, 3);
for i = 1:n
    GT_LAB(i,:) = xyz2lab(GT_XYZ(i,:));
    E_LAB(i,:) = xyz2lab(E_XYZ(i,:));
end
time_xyz2lab = toc(t_xyz2lab);

t_xyz2luv = tic;
GT_Luv = zeros(n, 3);
E_Luv = zeros(n, 3);
for i = 1:n
    GT_Luv(i,:) = xyz2Luv(GT_XYZ(i,:));
    E_Luv(i,:) = xyz2Luv(E_XYZ(i,:));
end
time_xyz2luv = toc(t_xyz2luv);

t_xyz2jab = tic;
GT_JAB = XYZ_to_CAM16UCS(GT_XYZ);
E_JAB = XYZ_to_CAM16UCS(E_XYZ);
time_xyz2jab = toc(t_xyz2jab);

%% 计算各颜色空间指标
RGB_white = [0.33, 0.33, 0.33];
LAB_white = [100, 0, 0];

% RGB空间
[all_metrics.RGB, time_matrix(1,:)] = calculate_metrics_with_time(GT_RGB, E_RGB, RGB_white, false, 0);

% XYZ空间
[all_metrics.XYZ, time_matrix(2,:)] = calculate_metrics_with_time(GT_XYZ, E_XYZ, RGB_white, false, time_rgb2xyz);

% LMS空间
[all_metrics.LMS, time_matrix(3,:)] = calculate_metrics_with_time(GT_LMS, E_LMS, RGB_white, false, time_rgb2xyz + time_xyz2lms);

% LAB空间
[all_metrics.LAB, time_matrix(4,:)] = calculate_metrics_with_time(GT_LAB, E_LAB, LAB_white, true, time_rgb2xyz + time_xyz2lab);

% Luv空间
[all_metrics.Luv, time_matrix(5,:)] = calculate_metrics_with_time(GT_Luv, E_Luv, LAB_white, true, time_rgb2xyz + time_xyz2luv);

% JAB空间
[all_metrics.JAB, time_matrix(6,:)] = calculate_metrics_with_time(GT_JAB, E_JAB, LAB_white, true, time_rgb2xyz + time_xyz2jab);

% %% 输出时间矩阵
% fprintf('\n=== 时间矩阵 (颜色空间 × 指标) ===\n');
% fprintf('行: RGB, XYZ, LMS, LAB, Luv, JAB\n');
% fprintf('列: Recovery, Reproduction, Euclidean, CCI_rec, CCI_euc\n\n');
% disp(time_matrix);
end

%% 指标计算子函数（返回每个指标的独立时间）
function [metrics, time_array] = calculate_metrics_with_time(gt, e, white, is_lab_space, conversion_time)
n = size(gt, 1);
metrics = zeros(n, 5);
time_array = zeros(1, 5);

% 指标1: Recovery error
t1 = tic;
for i = 1:n
    metrics(i,1) = acos_deg(gt(i,:), e(i,:));
end
time_array(1) = conversion_time + toc(t1);

% 指标2: Reproduction error
t2 = tic;
for i = 1:n
    if is_lab_space
        ep = [gt(i,1)/e(i,1), (gt(i,2)-e(i,2))/256, (gt(i,3)-e(i,3))/256];
        metrics(i,2) = acos_deg(white, ep);
    else
        metrics(i,2) = acos_deg(white, gt(i,:)./e(i,:));
    end
end
time_array(2) = conversion_time + toc(t2);

% 指标3: Euclidean distance
t3 = tic;
for i = 1:n
    diff = gt(i,:) - e(i,:);
    metrics(i,3) = sqrt(sum(diff.^2));
end
time_array(3) = conversion_time + toc(t3);

% 指标4: CCI recovery
t4 = tic;
for i = 1:n
    gt_white_angle = acos_deg(gt(i,:), white);
    metrics(i,4) = metrics(i,1) / gt_white_angle;
end
time_array(4) = conversion_time + toc(t4);

% 指标5: CCI euclidean
t5 = tic;
for i = 1:n
    gt_white_dist = sqrt(sum((gt(i,:) - white).^2));
    metrics(i,5) = metrics(i,3) / gt_white_dist;
end
time_array(5) = conversion_time + toc(t5);
end