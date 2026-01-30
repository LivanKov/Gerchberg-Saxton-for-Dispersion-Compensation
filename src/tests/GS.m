Maxiter = 10000;
t = -5:0.01:5-0.01;
N = length(t);

full_f = rectangularPulse(-.5, .5, 2*t).*exp(30i*pi*t.^2);

f = abs(full_f);
F = abs(fft(full_f)/N);

plot(f);
figure;
plot(F);
figure;
plot(angle(full_f));


phi = 2*pi*rand(1, N) - pi;
x = f.*exp(1i*phi);

k = 1;

while k < Maxiter
    X = fft(x)/N;
    Y = F.*exp(1i*angle(X));
    y = N * ifft(Y);
    x = f.*exp(1i*angle(y));
    k = k + 1;
end

figure;
plot(angle(x));

% Gerchberg-Saxton conversion via difference
% Optimize the consistency of the GS-Algorithm (currently rather inconsistent)