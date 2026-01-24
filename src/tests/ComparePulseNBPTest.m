% Compare different pulse shapes in regards to their BER
s = System;
s.alpha = 0.5;
n_samples = 100000;

[x_1, y_1] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.SINC);
plot(x, y, '-s');
hold on;
[x_2, y_2] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.COS_SQR);
plot(x_2, y_2, '-s');
hold on;
[x_3, y_3] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.RECT);
plot(x_3, y_3, '-s');
hold on;
[x_4, y_4] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.GAUS);
plot(x_4, y_4, '-s');
hold on;
[x_5, y_5] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.RRCOS);
plot(x_5, y_5, '-s');
hold on;

title('BER/SNR Comparison: Comparing different pulse shapes without a filter');
ylabel('BER - log10(Pb)');
xlabel('Eb/N0 (dB)');
legend('Sinc', 'Cos^2', 'Rectangle','Gaus', 'Root-raised-Cosine', 'Location', 'northeast');
