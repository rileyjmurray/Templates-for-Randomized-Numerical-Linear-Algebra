% Throws an asserion error if something went wrong.
function [] = test_least_squares()
    addpath('../matrix_generators/');

    % consistent_tall
    m = 100;
    n = 10;
    A = gen_simp_mat(m, n, 1);
    [U, s, Vt] = svd(A);
    size(A)
    x = randn(n, 1);
    test1.A = A;
    test1.U = U;
    test1.s = s;
    test1.Vt = Vt;
    test1.x_opt = x;
    test1.b = A * x;

    % consistent_lowrank
    m = 100;
    n = 10;
    rank = 5;
    U = randn(m, rank);
    [U,~] = qr(U, 0);
    s = diag(rand(rank, 1) + 1e-4);
    V = randn(n, rank);
    [V,~] = qr(V, 0);
    Vt = V';
    A = (U * s) * Vt;
    x = randn(n, 1);
    test2.A = A;
    test2.U = U;
    test2.s = s;
    test2.Vt = Vt;
    test2.x_opt = x;
    test2.b = A * x;
   
    % consistent_square
    n = 10;
    s = diag(rand(n, 1) + 1e-4);
    U = randn(m, n);
    [U,~] = qr(U, 0);
    V = randn(n, n);
    [V, ~] = qr(V, 0);
    Vt = V'; 
    A = (U * s) * Vt;
    x = randn(n, 1);
    test3.A = A;
    test3.U = U;
    test3.s = s;
    test3.Vt = Vt;
    test3.x_opt = x;
    test3.b = A * x;    

    % inconsistent_orthog
    m = 1000;
    n = 100;
    U = randn(m, n);
    [U,~] = qr(U, 0);
    V = randn(n, n);
    [V, ~] = qr(V, 0);
    Vt = V'; 
    s = diag(rand(n, 1) + 1e-4);
    A = U * s * Vt;
    b = randn(m, 1);
    b = b - U * (U' * b);
    test4.A = A;
    test4.U = U;
    test4.s = s;
    test4.Vt = Vt;
    test4.b = b * 1e2 / norm(b, 2);
    test4.x_opt = zeros(n, 1); 
    
    % inconsistent_gen
    m = 1000;
    n = 100;
    num_hi = 30;
    num_lo = n - num_hi;
    % Make A
    hi_spec = 1e5 * ones(1, num_hi) + rand(1, num_hi);
    lo_spec = ones(1, num_lo) + rand(1, num_lo);
    spec = diag(cat(2, hi_spec, lo_spec));
    U = randn(m, n);
    [U,~] = qr(U, 0);
    V = randn(n, n);
    [V,~] = qr(V, 0);
    Vt = V';
    A = (U * spec) * Vt;
    % Make b
    hi_x = randn(num_hi, 1) / 1e5;
    lo_x = randn(num_lo, 1);
    x = cat(1, hi_x, lo_x);
    b_orth = randn(m, 1) * 1e2;
    % orthogonal to range(A)
    b_orth = b_orth - U * (U' * b_orth);
    test5.A = A;
    test5.U = U;
    test5.s = s;
    test5.Vt = Vt;
    test5.x_opt = x;
    test5.b = A * x + b_orth;
    
    %test_spo3(test1, test3, test4, test5);
    test_spo1(test1, test2, test3, test4, test5);
end

function[] = test_spo3(test1, test3, test4, test5)
    addpath('../../drivers/least_squares/');

        % consistent_tall
        test1.x_approx = spo3(test1.A, test1.b, 1, 0.0, 1, 0);
        run_consistent(test1, 1e-12);

        % consistent_square
        test3.x_approx = spo3(test3.A, test3.b, 1, 0.0, 1, 0);
        run_consistent(test3, 1e-12);

        % inconsistent_orthog
        test4.x_approx = spo3(test4.A, test4.b, 3, 1e-12, 100, 0);
        run_inconsistent(test4, 1e-6);

        % inconsistent_gen
        test5.x_approx = spo3(test5.A, test5.b, 3, 1e-12, 100, 0);
        run_inconsistent(test5, 1e-6);
end

function[] = test_spo1(test1, test2, test3, test4, test5)
    addpath('../../drivers/least_squares/');

        % consistent_tall()
        test1.x_approx = spo1(test1.A, test1.b, 3, 1e-12, 100, 0, 0);
        run_consistent(test1, 1e-6)
        test1.x_approx = spo1(test1.A, test1.b, 1, 0.0, 1, 1, 0);
        run_consistent(test1, 1e-12);

        % consistent_lowrank
        test2.x_approx = spo1(test2.A, test2.b, 3, 0.0, 100, 0, 0);
        run_consistent(test2, 1e-6);
        test2.x_approx = spo1(test2.A, test2.b, 1, 0.0, 1, 1, 0);
        run_consistent(test2, 1e-12);

        % consistent_square
        test3.x_approx = spo1(test3.A, test3.b, 1, 0.0, 100, 0, 0);
        run_consistent(test3, 1e-6);
        test3.x_approx = spo1(test3.A, test3.b, 1, 0.0, 1, 1, 0);
        run_consistent(test3, 1e-12)

        % inconsistent_orthog
        test4.x_approx = spo1(test4.A, test4.b, 3, 1e-12, 100, 0, 0);
        run_inconsistent(test4, 1e-6);
        test4.x_approx = spo1(test4.A, test4.b, 3, 1e-12, 100, 1, 0);
        run_inconsistent(test4, 1e-6);

        % inconsistent_gen
        test5.x_approx = spo1(test5.A, test5.b, 3, 1e-12, 100, 0, 0);
        run_inconsistent(test5, 1e-6);
        test5.x_approx = spo1(test5.A, test5.b, 3, 1e-12, 50, 1, 0);
        run_inconsistent(test5, 1e-6);
end

function[] = test_sso1(test1, test2, test3, test4, test5)
    addpath('../../drivers/least_squares/');
end

function[] = run_inconsistent(self, test_tol)
        test_residual_proj(self, test_tol);
        test_x_angle(self, test_tol);
        test_x_norm(self, test_tol);
end

function[] = run_consistent(self, test_tol)
        test_x_norm(self, test_tol);
        test_x_angle(self, test_tol);
        test_objective(self, test_tol);
end

function[] = test_x_angle(self, tol)
    % x' x_opt >= (1 - tol)*||x|| ||x_opt||
    y_opt = self.Vt * self.x_opt;
    norm_y_opt = norm(y_opt, 2);
    y = self.Vt * self.x_approx;
    norm_y = norm(y, 2);
    if norm_y_opt < 1e-8
        % Norm is too small to accurately compute cosine
        assert(abs(norm_y - norm_y_opt) <= tol);
    else
        y_opt = y_opt / norm_y_opt;
        y = y / norm_y;
        cosine = dot(y, y_opt);
        assert(cosine >= (1 - tol));
    end
end

function[] = test_x_norm(self, tol)
    % (1 - tol)*||x_opt|| <= ||x|| <= (1+tol)*||x_opt|| + tol
    nrm = norm(self.Vt * self.x_approx, 2);
    norm_opt = norm(self.Vt * self.x_approx, 2);
    assert(nrm <= ((1+tol)*norm_opt + tol));
    assert(((1-tol)*norm_opt) <= nrm);    
end

function[] = test_delta_x(self, tol)
    %||x - x_opt|| <= tol
    delta_x = self.x_opt - self.x_approx;
    nrm = norm(delta_x, 2) / (1 + min(norm(self.x_opt, 2), norm(self.x_approx, 2)));
    assert(nrm <= tol);
end

function[] = test_residual_proj(self, tol)
    % || U U' (A x - b) || / ||A x - b|| <= tol
    % This test is probably better scaled than the normal equations
    residual = self.A * self.x_approx - self.b;
    residual_proj = self.U * (self.U' * residual);
    nrm = norm(residual_proj, 2) / norm(residual, 2);
    assert(nrm <= tol);
end

function[] = test_objective(self, tol)
    % ||A x - b|| <= ||A x_opt - b|| + tol
    res_approx = self.b - self.A * self.x_approx;
    res_opt = self.b - self.A * self.x_opt;
    nrm_approx = norm(res_approx, 2);
    nrm_opt = norm(res_opt, 2);
    assert(nrm_approx <= (nrm_opt + tol));
end

function[] = test_normal_eqs(self, tol)
    % || A' A x - A' b|| <= tol
    gap = (self.A)' * self.b - (self.A)' * (self.A * self.x_approx);
    nrm = norm(gap, 2);
    assert(nrm <= tol);
end
%{
function[] = test_convergence_rate(self, seed)
    addpath('../Matrix_Generators/');
    n_rows = 1000;
    % least 10x more rows than cols
    n_cols = 50; 
    A = gen_simp_mat(n_rows, n_cols, 5);
    x0 = randn(n_cols, 1);
    b0 = A * x0;
    b = b0 + 0.05 * randn(n_rows, 1);
    x_star = la.lstsq(A, b)[0]
    errors = []
    sampling_factors = arange(start=1, stop=10, step=10 / n_cols)
    for sf in sampling_factors:
        sas.sampling_factor = sf
        x_ske = sas(A, b, tol=np.NaN, iter_lim=1, rng=rng)
        err = la.norm(x_ske - x_star)
        errors.append(err)
    errors = np.array(errors)
    coeffs, r2 = ustats.loglog_fit(sampling_factors, errors)
    % at least 1/sqrt(d)
    self.assertLessEqual(coeffs[1], -0.5) 
    self.assertGreaterEqual(r2, 0.7)
end
%}