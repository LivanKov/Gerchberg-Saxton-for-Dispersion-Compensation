% Compare different channel lengths when affected by chromatic dispersion
clc; close all;
s = System;
n_samples = 10000;
s.CHAN_LEN = 20;

[x_1, y_1] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.SINC);
plot(x_1, y_1, '-s');
hold on;

[x_2, y_2] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.SINC, ...
    'enableOpticalChannel', true, 'applySquareLaw', true, 'applyPredistortion', true);
plot(x_2, y_2, '-s'); hold on;


[x_3, y_3] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.SINC, ...
    'enableOpticalChannel', true, 'applySquareLaw', true);
plot(x_3, y_3, '-s'); hold on;


title('BER/SNR Comparison: Showcasing the effects of Chromatic Dispersion. 20km channel. Amplitude-Only-Predistortion');
ylabel('BER - log10(Pb)');
xlabel('Eb/N0 (dB)');
legend('No CD', 'CD + GS predistortion', 'CD + no predistortion', 'Location', 'northeast');
