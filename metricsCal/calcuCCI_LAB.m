function [LAB_metric,lab_time] = calcuCCI_LAB(LAB_gt,LAB_e)
    % 颜色恒常性算法误差预测指标计算
    % LAB_gt:实际场景光源 n*3的矩阵
    % LAB_e:算法估计光源 n*3的矩阵
    
    n = size(LAB_gt,1);
    % LAB颜色空间指标
    LAB_white = [100,0,0];
    time_rec = 0;
    time_rep = 0;
    time_euc = 0;
    time_CCIrec = 0;
    time_CCIeuc = 0;
    for i = 1:n
        tic;
        LAB_rec(i) = acos_deg(LAB_gt(i,:), LAB_e(i,:));
        time_rec = time_rec + toc;
        tic;
        LAB_ep = [LAB_gt(i,1)/LAB_e(i,1), (LAB_gt(i,2)-LAB_e(i,2))/256, (LAB_gt(i,3)-LAB_e(i,3))/256];
        LAB_rep(i) = acos_deg(LAB_white, LAB_ep);
        time_rep = time_rep + toc;
        tic;
        LAB_euc(i) = sqrt(sum((LAB_gt(i,:) - LAB_e(i,:)).^2));
        time_euc = time_euc + toc;
        tic;
        LAB_CCIrec(i) = LAB_rec(i)/acos_deg(LAB_gt(i,:), LAB_white);
        time_CCIrec = time_CCIrec + time_rec + toc;
        tic;
        LAB_CCIeuc(i) = LAB_euc(i)/sqrt(sum((LAB_gt(i,:) - LAB_white).^2));
        time_CCIeuc = time_CCIeuc + time_euc + toc;
    end
    LAB_metric = [LAB_rec',LAB_rep',LAB_euc',LAB_CCIrec',LAB_CCIeuc'];
    lab_time = [time_rec,time_rep,time_euc,time_CCIrec,time_CCIeuc];
end