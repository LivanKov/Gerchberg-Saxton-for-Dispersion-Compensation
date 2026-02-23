clc; close all;

system = System;
system.pulseShape = Pulse.RCOS;
system.CHAN_LEN = 20;
system.generateRandomInput(5000);
system.shapeInput();

target_envelope = abs(system.currentVals);

sq_target = target_envelope.^2;
system.applyChromaticDispersion();
sq_baseline = abs(system.currentVals).^2;
system.resetCD();
% predistort using basic GS
ModifiedGS(system, 'mode', 0, 'convergenceMode', 1, 'iterations', 150);
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

figure;
system.applySquareLaw();
system.scatterPlot();
system.resetCD();

system.applyChromaticDispersion();
system.applySquareLaw();
figure;
system.scatterPlot();