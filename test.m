%% MATLAB Installation Test Script
% This script checks core MATLAB functionality:
% 1. Basic arithmetic
% 2. Linear algebra
% 3. Plotting
% 4. Optimization
% 5. Symbolic toolbox (if installed)

clc;
clear;

fprintf('===============================\n');
fprintf(' MATLAB Installation Test\n');
fprintf('===============================\n\n');

%% 1. Basic Arithmetic
fprintf('1. Testing basic arithmetic...\n');
a = 5;
b = 3;
c = a^2 + b^2;
fprintf('   5^2 + 3^2 = %d\n\n', c);

%% 2. Linear Algebra Test
fprintf('2. Testing linear algebra...\n');
A = rand(3);
b = rand(3,1);

x = A\b;              % Solve linear system
detA = det(A);        % Determinant
eigA = eig(A);        % Eigenvalues

fprintf('   Determinant of A: %f\n', detA);
fprintf('   Eigenvalues of A:\n');
disp(eigA);

%% 3. Plotting Test
fprintf('3. Testing plotting...\n');
x_plot = linspace(0,2*pi,100);
y_plot = sin(x_plot);

figure;
plot(x_plot,y_plot,'LineWidth',2);
title('Test Plot: y = sin(x)');
xlabel('x');
ylabel('sin(x)');
grid on;

fprintf('   Plot window should have opened.\n\n');

%% 4. Optimization Test
fprintf('4. Testing optimization (fminsearch)...\n');
f = @(x) (x-2)^2 + 1;
xmin = fminsearch(f,0);

fprintf('   Minimum found at x = %.4f\n\n', xmin);

%% 5. Symbolic Toolbox Test (optional)
fprintf('5. Testing symbolic toolbox...\n');
if license('test','Symbolic_Toolbox')
    syms x
    f_sym = x^2 + 2*x + 1;
    df = diff(f_sym);
    fprintf('   Symbolic derivative of x^2+2x+1:\n');
    disp(df);
else
    fprintf('   Symbolic toolbox not installed (this is OK).\n');
end

fprintf('\n===============================\n');
fprintf(' All tests completed.\n');
fprintf('===============================\n');
