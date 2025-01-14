function[Omega] = srht(A, d)
    %{
    Constructs a sketching operator of size (size(A, 2), d) using
    subsampled randomized discrete Walsh-Hadamar transform.

    Utilizes Matlab's built-in fwht() function.

    Serves an illustrative matter, rather than an efficient implementation.
    %}
    [m, n] = size(A);
    % Generating a random sign vector
    sgn = (rand(1, n) < .5) * 2 - 1;
    % Randomly changing signs of columns of A
    A = bsxfun(@times, A, sgn);
    
    % WHT are only defined for even dimensions
    m = 2^(ceil(log2(m)));
    
    % Applying an m-step WHT
    Omega = (fwht(A, m));
    
    % Random subsampling of the transform output
    idx = sort(randsample(m, d));
    Omega = Omega(idx, :)';
    % Multiplying by a constanat
    Omega = Omega * (sqrt(m / d));
    % Optional random row permutation
    idx = randperm(n);
    Omega = Omega(idx,:);
end