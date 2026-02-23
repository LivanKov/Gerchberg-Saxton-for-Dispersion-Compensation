% Compare different channel lengths when affected by chromatic dispersion
s = System;
n_samples = 10000;
s.CHAN_LEN = 10;

[x_1, y_1] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.COS_SQR);
plot(x_1, y_1, '-s');
hold on;

[x_2, y_2] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.COS_SQR, 'enableOpticalChannel', true);
plot(x_2, y_2, '-s'); hold on;

[x, y] = s.runBERTest('useLowpassFilter', true, 'pulseShape', Pulse.COS_SQR, 'length', n_samples);
plot(x, y, '-s');
hold on;
[x_f, y_f] = s.runBERTest('useLowpassFilter', true, 'pulseShape', Pulse.COS_SQR, 'length', n_samples, 'enableOpticalChannel', true);
plot(x_f, y_f, '-s');


title('BER/SNR Comparison: Showcasing the effects of Chromatic Dispersion. No lowpass filter used');
ylabel('BER - log10(Pb)');
xlabel('Eb/N0 (dB)');
legend('No CD', 'CD','No CD filter', 'CD filter', 'Location', 'northeast');

