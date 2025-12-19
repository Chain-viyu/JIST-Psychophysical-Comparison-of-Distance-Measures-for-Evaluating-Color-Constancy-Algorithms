function alpha = cronbach(data)
    % 计算Cronbach's Alpha信度系数
    % data: n×k矩阵 (n个项目, k个评分者)
    
    [n, k] = size(data);
    
    % 计算各列方差
    item_var = var(data, 0, 1);
    
    % 计算总分方差
    total_scores = sum(data, 2);
    total_var = var(total_scores);
    
    % Cronbach's Alpha公式
    alpha = (k / (k - 1)) * (1 - sum(item_var) / total_var);
end