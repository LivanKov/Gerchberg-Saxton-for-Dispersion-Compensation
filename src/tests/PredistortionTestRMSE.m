system = System;
system.pulseShape = Pulse.SINC;
system.CHAN_LEN = 30;
system.ingest('10101010001010101');
system.shapeInput();

target_envelope = abs(system.currentVals);

sq_target = target_envelope.^2;
system.applyChromaticDispersion();
sq_baseline = abs(system.currentVals).^2;
system.resetCD();
% predistort using basic GS
ModifiedGS(system, 'mode', 1, 'convergenceMode', 0, 'iterations', 150,  'plotRMSE', true);
system.applyChromaticDispersion();
sq_predistorted = abs(system.currentVals).^2;

figure;
plot(system.t_vec, sq_target); hold on;
plot(system.t_vec, sq_baseline);
plot(system.t_vec, sq_predistorted);
grid on;
legend('Target |x(t)|^2', 'After CD + PD (no predistortion)', ...
    'After CD + PD (GS predistortion)', 'Location', 'Northeast');
title('Square-law output comparison (photodiode) (Pre-Implemented)');
xlabel('Time (s)');
ylabel('|x(t)|^2');


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
title('Square-law output comparison (photodiode) (Pre-Implemented) (Filtered)');
xlabel('Time (s)');
ylabel('|x(t)|^2');
