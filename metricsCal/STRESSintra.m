function intra_stress= STRESSintra( data )
%% calculation of STRESS (standaridized residual sum of squares )
% dV, dE 应为列向量
% data = []; % 每两列数据计算出一个intra-STRESS，奇数列dV，偶数列dE

m = size(data, 2)/2;
intra_result = zeros(1,m);
for j = 1:m
    dV = data(:,2*j-1);
    dE = data(:,2*j);
    n=length(dV);
    F1=sum(dE.^2)/sum(dE.*dV);
    for i=1:n
        a(i,:)=dE(i,:)-F1*dV(i,:);
    end
    A=sum(a.^2);
    B=sum((F1^2)*(dV.^2));
    stress=(A/B)^(0.5)*100;
    intra_result(1,j) = stress;
end
intra_stress = intra_result;
end