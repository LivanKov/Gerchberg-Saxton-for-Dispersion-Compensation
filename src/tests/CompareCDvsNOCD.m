% Compare different channel lengths when affected by chromatic dispersion
s = System;
n_samples = 10000;
s.CHAN_LEN = 5;

[x_1, y_1] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.SINC);
plot(x_1, y_1, '-s');
hold on;

[x_2, y_2] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.SINC, ...
    'enableOpticalChannel', true, 'enableSquareLaw', true);
plot(x_2, y_2, '-s'); hold on;


title('BER/SNR Comparison: Showcasing the effects of Chromatic Dispersion. 30km channel');
ylabel('BER - log10(Pb)');
xlabel('Eb/N0 (dB)');
legend('No CD', 'CD','No CD filter', 'CD filter', 'Location', 'northeast');

