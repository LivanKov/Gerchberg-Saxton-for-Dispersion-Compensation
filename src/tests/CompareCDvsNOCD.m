% Compare different pulse shapes in regards to their BER within a system
% that utilizes a lowpass filter
s = System;
n_samples = 100000;

[x_1, y_1] = s.runBERTest('useLowpassFilter', false, 'length', n_samples, 'pulseShape', Pulse.SINC);
plot(x, y, '-s');