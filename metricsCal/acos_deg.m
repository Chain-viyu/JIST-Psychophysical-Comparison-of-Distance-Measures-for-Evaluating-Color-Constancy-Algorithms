function theta_deg = acos_deg(A,B)
    dotProduct = dot(A, B);
    normA = norm(A);
    normB = norm(B);
    cosTheta = dotProduct / (normA * normB);
    theta = acos(cosTheta);
    theta_deg = rad2deg(theta);
end