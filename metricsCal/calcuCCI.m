function [RGB_metric,RGB_time] = calcuCCI(RGB_gt,RGB_e)
    % 颜色恒常性算法误差预测指标计算
    % RGB_gt:实际场景光源 n*3的矩阵
    % RGB_e:算法估计光源 n*3的矩阵
    
    n = size(RGB_gt,1);
    % RGB颜色空间指标
    RGB_white = [0.33,0.33,0.33];
    time_rec = 0;
    time_rep = 0;
    time_euc = 0;
    time_CCIrec = 0;
    time_CCIeuc = 0;
    for i = 1:n
        tic;
        RGB_rec(i) = acos_deg(RGB_gt(i,:),RGB_e(i,:));
        time_rec = time_rec + toc;
        tic;
        RGB_rep(i) = acos_deg(RGB_white,RGB_gt(i,:)./RGB_e(i,:));
        time_rep = time_rep + toc;
        tic;
        RGB_euc(i) = sqrt(sum((RGB_gt(i,:) - RGB_e(i,:)).^2));
        time_euc = time_euc + toc;
        tic;
        RGB_CCIrec(i) = RGB_rec(i)/acos_deg(RGB_gt(i,:),RGB_white);
        time_CCIrec = time_CCIrec + time_rec + toc;
        tic;
        RGB_CCIeuc(i) = RGB_euc(i)/sqrt(sum((RGB_gt(i,:) - RGB_white).^2));
        time_CCIeuc = time_CCIeuc + time_euc + toc;
    end
    RGB_metric = [RGB_rec',RGB_rep',RGB_euc',RGB_CCIrec',RGB_CCIeuc'];
    RGB_time = [time_rec,time_rep,time_euc,time_CCIrec,time_CCIeuc];
end