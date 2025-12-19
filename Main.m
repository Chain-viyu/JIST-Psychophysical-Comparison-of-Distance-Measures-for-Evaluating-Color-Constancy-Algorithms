clear
clc
% 添加函数路径
addpath('metricsCal\');
addpath('results');

%% ========== 第一部分：计算各算法的白平衡指标 ==========
fprintf('========================================\n');
fprintf('第一部分：计算白平衡指标\n');
fprintf('========================================\n');

% 1.1 加载 GT 数据
fprintf('  => 加载 All_Illumination_RGB_Final.mat...\n');
load('All_Illumination_RGB_Final.mat');

% Test Another GT
% GT = GroundTruth;

% 1.2 定义参数
category_names = {'scene', 'nature', 'indoor', 'portrait'};
num_categories = length(category_names);

method_names = {'GreyEdge', 'GP', 'GreyWorld', 'maxRGB', 'PCA', 'ShadesOfGrey', 'GI', 'SIIE'};
num_methods = length(method_names);

color_spaces = {'RGB', 'XYZ', 'LMS', 'LAB', 'Luv', 'JAB'};
num_color_spaces = length(color_spaces);

error_metrics = {'Recovery_error', 'Reproduction_error', 'Euclidean_distance', 'CCI_recovery', 'CCI_euclidean'};
num_error_metrics = length(error_metrics);

% 1.3 加载所有方法的数据
fprintf('\n=== 加载所有方法的 REC 数据 ===\n');
method_data = struct();

for m = 1:num_methods
    method = method_names{m};
    if evalin('base', ['exist(''' method ''', ''var'')'])
        method_data.(method) = evalin('base', method);
        fprintf('  => %s 数据已加载。\n', method);
    else
        warning('工作区中未找到 %s 结构体，将跳过该方法。', method);
    end
end

% 1.4 初始化结果结构
REC_Categorized = struct();

% 1.5 循环处理每个类别
fprintf('\n=== 开始计算各类别的白平衡指标 ===\n');

for i = 1:num_categories
    cat_name = category_names{i};
    InputType = GT.(cat_name);
    rec_var_name = ['REC_' cat_name];
    
    fprintf('\n--- %s 类别白平衡指标 ---\n', upper(cat_name));
    
    % 检查 GT 数据是否存在
    if ~isfield(GT, rec_var_name)
        warning('REC_%s 在 GT 中不存在，跳过该类别。', cat_name);
        continue;
    end
    
    REC_GT = GT.(rec_var_name);
    num_samples = size(REC_GT, 1);
    
    % 初始化该类别下所有颜色空间和指标的存储矩阵
    for cs = 1:num_color_spaces
        color_space = color_spaces{cs};
        for em = 1:num_error_metrics
            error_metric = error_metrics{em};
            REC_Categorized.(cat_name).(color_space).([error_metric '_metrics']) = nan(num_samples, num_methods);
        end
    end
    
    % 存储 GT REC
    REC_Categorized.(cat_name).REC_GT = REC_GT;
    
    % 循环处理每个方法
    for m = 1:num_methods
        method = method_names{m};
        
        % 检查该方法的数据是否存在
        if isfield(method_data, method) && isfield(method_data.(method), rec_var_name)
            REC_Method = method_data.(method).(rec_var_name);
            
            % 计算 GT vs 当前方法
            fprintf('  计算 %s vs %s...\n', method, cat_name);
            [method_metrics, ~] = CalculateMetricsinCS(REC_GT, REC_Method, InputType);
            
            % 将结果存储到对应的位置
            if isstruct(method_metrics)
                % method_metrics 结构: method_metrics.(color_space) = [num_samples × 5]
                for cs = 1:num_color_spaces
                    color_space = color_spaces{cs};
                    if isfield(method_metrics, color_space)
                        % method_metrics.(color_space) 应该是 num_samples × 5 的矩阵
                        for em = 1:num_error_metrics
                            error_metric = error_metrics{em};
                            REC_Categorized.(cat_name).(color_space).([error_metric '_metrics'])(:, m) = ...
                                method_metrics.(color_space)(:, em);
                        end
                    end
                end
            else
                warning('method_metrics 格式不符合预期，请检查 CalculateMetricsinCS 的输出格式。');
            end
            
            fprintf('    => %s 指标计算完成。\n', method);
        else
            warning('  %s.REC_%s 不存在，跳过该方法。', method, cat_name);
        end
    end
end

fprintf('\n=== 所有类别的白平衡指标计算完成 ===\n');
%% ========== 第二部分：计算与主观评分的相关性 ==========
fprintf('\n========================================\n');
fprintf('第二部分：计算与主观评分的相关性\n');
fprintf('========================================\n');

% 2.1 加载主观评分数据
fprintf('\n  => 加载 All_Mean_Ratings_Final.mat...\n');
load('All_Mean_Ratings_Final.mat');

% 2.2 初始化相关性结果结构
Correlation_Results = struct();

% 2.3 循环处理每个类别
for i = 1:num_categories
    cat_name = category_names{i};
    
    fprintf('\n--- 计算 %s 类别的相关性 ---\n', upper(cat_name));
    
    % 检查评分数据是否存在
    rating_var_name = ['Rating_' cat_name];
    if ~evalin('base', ['exist(''' rating_var_name ''', ''var'')'])
        warning('Rating_%s 不存在，跳过该类别。', cat_name);
        continue;
    end
    
    % 获取评分数据
    Rating_table = evalin('base', rating_var_name);
    
    % 提取所有评分列（排除ImageID）
    rating_columns = Rating_table.Properties.VariableNames;
    rating_columns = rating_columns(~strcmp(rating_columns, 'ImageID'));
    num_rating_methods = length(rating_columns);
    
    % 获取评分矩阵 (num_samples × num_rating_methods)
    Ratings = table2array(Rating_table(:, rating_columns));
    num_samples = size(Ratings, 1);
    
    fprintf('  评分数据: %d samples × %d methods\n', num_samples, num_rating_methods);
    
    % 检查 REC_Categorized 数据是否存在
    if ~isfield(REC_Categorized, cat_name)
        warning('REC_Categorized.%s 不存在，跳过该类别。', cat_name);
        continue;
    end
    
    % 循环处理每个颜色空间
    for cs = 1:num_color_spaces
        color_space = color_spaces{cs};
        
        fprintf(' 处理颜色空间: %s\n', color_space);
        
        if ~isfield(REC_Categorized.(cat_name), color_space)
            warning('   颜色空间 %s 不存在，跳过。', color_space);
            continue;
        end
        
        % 循环处理每个误差指标
        for em = 1:num_error_metrics
            error_metric = error_metrics{em};
            metric_name = [error_metric '_metrics'];
            
            if ~isfield(REC_Categorized.(cat_name).(color_space), metric_name)
                warning('    指标 %s 不存在，跳过。', error_metric);
                continue;
            end
            
            % 获取该指标的数据 (num_samples × num_methods)
            Metrics = REC_Categorized.(cat_name).(color_space).(metric_name);
                   
            % === 计算每张图像的相关性 ===
            % 对每张图像，计算其评分与所有算法指标之间的相关性
            Pearson_per_image = nan(num_samples, 1);
            Spearman_per_image = nan(num_samples, 1);
            Pearson_pval_per_image = nan(num_samples, 1);
            Spearman_pval_per_image = nan(num_samples, 1);
            
            for s = 1:num_samples
                % 获取该图像在所有算法上的指标值 (1 × num_methods)
                metrics_row = Metrics(s, :);
                
                % 对每个评分方法计算相关性
                for rm = 1:1
                    % 获取该图像在所有评分方法上的评分 (1 × 1)
                    rating_row = Ratings(s, :);
                    
                    % 检查是否有有效数据（至少需要3个有效的算法结果）
                    valid_idx = ~isnan(metrics_row);
                    
                    if sum(valid_idx) >= 3 && ~isnan(rating_row(rm))
                        % 计算该图像的评分与所有算法指标的 Pearson 相关性
                        [r_p, p_p] = corr(metrics_row(valid_idx)', rating_row', 'Type', 'Pearson');
                        Pearson_per_image(s, rm) = r_p;
                        Pearson_pval_per_image(s, rm) = p_p;
                        
                        % 计算 Spearman 相关性
                        [r_s, p_s] = corr(metrics_row(valid_idx)', rating_row', 'Type', 'Spearman');
                        Spearman_per_image(s, rm) = r_s;
                        Spearman_pval_per_image(s, rm) = p_s;
                    end
                end
            end
            
            % 存储每张图像的相关性结果
            Correlation_Results.(cat_name).(color_space).(error_metric).Pearson_per_image = Pearson_per_image;
            Correlation_Results.(cat_name).(color_space).(error_metric).Pearson_pval_per_image = Pearson_pval_per_image;
            Correlation_Results.(cat_name).(color_space).(error_metric).Spearman_per_image = Spearman_per_image;
            Correlation_Results.(cat_name).(color_space).(error_metric).Spearman_pval_per_image = Spearman_pval_per_image;
            
            % 计算该指标下所有图像的平均相关性
            Correlation_Results.(cat_name).(color_space).(error_metric).Pearson_mean = nanmean(Pearson_per_image(:));
            Correlation_Results.(cat_name).(color_space).(error_metric).Spearman_mean = nanmean(Spearman_per_image(:));
            
            fprintf('   %s: Pearson mean = %.3f, Spearman mean = %.3f (across all images)\n', ...
                error_metric, ...
                Correlation_Results.(cat_name).(color_space).(error_metric).Pearson_mean, ...
                Correlation_Results.(cat_name).(color_space).(error_metric).Spearman_mean);
        end
    end
end

fprintf('\n=== 相关性计算完成 ===\n');

%% ========== 2.4 创建汇总矩阵 ==========
fprintf('\n=== 创建汇总矩阵 ===\n');

% 为每个类别创建汇总矩阵
for i = 1:num_categories
    cat_name = category_names{i};
    
    if ~isfield(Correlation_Results, cat_name)
        continue;
    end
    
    % 获取该类别的样本数量
    rating_var_name = ['Rating_' cat_name];
    if evalin('base', ['exist(''' rating_var_name ''', ''var'')'])
        Rating_table = evalin('base', rating_var_name);
        num_samples = size(Rating_table, 1);
    else
        continue;
    end
    
    % 计算汇总矩阵的列数：6个颜色空间 × 5个误差指标 = 30列
    num_columns = num_color_spaces * num_error_metrics;
    
    % 初始化汇总矩阵 [num_samples × 30]
    Pearson_summary = nan(num_samples, num_columns);
    Spearman_summary = nan(num_samples, num_columns);
    
    % 创建列名
    column_names = cell(1, num_columns);
    col_idx = 0;
    
    % 填充汇总矩阵
    for cs = 1:num_color_spaces
        color_space = color_spaces{cs};
        
        if ~isfield(Correlation_Results.(cat_name), color_space)
            col_idx = col_idx + num_error_metrics;
            continue;
        end
        
        for em = 1:num_error_metrics
            error_metric = error_metrics{em};
            col_idx = col_idx + 1;
            
            % 创建列名：ColorSpace_ErrorMetric
            column_names{col_idx} = [color_space '_' error_metric];
            
            if ~isfield(Correlation_Results.(cat_name).(color_space), error_metric)
                continue;
            end
            
            % 获取该颜色空间-误差指标组合的相关性数据
            corr_data = Correlation_Results.(cat_name).(color_space).(error_metric);
            
            if isfield(corr_data, 'Pearson_per_image')
                % 对每张图像，取所有评分方法的平均相关性
                Pearson_summary(:, col_idx) = nanmean(corr_data.Pearson_per_image, 2);
            end
            
            if isfield(corr_data, 'Spearman_per_image')
                Spearman_summary(:, col_idx) = nanmean(corr_data.Spearman_per_image, 2);
            end
        end
    end
    
    % 存储汇总矩阵
    Correlation_Results.([cat_name '_Pearson_summary']) = Pearson_summary;
    Correlation_Results.([cat_name '_Spearman_summary']) = Spearman_summary;
    Correlation_Results.([cat_name '_column_names']) = column_names;
    
    fprintf('  %s: 汇总矩阵 %d samples × %d metrics\n', upper(cat_name), num_samples, num_columns);
end

fprintf('\n=== 汇总矩阵创建完成 ===\n');

%% ========== 第三部分：结果汇总和可视化 ==========
fprintf('\n========================================\n');
fprintf('第三部分：结果汇总\n');
fprintf('========================================\n');

% 3.1 显示相关性结果摘要
fprintf('\n=== 相关性结果摘要 ===\n');
for i = 1:num_categories
    cat_name = category_names{i};
    if isfield(Correlation_Results, cat_name)
        fprintf('\n%s 类别:\n', upper(cat_name));
        
        % 显示汇总矩阵信息
        pearson_summary_name = [cat_name '_Pearson_summary'];
        spearman_summary_name = [cat_name '_Spearman_summary'];
        
        if isfield(Correlation_Results, pearson_summary_name)
            summary_size = size(Correlation_Results.(pearson_summary_name));
            fprintf('  汇总矩阵: %d images × %d metrics (颜色空间×误差指标)\n', ...
                summary_size(1), summary_size(2));
        end
        
        % 显示详细信息（前2个颜色空间）
        for cs = 1:min(2, num_color_spaces)
            color_space = color_spaces{cs};
            if isfield(Correlation_Results.(cat_name), color_space)
                fprintf('  %s 颜色空间:\n', color_space);
                for em = 1:num_error_metrics
                    error_metric = error_metrics{em};
                    if isfield(Correlation_Results.(cat_name).(color_space), error_metric)
                        corr_data = Correlation_Results.(cat_name).(color_space).(error_metric);
                        fprintf('    %s: Pearson=%.4f, Spearman=%.4f (图像平均)\n', ...
                            strrep(error_metric, '_', ' '), ...
                            corr_data.Pearson_mean, ...
                            corr_data.Spearman_mean);
                    end
                end
            end
        end
        if num_color_spaces > 2
            fprintf('  ... (共 %d 个颜色空间)\n', num_color_spaces);
        end
    end
end

% 3.2 保存结果
fprintf('\n=== 保存结果 ===\n');
save('Correlation_Results.mat', 'Correlation_Results',  'REC_Categorized','-v7.3');
fprintf('  => Correlation_Results 已保存到 Correlation_Results.mat\n');

fprintf('\n========================================\n');
fprintf('所有处理完成！\n');
fprintf('========================================\n');

%% 6. 保存指标结果

save('metrics_results.mat', ...
    'IntraOV_Combined', ...        % 合并的 IntraOV
    'InterOV_Categorized', ...     % 分类别的 InterOV
    'REC_Categorized', ...         % 分类别的白平衡指标 (包含 REC_GT)
    'Correlation_Results', ...     % 相关性结果
    '-v7.3');

fprintf('=== 所有指标和相关性结果已保存到 metrics_results.mat ===\n');