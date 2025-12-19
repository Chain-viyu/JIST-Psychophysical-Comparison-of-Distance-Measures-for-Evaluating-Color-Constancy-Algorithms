function metrics_inter = CalculateInterVariability(allRating)
    % 计算个体间变异性指标
    % allRating: 每个被试的平均评分 (行数 x [序号, 被试1均值, 被试2均值, ...])
    % 输出:
    %   metrics_inter: 结构体，包含各类别的详细指标
    %   metrics_inter.STRESS_inter_max: Inter-STRESS 最大值
    %   metrics_inter.STRESS_inter_min: Inter-STRESS 最小值
    %   metrics_inter.summary_matrix_placeholder: 提示外部构建的结构
    
    % 初始化输出
    metrics_inter = struct();
    
    % fprintf('\n=== Inter指标 ===\n');
    
    % 提取数据 (移除序号列)
    data_inter = allRating(:, 2:end);
    
    % --- 检查数据有效性 ---
    if size(data_inter, 1) < 2 || size(data_inter, 2) < 2
        warning('数据行数或列数不足，无法计算 ICC, Cronbach Alpha 和 STRESSinter。');
        metrics_inter.ICC_inter = NaN;
        metrics_inter.CronbachAlpha = NaN;
        metrics_inter.STRESS_inter_mean = NaN;
        metrics_inter.STRESS_inter_max = NaN;
        metrics_inter.STRESS_inter_min = NaN;
        return;
    end
    
    % 移除包含 NaN 的行（如果有的话）
    valid_rows = all(~isnan(data_inter), 2);
    data_valid = data_inter(valid_rows, :);
    
    if isempty(data_valid)
        warning('有效数据为空，无法计算 Inter Variability 指标。');
        metrics_inter.ICC_inter = NaN;
        metrics_inter.CronbachAlpha = NaN;
        metrics_inter.STRESS_inter_mean = NaN;
        metrics_inter.STRESS_inter_max = NaN;
        metrics_inter.STRESS_inter_min = NaN;
        return;
    end
    
    % 计算个体间信度
    % 假设 ICC(data, 'A-1') 针对 [item x rater] 计算
    metrics_inter.ICC_inter = ICC(data_valid, 'A-1');
    
    % 计算Cronbach's Alpha
    metrics_inter.CronbachAlpha = cronbach(data_valid);
    
    % 计算Inter-STRESS
    % STRESSinter 假设接受 [rater x item] 形式，且评分范围为 1~10 (原评分+5)
    stress_individual = STRESSinter(data_valid' + 5); 
    
    % 计算 STRESS 的均值、最大值和最小值
    metrics_inter.STRESS_inter_individual = stress_individual;
    metrics_inter.STRESS_inter_mean = mean(stress_individual);
    metrics_inter.STRESS_inter_max = max(stress_individual);
    metrics_inter.STRESS_inter_min = min(stress_individual);
    
    % --- 为外部脚本构建 summary_matrix 提供结构信息 ---
    metrics_inter.summary_matrix = [metrics_inter.ICC_inter, ...
        metrics_inter.CronbachAlpha, ...
        metrics_inter.STRESS_inter_mean, ...
        metrics_inter.STRESS_inter_max, ...
        metrics_inter.STRESS_inter_min];
    
    % 输出结果
    fprintf('  个体间ICC: %.4f\n', metrics_inter.ICC_inter);
    fprintf('  Cronbach Alpha: %.4f\n', metrics_inter.CronbachAlpha);
    fprintf('  个体间STRESS均值: %.4f (Max: %.4f, Min: %.4f)\n', ...
        metrics_inter.STRESS_inter_mean, ...
        metrics_inter.STRESS_inter_max, ...
        metrics_inter.STRESS_inter_min);
end