delta = 1/256;
maxiter = 1000;
t = -.5:delta:.5-delta;
N = length(t);
error_tol = 1e-10;

full_f = sin(t*10) + sin;



f = abs(full_f);
F = abs(fft(full_f)/N);

phi = 2*pi*rand(1,N) - pi;
x = f*exp(i*phi);