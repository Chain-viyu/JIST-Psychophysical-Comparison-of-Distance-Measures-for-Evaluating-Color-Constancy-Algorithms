%{
Time: 2025.12.17
Author: wcy (Modified)
Purpose: 计算颜色恒常性论文各个指标运行所需时间
         包含 PED, DE2000, SSIM, PSNR 等指标
         结果保存为表格格式
%}

%% 参数设置
n = 1000;  % 光源数量
img_size = 512;  % 图像尺寸 512×512

%% 随机生成光源数据和测试图像
fprintf('生成测试数据中...\n');
rgb_e = generate_rgb_matrix(n);
rgb_gt = generate_rgb_matrix(n);

% 生成测试图像（512×512×3）用于 SSIM 和 PSNR
img_gt = generate_test_image(img_size);
img_e = generate_test_image(img_size);

%% RGB 颜色空间下的指标计算
fprintf('开始 RGB 空间计算...\n');
count = n;
rgb_time = zeros(count, 5);
other_time = zeros(count, 4);  % PED, DE2000, SSIM, PSNR

for i = 1:count
    % 原有的5个指标
    rgb_e_i = rgb_e(i,:);
    rgb_gt_i = rgb_gt(i,:);
    [~, rgb_time(i,:)] = calcuCCI(rgb_gt_i, rgb_e_i);
    
    % 新增的4个指标 (other分类)
    other_time(i,:) = calculate_other_metrics(rgb_gt_i, rgb_e_i, img_gt, img_e);
end

rgb_time_mean = sum(rgb_time);
other_time_mean = sum(other_time);

%% 其他颜色空间计算指标
fprintf('开始其他颜色空间计算...\n');
xyz_time = zeros(count, 5);
lms_time = zeros(count, 5);
lab_time = zeros(count, 5);
luv_time = zeros(count, 5);
jab_time = zeros(count, 5);

for i = 1:count
    % 获取当前光源数据
    rgb_e_i = rgb_e(i,:)*255;
    rgb_gt_i = rgb_gt(i,:)*255;
    
    % RGB to XYZ
    tic;
    xyz_e = rgb2xyz(rgb_e_i);
    xyz_gt = rgb2xyz(rgb_gt_i);
    time_rgb2xyz = toc;
    
    % XYZ to LMS
    tic;
    lms_e = xyz2lms(xyz_e);
    lms_gt = xyz2lms(xyz_gt);
    time_xyz2lms = toc;
    time_rgb2lms = time_rgb2xyz + time_xyz2lms;
    
    % XYZ to LAB
    tic;
    lab_e = xyz2lab(xyz_e);
    lab_gt = xyz2lab(xyz_gt);
    time_xyz2lab = toc;
    time_rgb2lab = time_rgb2xyz + time_xyz2lab;
    
    % XYZ to Luv
    tic;
    luv_e = xyz2Luv(xyz_e);
    luv_gt = xyz2Luv(xyz_gt);
    time_xyz2luv = toc;
    time_rgb2luv = time_rgb2xyz + time_xyz2luv;
    
    % XYZ to CAM16
    tic;
    W = [95.047, 100, 108.883];
    jabMh_e = XYZ2CAM16UCS(xyz_e, W, 20, 20, 'dark');
    jabMh_gt = XYZ2CAM16UCS(xyz_gt, W, 20, 20, 'dark');
    time_xyz2jab = toc;
    time_rgb2jab = time_rgb2xyz + time_xyz2jab;
    
    jab_e = jabMh_e(1:3);
    jab_gt = jabMh_gt(1:3);
    
    % 计算各颜色空间的指标时间
    [~, xyz_time(i,:)] = calcuCCI(xyz_gt, xyz_e);
    [~, lms_time(i,:)] = calcuCCI(lms_gt, lms_e);
    [~, lab_time(i,:)] = calcuCCI_LAB(lab_gt, lab_e);
    [~, luv_time(i,:)] = calcuCCI_LAB(luv_gt, luv_e);
    [~, jab_time(i,:)] = calcuCCI_LAB(jab_gt, jab_e);
    
    % 加上空间转换时间
    xyz_time(i,:) = xyz_time(i,:) + time_rgb2xyz;
    lms_time(i,:) = lms_time(i,:) + time_rgb2lms;
    lab_time(i,:) = lab_time(i,:) + time_rgb2lab;
    luv_time(i,:) = luv_time(i,:) + time_rgb2luv;
    jab_time(i,:) = jab_time(i,:) + time_rgb2jab;
end

xyz_time_mean = sum(xyz_time);
lms_time_mean = sum(lms_time);
lab_time_mean = sum(lab_time);
luv_time_mean = sum(luv_time);
jab_time_mean = sum(jab_time);

%% 构建结果表格
fprintf('\n构建结果表格...\n');

% 假设 calcuCCI 返回5个指标，这里使用通用名称
% 如果知道具体指标名，请替换 Metric1-5
metric_names = {'Metric1', 'Metric2', 'Metric3', 'Metric4', 'Metric5'};
other_metrics = {'PED', 'DE2000', 'SSIM', 'PSNR'};

% 初始化单元格数组
color_space = {};
metric_name = {};
time_value = [];

% RGB 空间的5个指标
for i = 1:5
    color_space{end+1} = 'RGB';
    metric_name{end+1} = metric_names{i};
    time_value(end+1) = rgb_time_mean(i);
end

% XYZ 空间的5个指标
for i = 1:5
    color_space{end+1} = 'XYZ';
    metric_name{end+1} = metric_names{i};
    time_value(end+1) = xyz_time_mean(i);
end

% LMS 空间的5个指标
for i = 1:5
    color_space{end+1} = 'LMS';
    metric_name{end+1} = metric_names{i};
    time_value(end+1) = lms_time_mean(i);
end

% LAB 空间的5个指标
for i = 1:5
    color_space{end+1} = 'LAB';
    metric_name{end+1} = metric_names{i};
    time_value(end+1) = lab_time_mean(i);
end

% Luv 空间的5个指标
for i = 1:5
    color_space{end+1} = 'Luv';
    metric_name{end+1} = metric_names{i};
    time_value(end+1) = luv_time_mean(i);
end

% CAM16 空间的5个指标
for i = 1:5
    color_space{end+1} = 'CAM16';
    metric_name{end+1} = metric_names{i};
    time_value(end+1) = jab_time_mean(i);
end

% Other 分类的4个指标
for i = 1:4
    color_space{end+1} = 'Other';
    metric_name{end+1} = other_metrics{i};
    time_value(end+1) = other_time_mean(i);
end

% 创建表格
results_table = table(color_space', metric_name', time_value', ...
    'VariableNames', {'ColorSpace', 'MetricName', 'Time_Seconds'});

%% 显示和保存结果
fprintf('\n========== 计算时间统计结果 ==========\n');
fprintf('测试次数: %d\n', count);
fprintf('图像尺寸: %d×%d\n\n', img_size, img_size);
disp(results_table);

% 保存为 CSV 文件
csv_filename = 'CCI_timing_results.csv';
writetable(results_table, csv_filename);
fprintf('\n结果已保存到: %s\n', csv_filename);

% 保存为 MAT 文件
mat_filename = 'CCI_timing_results.mat';
save(mat_filename, 'results_table');
fprintf('结果已保存到: %s\n', mat_filename);

% 可选：保存为 Excel 文件
try
    excel_filename = 'CCI_timing_results.xlsx';
    writetable(results_table, excel_filename);
    fprintf('结果已保存到: %s\n', excel_filename);
catch
    fprintf('注意: Excel 文件保存失败（可能需要 Excel 支持）\n');
end

%% 辅助函数

function rgb_matrix = generate_rgb_matrix(n)
    % 生成 n×3 的 RGB 矩阵，每行和为1，均匀采样三角形区域
    rand_vals = rand(n, 2);
    rand_sorted = sort(rand_vals, 2);
    
    r = rand_sorted(:, 1);
    g = rand_sorted(:, 2) - rand_sorted(:, 1);
    b = 1 - rand_sorted(:, 2);
    
    rgb_matrix = [r, g, b];
end

function img = generate_test_image(size)
    % 生成 size×size×3 的随机测试图像
    img = rand(size, size, 3);
end

function times = calculate_other_metrics(rgb_gt, rgb_e, img_gt, img_e)
    % 计算 PED, DE2000, SSIM, PSNR 四个指标的时间
    % 输入: rgb_gt, rgb_e - 1×3 向量
    %       img_gt, img_e - 512×512×3 图像
    % 输出: times - 1×4 时间向量
    
    times = zeros(1, 4);
    
    % 1. 计算 PED (Perceptual Error Distance)
    tic;
    wr = 0.299; wg = 0.587; wb = 0.114;  % 感知权重
    ped_value = sqrt(wr*(rgb_gt(1)-rgb_e(1))^2 + ...
                     wg*(rgb_gt(2)-rgb_e(2))^2 + ...
                     wb*(rgb_gt(3)-rgb_e(3))^2);
    times(1) = toc;
    
    % 2. 计算 DE2000
    tic;
    lab_gt = rgb2lab(rgb_gt);
    lab_e = rgb2lab(rgb_e);
    if exist('de2000', 'file')
        de2000_value = de2000(lab_gt, lab_e);
    else
        % 如果没有 de2000 函数,使用简化的 Delta E 计算
        fprintf('use DE')
        de2000_value = sqrt(sum((lab_gt - lab_e).^2));
    end
    times(2) = toc;
    
    % 3. 计算 SSIM (使用512×512图像)
    tic;
    ssim_value = ssim(img_gt, img_e);
    times(3) = toc;
    
    % 4. 计算 PSNR (使用512×512图像)
    tic;
    psnr_value = psnr(img_gt, img_e);
    times(4) = toc;
end