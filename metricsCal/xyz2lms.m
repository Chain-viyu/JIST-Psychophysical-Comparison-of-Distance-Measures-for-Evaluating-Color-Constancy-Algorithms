function LMS = xyz2lms(XYZ)
    %D65
    XYZ2LMS = [0.4002 0.7075 -0.0807;-0.2280 1.1500 0.0612;0 0 0.9184];
    xyz = XYZ';
    lms = XYZ2LMS * xyz;
    lms = lms / sum(lms);
    LMS = lms';
end

% function LMS = xyz2lms(XYZ)
%     %D65
%     XYZ2LMS = [0.4002 0.7075 -0.0807;-0.2280 1.1500 0.0612;0 0 0.9184];
%     n = size(XYZ,1);
%     LMS = ones(n,3);
%     for i = 1:n
%         xyz = XYZ(i,:)';
%         lms = XYZ2LMS * xyz;
%         lms = lms / sum(lms);
%         LMS(i,:) = lms';
%     end
% end