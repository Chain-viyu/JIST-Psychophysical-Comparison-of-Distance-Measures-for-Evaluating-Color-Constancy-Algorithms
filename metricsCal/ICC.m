function icc_value = ICC(data, type)
    % data: n×k矩阵 (n个项目, k个评分者)
    % type: 'A-1' 表示ICC(2,1)
    
    [n, k] = size(data);
    
    % 计算均方
    grand_mean = mean(data(:));
    row_means = mean(data, 2);
    col_means = mean(data, 1);
    
    % 被试间均方 (BMS)
    BMS = k * sum((row_means - grand_mean).^2) / (n - 1);
    
    % 评分者间均方 (JMS)
    JMS = n * sum((col_means - grand_mean).^2) / (k - 1);
    
    % 误差均方 (EMS)
    SS_error = sum(sum((data - repmat(row_means, 1, k) - repmat(col_means, n, 1) + grand_mean).^2));
    EMS = SS_error / ((n - 1) * (k - 1));
    
    % ICC(2,1)
    icc_value = (BMS - EMS) / (BMS + (k - 1) * EMS + k * (JMS - EMS) / n);
end