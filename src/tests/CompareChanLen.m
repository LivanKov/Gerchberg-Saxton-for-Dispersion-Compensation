% Compare a channel affectd by CD to a clean channel
s = System;
n_samples = 10000;
s.CHAN_LEN = 50;

[x_1, y_1] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.SINC, 'enableOpticalChannel', true);
plot(x_1, y_1, '-s');
hold on;

s.CHAN_LEN = 40;

[x_2, y_2] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.SINC, 'enableOpticalChannel', true);
plot(x_2, y_2, '-s');

s.CHAN_LEN = 30;

[x_3, y_3] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.SINC, 'enableOpticalChannel', true);
plot(x_3, y_3, '-s');

s.CHAN_LEN = 20;

[x_4, y_4] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.SINC, 'enableOpticalChannel', true);
plot(x_4, y_4, '-s');

s.CHAN_LEN = 10;

[x_5, y_5] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.SINC, 'enableOpticalChannel', true);
plot(x_5, y_5, '-s');

title('BER/SNR Comparison: Showcasing the effects of Chromatic Dispersion on various channel lengths.');
ylabel('BER - log10(Pb)');
xlabel('Eb/N0 (dB)');
legend('50km', '40km', '30km', '20km', '10km', 'Location', 'northeast');