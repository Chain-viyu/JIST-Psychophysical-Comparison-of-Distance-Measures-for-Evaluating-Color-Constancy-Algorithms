function inter_stress= STRESSinter( data )
% dV 应为列向量
% data = []; % 每列数据计算出一个inter-STRESS

m = size(data, 2); 
inter_result = zeros(1,m);
for j = 1:m
    dV = data(:,j);
    n=length(dV);
    E=ones(n,1);
    avg=mean(dV);
    dE=E*avg;
    F1=sum(dE.^2)/sum(dE.*dV);
    for i=1:n
        a(i,:)=dE(i,:)-F1*dV(i,:);
    end
    A=sum(a.^2);
    B=sum((F1^2)*(dV.^2));
    stress=(A/B)^(0.5).*100;
    inter_result(1,j) = stress; 
end
inter_stress = inter_result';
end