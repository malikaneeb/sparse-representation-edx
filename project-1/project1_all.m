% In this project we demonstrate the OMP and BP algorithms, by running them 
% on a set of signals and checking whether they provide the desired outcome
 
%% Parameters
 
% TODO: Set the length of the signal
% Write your code here... n = ????;
n = 50;

% TODO: Set the number of atoms in the dictionary
% Write your code here... m = ????;
m = 100;

% TODO: Set the maximum number of non-zeros in the generated vector
% Write your code here... s_max = ????;
s_max = 15;

% TODO: Set the minimal entry value
% Write your code here... min_coeff_val = ????;
min_coeff_val = 1;

% TODO: Set the maximal entry value
% Write your code here... max_coeff_val = ????;
max_coeff_val = 3;

% Number of realizations
num_realizations = 200;

% Base seed: A non-negative integer used to reproduce the results
% TODO: Set an arbitrary value for base seed
% Write your code here... base_seed = ????;
base_seed = 4321;

%% Create the dictionary
 
% TODO: Create a random matrix A of size (n x m)
% Write your code here... A = ????;
A = randn(n,m);


% TODO: Normalize the columns of the matrix to have a unit norm
% Write your code here... A_normalized = ????;
col_norm = sqrt(sum(A.^2, 1));
A_normalized = A ./ col_norm;


%% Create data and run OMP and BP
 
% Nullify the entries in the estimated vector that are smaller than eps
eps_coeff = 1e-4;
% Set the optimality tolerance of the linear programing solver
tol_lp = 1e-4;
 
% Allocate a matrix to save the L2 error of the obtained solutions
L2_error = zeros(s_max,num_realizations,2); 
% Allocate a matrix to save the support recovery score
support_error = zeros(s_max,num_realizations,2);
           
% Loop over the sparsity level
for s = 1:s_max
    
    % Use the same random seed in order to reproduce the results if needed
    rng(s+base_seed)
    
    % Loop over the number of realizations
    for experiment = 1:num_realizations
   
        % In this part we will generate a test signal b = A_normalized*x by 
        % drawing at random a sparse vector x with s non-zeros entries in 
        % true_supp locations with values in the range of [min_coeff_val, max_coeff_val]
        x = zeros(m,1);
        
        % TODO: Draw at random a true_supp vector
        % Write your code here... true_supp = ????;
        true_supp = randperm(m, s);
        
        % TODO: Draw at random the coefficients of x in true_supp locations
        % Write your code here... x = ????;
        rsign = (rand(s,1) > 0.5) * 2 - 1;
        x(true_supp) = sparse(rsign .* ((max_coeff_val-min_coeff_val) ...
            .* rand(s,1) + min_coeff_val));
        
        % TODO: Create the signal b
        % Write your code here... b = ????;
        b = A_normalized * x;
        
        % TODO: Run OMP
        % Write your code here... x_omp = omp(????, ????, ????);
        x_omp = omp(A_normalized, b, s);
        x_omp(abs(x_omp) < eps_coeff) = 0;
        
        % TODO: Compute the relative L2 error
        % Write your code here... L2_error(s,experiment,1) = ????;
        L2_error(s, experiment, 1) = sum( (x_omp - x).^2 ) / sum(x.^2);
        %L2_error(s, experiment, 1) = norm(x_omp - x)^2 / norm(x)^2;
        
        % TODO: Get the indices of the estimated support
        % Write your code here... estimated_supp = ????;
        estimated_supp = sum(abs(x_omp) > eps_coeff);
        
        % TODO: Compute the support recovery score
        % Write your code here... support_error(s,experiment,1) = ????;
        support_error(s,experiment,1) = ...
            1 - sum((x ~= 0) & (abs(x_omp) > eps_coeff)) / ...
            max(estimated_supp, s);
        
        % TODO: Run BP
        % Write your code here... x_lp = lp(????, ????, ????);
        x_lp = lp(A_normalized, b, tol_lp);
        x_lp(abs(x_lp) < eps_coeff) = 0;
        
        % TODO: Compute the relative L2 error
        % Write your code here... L2_error(s,experiment,2) = ????;
        L2_error(s, experiment, 2) = sum( (x_lp - x).^2 ) / sum(x.^2);
        %L2_error(s, experiment, 2) = norm(x_lp - x)^2 / norm(x)^2;
        
        % TODO: Get the indices of the estimated support, where the
        % coeffecients are larger (in absolute value) than eps_coeff
        % Write your code here... estimated_supp = ????;
        estimated_supp = sum(abs(x_lp) > eps_coeff);
        
        % TODO: Compute the support recovery error
        % Write your code here... support_error(s,experiment,2) = ????;
        support_error(s,experiment,2) = ...
            1 - sum((x ~= 0) & (abs(x_lp) > eps_coeff)) / ...
            max(estimated_supp, s);
 
    end
    
end
 
%% Display the results 
 
% Plot the average relative L2 error, obtained by the OMP and BP versus the cardinality
figure(1); clf; 
plot(1:s_max,mean(L2_error(1:s_max,:,1),2),'r','LineWidth',2); hold on;
plot(1:s_max,mean(L2_error(1:s_max,:,2),2),'g','LineWidth',2); 
xlabel('Cardinality of the true solution');
ylabel('Average and Relative L_2-Error');
set(gca,'FontSize',14);
legend({'OMP','LP'});
axis([0 s_max 0 1]);
 
% Plot the average support recovery score, obtained by the OMP and BP versus the cardinality
figure(2); clf; 
plot(1:s_max,mean(support_error(1:s_max,:,1),2),'r','LineWidth',2); hold on;
plot(1:s_max,mean(support_error(1:s_max,:,2),2),'g','LineWidth',2); 
xlabel('Cardinality of the true solution');
ylabel('Probability of Error in Support');
set(gca,'FontSize',14);
legend({'OMP','LP'});
axis([0 s_max 0 1]);

% Comment:
% L2-error Basis pursuit (LP) is superior to OMP giving a reasonable error
% until the cardinality equals 7. For OMP that happens for a cardinality
% equal to 5. Also LP manages to have relative error less than at least
% until cardinality equal to 15.
% 
% Regarding the support recovery error, there is not a clear winner.
% However OMP presents a smaller error for larger cardinalities,
% which is better.