function metrics = CalculateObserverVariability(intra_ind, intra_pool, allRating, MeanRating)
    % 计算各类指标
    % intra_ind: 每个被试的重复评分数据 (行数 x [序号, 被试1评分1, 被试1评分2, ...])
    % intra_pool: 所有被试合并的重复评分数据 (总行数 x [序号, 评分1, 评分2])
    % allRating: 每个被试的平均评分 (行数 x [序号, 被试1均值, 被试2均值, ...])
    % MeanRating: 所有被试的总平均评分 (行数 x [序号, 总均值])
    
    % 初始化输出结构
    metrics = struct();
    
    % 计算个体内信度 (intra_ind)
    numSubjects = (size(intra_ind, 2) - 1) / 2;
    icc_individual = zeros(numSubjects, 1);
    for i = 1:numSubjects
        col1 = 2 * i;
        col2 = 2 * i + 1;
        data = [intra_ind(:, col1), intra_ind(:, col2)];
        icc_individual(i) = ICC(data, 'A-1');
    end
    metrics.ICC_individual = icc_individual;
    metrics.ICC_individual_mean = mean(icc_individual);
    
    % 计算合并内信度 (intra_pool)
    data_pool = [intra_pool(:, 2), intra_pool(:, 3)];
    metrics.ICC_pooled = ICC(data_pool, 'A-1');
    
    % 计算个体间信度 (allRating)
    data_inter = allRating(:, 2:end);
    metrics.ICC_inter = ICC(data_inter, 'A-1');
    
    % 计算Cronbach's Alpha
    metrics.CronbachAlpha = cronbach(data_inter);
    
    % 计算Intra-STRESS (使用intra_ind数据)
    intra_data = intra_ind(:, 2:end)+4;  % 去除第一列序号
    metrics.STRESS_intra_individual = STRESSintra(intra_data);
    metrics.STRESS_intra_mean = mean(metrics.STRESS_intra_individual);
    
    % 计算Intra-STRESS (使用intra_pool数据)
    pool_data = intra_pool(:, 2:3)+4;  % 两列评分数据
    metrics.STRESS_intra_pooled = STRESSintra(pool_data);
    
    % 计算Inter-STRESS (使用allRating数据)
    metrics.STRESS_inter_individual = STRESSinter(data_inter'+4);
    metrics.STRESS_inter_mean = mean(metrics.STRESS_inter_individual);
    
    % 输出结果
    fprintf('=== ICC指标 ===\n');
    fprintf('个体内ICC均值: %.4f\n', metrics.ICC_individual_mean);
    fprintf('合并ICC: %.4f\n', metrics.ICC_pooled);
    fprintf('个体间ICC: %.4f\n', metrics.ICC_inter);
    fprintf('Cronbach Alpha: %.4f\n', metrics.CronbachAlpha);
    
    fprintf('\n=== STRESS指标 ===\n');
    fprintf('个体内STRESS均值: %.4f\n', metrics.STRESS_intra_mean);
    fprintf('合并内STRESS: %.4f\n', metrics.STRESS_intra_pooled);
    fprintf('个体间STRESS均值: %.4f\n', metrics.STRESS_inter_mean);
end