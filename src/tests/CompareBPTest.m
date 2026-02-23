% Compare how different lowpass filter area percentages affect BER performance
s = System;
n_samples = 20000;
clc; 
close all;

[x_1, y_1] = s.runBERTest('useLowpassFilter', true, 'length', n_samples, 'lowpassPercentage', 50, 'pulseShape', Pulse.COS_SQR);
plot(x_1, y_1, '-s');
hold on;
[x_2, y_2] = s.runBERTest('useLowpassFilter', true, 'length', n_samples, 'lowpassPercentage', 70, 'pulseShape', Pulse.COS_SQR);
plot(x_2, y_2, '-s');
hold on;
[x_3, y_3] = s.runBERTest('useLowpassFilter', true, 'length', n_samples, 'lowpassPercentage', 80, 'pulseShape', Pulse.COS_SQR);
plot(x_3, y_3, '-s');
hold on;
[x_4, y_4] = s.runBERTest('useLowpassFilter', true, 'length', n_samples, 'lowpassPercentage', 90, 'pulseShape', Pulse.COS_SQR);
plot(x_4, y_4, '-s');
hold on;
[x_5, y_5] = s.runBERTest('useLowpassFilter', true, 'length', n_samples, 'lowpassPercentage', 95, 'pulseShape', Pulse.COS_SQR);
plot(x_5, y_5, '-s');
hold on;
[x_6, y_6] = s.runBERTest('useLowpassFilter', true, 'length', n_samples, 'lowpassPercentage', 99, 'pulseShape', Pulse.COS_SQR);
plot(x_6, y_6, '-s');
hold on;

title('BER/SNR Comparison: Effect of Lowpass Filter Area Coverage');
ylabel('BER - log10(Pb)');
xlabel('Eb/N0 (dB)');
legend('50%', '70%', '80%', '90%', '95%', '99%', 'Location', 'northeast');