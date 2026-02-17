system = System;
system.pulseShape = Pulse.SINC;
system.CHAN_LEN = 30;
system.generateRandomInput(1000);
system.shapeInput();

target_launch = system.currentVals;
target_envelope = abs(target_launch);

max_iters = 500;

% Receiver-side initialization:
% A(t) with arbitrary phase.
receiver_side = target_envelope .* exp(1j * 2*pi*rand(size(target_envelope)));


% Inverse-CD-first GS loop:
% 1) receiver -> transmitter using ICDTF
% 2) transmitter constraint: keep amplitude B(t), set phase to 0
% 3) transmitter -> receiver using CDTF
% 4) receiver constraint: enforce target amplitude A(t), keep phase
prev = target_envelope;

rmse_vec = zeros(1,max_iters);

err = inf;

for k = 1:max_iters
    backpropagated = applyCDInverse(receiver_side, system);
    backpropagated = abs(backpropagated) .* exp(1j * 0);
    propagated = applyCD(backpropagated, system);
    receiver_side = target_envelope .* exp(1j * angle(propagated));
    err = rmse(prev, abs(backpropagated));
    fprintf(1, "Current rmse: %d\n", err);
    rmse_vec(k) = err;
    prev = abs(backpropagated);
end

%Validate that the vector contains non-increasing rmse values
isDecreasing = all(diff(rmse_vec) <= 0);


% rmse limited approach



if isDecreasing
    fprintf(1, "RMSE vector consists of strictly non-increasing values\n");
else
    fprintf(1, "RMSE vector contains increasing values!\n");
end

baseline_out = applyCD(target_launch, system);
predistorted_out = applyCD(abs(backpropagated), system);

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
plot(system.t_vec, sq_target); hold on;
plot(system.t_vec, sq_baseline);
plot(system.t_vec, sq_predistorted);
grid on;
legend('Target |x(t)|^2', 'After CD + PD (no predistortion)', ...
    'After CD + PD (GS predistortion)', 'Location', 'Northeast');
title('Square-law output comparison (photodiode)');
xlabel('Time (s)');
ylabel('|x(t)|^2');


figure;
scatter(system.t_vec(system.sample_indices), sq_baseline(system.sample_indices));
title("Baseline");
figure;
scatter(system.t_vec(system.sample_indices), sq_predistorted(system.sample_indices));
title("Predistorted");

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
