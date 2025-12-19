function metrics_intra = CalculateIntraVariability(intra_ind, intra_pool)
    % 计算个体内变异性指标
    % intra_ind: 每个被试的重复评分数据 (行数 x [序号, 被试1评分1, 被试1评分2, ...])
    % intra_pool: 所有被试合并的重复评分数据 (总行数 x [序号, 评分1, 评分2])
    % 输出:
    %   metrics_intra: 结构体，包含各类别的详细指标
    %   metrics_intra.summary_matrix: 4×8矩阵 (4类别 × 8指标)
    %                   列顺序: ICC_individual_mean, ICC_pooled, STRESS_intra_mean, STRESS_intra_pooled, 
    %                           ICC_individual_max, ICC_individual_min, STRESS_intra_max, STRESS_intra_min
    
    % 定义类别
    scene_1D = 24;
    scene_5D = [49, 50, 51, 54, 55, 56, 57, 58, 65, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 81, 82, 83, 84, 85, 92, 93, 126, 130];
    
    nature_1D = [22, 25];
    nature_5D = [52, 53, 59, 60, 61, 62, 66, 80, 86, 87, 88, 89, 90, 91, 94, 123, 124, 127, 128, 129, 131, 132];
    
    indoor_1D = [1, 2, 3, 4, 5, 10, 16, 17, 23, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 39, 40, 41, 46, 47];
    indoor_5D = [100, 101, 102, 104, 133];
    
    portrait_5D = [63, 64, 95, 96, 97, 98, 99, 103, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 125, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164];
    portrait_1D = [6, 7, 8, 9, 11, 12, 13, 14, 15, 18, 19, 20, 21, 31, 37, 38, 42, 43, 44, 45, 48];
    
    % 合并各类别
    scene_all = [scene_1D, scene_5D];
    nature_all = [nature_1D, nature_5D];
    indoor_all = [indoor_1D, indoor_5D];
    portrait_all = [portrait_5D, portrait_1D];
    
    categories = {'scene', 'nature', 'indoor', 'portrait'};
    category_indices = {scene_all, nature_all, indoor_all, portrait_all};
    
    % 初始化输出
    metrics_intra = struct();
    metrics_intra.summary_matrix = zeros(4, 8);  % 4类别 × 8指标
    
    % 对每个类别计算指标
    for cat_idx = 1:length(categories)
        cat_name = categories{cat_idx};
        cat_ind = category_indices{cat_idx};
        
        fprintf('\n=== %s类别 Intra指标 ===\n', upper(cat_name));
        
        % 从intra_ind中提取属于该类别的行
        mask_ind = ismember(intra_ind(:, 1), cat_ind);
        cat_intra_ind = intra_ind(mask_ind, :);
        
        % 从intra_pool中提取属于该类别的行
        mask_pool = ismember(intra_pool(:, 1), cat_ind);
        cat_intra_pool = intra_pool(mask_pool, :);
        
        % 打印数据量
        fprintf('  intra_ind 数据量 (行数): %d\n', size(cat_intra_ind, 1));
        fprintf('  intra_pool 数据量 (行数): %d\n', size(cat_intra_pool, 1));
        
        if isempty(cat_intra_ind)
            fprintf('  该类别无数据\n');
            metrics_intra.summary_matrix(cat_idx, :) = NaN;
            continue;
        end
        
        % 计算个体内ICC
        numSubjects = (size(intra_ind, 2) - 1) / 2;
        icc_individual = zeros(numSubjects, 1);
        
        % 检查 numSubjects 是否为整数
        if mod(numSubjects, 1) ~= 0
             warning('intra_ind 的列数 (除了第1列) 应该能被2整除.');
             numSubjects = floor(numSubjects); % 采取保守措施
        end
        
        for i = 1:numSubjects
            col1 = 2 * i;
            col2 = 2 * i + 1;
            data = [cat_intra_ind(:, col1), cat_intra_ind(:, col2)];
            
            % ICC函数需要至少两行数据，且不能有NaN
            valid_rows = all(~isnan(data), 2);
            valid_data = data(valid_rows, :);
            
            if size(valid_data, 1) >= 2
                % 假设 ICC(data, 'A-1') 是一个已定义的函数
                icc_individual(i) = ICC(valid_data, 'A-1'); 
            else
                icc_individual(i) = NaN;
            end
        end
        
        % 移除NaN值，以便计算min/max，但保留NaN值用于mean的nanmean
        valid_icc = icc_individual(~isnan(icc_individual));
        
        metrics_intra.(cat_name).ICC_individual = icc_individual;
        metrics_intra.(cat_name).ICC_individual_mean = nanmean(icc_individual);
        metrics_intra.(cat_name).ICC_individual_max = max(valid_icc); % 如果valid_icc为空，max返回空
        metrics_intra.(cat_name).ICC_individual_min = min(valid_icc); % 如果valid_icc为空，min返回空
        
        % 计算合并内信度
        if ~isempty(cat_intra_pool)
            data_pool = [cat_intra_pool(:, 2), cat_intra_pool(:, 3)];
            % 移除NaN行
            valid_rows_pool = all(~isnan(data_pool), 2);
            valid_data_pool = data_pool(valid_rows_pool, :);
            
            if size(valid_data_pool, 1) >= 2
                 metrics_intra.(cat_name).ICC_pooled = ICC(valid_data_pool, 'A-1');
            else
                 metrics_intra.(cat_name).ICC_pooled = NaN;
            end
        else
            metrics_intra.(cat_name).ICC_pooled = NaN;
        end
        
        % 计算Intra-STRESS (个体)
        % 假设 STRESSintra 接受 [n_items, n_raters*n_replicates] 或 [n_items*n_raters, n_replicates] 形式
        % 原始代码使用 [n_items, n_raters*n_replicates]，即每对评分并列
        intra_data = cat_intra_ind(:, 2:end) + 5; % 假设STRESSintra需要加5
        % 假设 STRESSintra(intra_data) 返回一个 [numSubjects, 1] 的向量
        stress_individual = STRESSintra(intra_data); 
        
        % 处理STRESSindividual
        valid_stress = stress_individual(~isnan(stress_individual));
        
        metrics_intra.(cat_name).STRESS_intra_individual = stress_individual;
        metrics_intra.(cat_name).STRESS_intra_mean = nanmean(stress_individual);
        metrics_intra.(cat_name).STRESS_intra_max = max(valid_stress);
        metrics_intra.(cat_name).STRESS_intra_min = min(valid_stress);
        
        % 计算Intra-STRESS (合并)
        if ~isempty(cat_intra_pool)
            pool_data = cat_intra_pool(:, 2:3) + 5;
            % 假设STRESSintra接受 [n_items, 2] 形式
            metrics_intra.(cat_name).STRESS_intra_pooled = STRESSintra(pool_data);
        else
            metrics_intra.(cat_name).STRESS_intra_pooled = NaN;
        end
        
        % 填充汇总矩阵 (4类别 × 8指标)
        metrics_intra.summary_matrix(cat_idx, 1) = metrics_intra.(cat_name).ICC_individual_mean;
        metrics_intra.summary_matrix(cat_idx, 2) = metrics_intra.(cat_name).ICC_pooled;
        metrics_intra.summary_matrix(cat_idx, 3) = metrics_intra.(cat_name).STRESS_intra_mean;
        metrics_intra.summary_matrix(cat_idx, 4) = metrics_intra.(cat_name).STRESS_intra_pooled;
        metrics_intra.summary_matrix(cat_idx, 5) = metrics_intra.(cat_name).ICC_individual_max;
        metrics_intra.summary_matrix(cat_idx, 6) = metrics_intra.(cat_name).ICC_individual_min;
        metrics_intra.summary_matrix(cat_idx, 7) = metrics_intra.(cat_name).STRESS_intra_max;
        metrics_intra.summary_matrix(cat_idx, 8) = metrics_intra.(cat_name).STRESS_intra_min;
        
        % 输出结果
        fprintf('  个体内ICC均值: %.4f (Max: %.4f, Min: %.4f)\n', ...
            metrics_intra.(cat_name).ICC_individual_mean, ...
            metrics_intra.(cat_name).ICC_individual_max, ...
            metrics_intra.(cat_name).ICC_individual_min);
        fprintf('  合并ICC: %.4f\n', metrics_intra.(cat_name).ICC_pooled);
        fprintf('  个体内STRESS均值: %.4f (Max: %.4f, Min: %.4f)\n', ...
            metrics_intra.(cat_name).STRESS_intra_mean, ...
            metrics_intra.(cat_name).STRESS_intra_max, ...
            metrics_intra.(cat_name).STRESS_intra_min);
        fprintf('  合并内STRESS: %.4f\n', metrics_intra.(cat_name).STRESS_intra_pooled);
    end
    
    % 输出汇总矩阵
    fprintf('\n=== Intra指标汇总矩阵 (4类别 × 8指标) ===\n');
    fprintf('行: scene, nature, indoor, portrait\n');
    fprintf('列1-4: ICC_individual_mean, ICC_pooled, STRESS_intra_mean, STRESS_intra_pooled\n');
    fprintf('列5-8: ICC_individual_max, ICC_individual_min, STRESS_intra_max, STRESS_intra_min\n\n');
    disp(metrics_intra.summary_matrix);
end