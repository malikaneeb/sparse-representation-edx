function x = oracle(CA, b, s)
% ORACLE Implementation of the Oracle estimator
%
% Solves the following problem:
%   min_x ||b - CAx||_2^2 s.t. supp{x} = s
% where s is a vector containing the support of the true sparse vector
%
% The solution is returned in the vector x

% Initialize the vector x
x = zeros(size(CA,2),1);

% TODO: Implement the Oracle estimator
% Write your code here... x = ????;
As = full(CA(:, s));
x(s) = pinv(As) * b;

end

