system = System;
system.pulseShape = Pulse.SINC;
system.CHAN_LEN = 20;
system.ingest('10101010001010101');
system.shapeInput();

target_launch = system.currentVals;
target_envelope = abs(target_launch);

max_iters = 100;

% Arbitrary phase
% pattern ϕ(t) should be generated and combined with the target
%amplitude A(t) to obtain the initialized receiver side signal
predistorted_launch = target_envelope .* exp(1j * 2*pi*rand(size(target_envelope)));


% Transmitter constraint: the pulse has to be real-valued
% Receiver constraint: the ampltiude has be equal to the original pulse,
% the phase is irrelevant
% Ideal case scenario: the input pulse is the inverse of the transfer
% function in frequency domain -> has to be complex-value but it is
% impossible as the input always has to be real-valued -> as such, 100%
% precise approximation is not possible

prev = target_envelope;

rmse_vec = zeros(1,max_iters);

for k = 1:max_iters
    propagated = applyCD(predistorted_launch, system);
    err = rmse(prev, abs(propagated));
    fprintf(1, "Current rmse: %d\n", err);
    rmse_vec(k) = err;
    prev = abs(propagated);
    propagated = target_envelope .* exp(1j * angle(propagated));
    backpropagated = applyCDInverse(propagated, system);
    predistorted_launch = target_envelope .* exp(1j * angle(backpropagated));
end

%Validate that the vector contains non-increasing rmse values
isDecreasing = all(diff(rmse_vec) <= 0);

if isDecreasing
    fprintf(1, "RMSE vector consists of strictly non-increasing values\n");
else
    fprintf(1, "RMSE vector contains increasing values!\n");
end

baseline_out = applyCD(target_launch, system);
predistorted_out = applyCD(predistorted_launch, system);

sq_target = target_envelope.^2;
sq_baseline = abs(baseline_out).^2;
sq_predistorted = abs(predistorted_out).^2;

figure;
plot(system.t_vec, target_envelope); hold on;
plot(system.t_vec, abs(baseline_out));
plot(system.t_vec, abs(predistorted_out));
grid on;
legend('Target envelope', 'After CD (no pred)', ...
    'After CD (GS pred)', 'Location', 'Northeast');
title('Envelope matching after chromatic dispersion');
xlabel('Time (s)');
ylabel('|x(t)|');

figure;
plot(system.t_vec, angle(predistorted_launch));
grid on;
title('Phase applied at transmitter (predistortion)');
xlabel('Time (s)');
ylabel('Phase (rad)');

figure;
plot(system.t_vec, sq_target); hold on;
plot(system.t_vec, sq_baseline);
plot(system.t_vec, sq_predistorted);
grid on;
legend('Target |x(t)|^2', 'After CD + PD (no predistortion)', ...
    'After CD + PD (GS predistortion)', 'Location', 'Northeast');
title('Square-law output comparison (photodiode)');
xlabel('Time (s)');
ylabel('|x(t)|^2');

% Apply lowpass filter to sq_predistorted
% sq_predistorted_filtered = lowpassFilter(sq_predistorted, system.FS, 0.1);

spec = fftshift(fft(sq_target));
N = length(sq_predistorted);
freq = (-N/2:N/2-1) / N * system.FS;
filt = OutputFilter;
filt.areaCovered = 99.9;
sqr_filt = filt.construct(freq, spec);
sq_predistorted_clean = abs(ifft(ifftshift(sqr_filt .* fftshift(fft(sq_predistorted)))));

figure;
plot(system.t_vec, sq_target); hold on;
plot(system.t_vec, sq_baseline);
plot(system.t_vec, sq_predistorted_clean);
grid on;
legend('Target |x(t)|^2', 'After CD + PD (no predistortion)', ...
    'After CD + PD + Noise clean up', 'Location', 'Northeast');
title('Square-law output comparison (photodiode)');
xlabel('Time (s)');
ylabel('|x(t)|^2');



function out = applyCD(signal, system)
    D = 17;
    beta2 = -(system.LAMBDA^2 / (2*pi*system.LIGHT)) * (D * 1e-3);
    N = length(signal);
    omega = (-((N-1)/2):(N/2)) * system.FS/N * 2*pi;
    H = exp(1i * (beta2/2) * omega.^2 * system.CHAN_LEN);
    out = ifft(ifftshift(fftshift(fft(signal)) .* H));
end

function out = applyCDInverse(signal, system)
    D = 17;
    beta2 = -(system.LAMBDA^2 / (2*pi*system.LIGHT)) * (D * 1e-3);
    N = length(signal);
    omega = (-((N-1)/2):(N/2)) * system.FS/N * 2*pi;
    H_inv = exp(-1i * (beta2/2) * omega.^2 * system.CHAN_LEN);
    out = ifft(ifftshift(fftshift(fft(signal)) .* H_inv));
end



% Amplitude only predistortion
% amplitude is not resetted at the transmitter

% Phase only predistortion
% Amplitude is enforced, phase is taken from the component of the for-loop


% Potentially harder to implement in real world 
% Jacobi-Anger expansion

% Convergence properties
% Local minimum
% Stability of the algorithm
% Mean squared error should reduce between iterations
