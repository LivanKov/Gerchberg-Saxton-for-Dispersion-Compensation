% Compare the BER in system without a lowpass filter with a system with
% lowpass in place
s = System;
[x, y] = s.runBERTest('useLowpassFilter', false, 'pulseShape', Pulse.GAUS);
plot(x, y, '-s');
hold on;
[x_f, y_f] = s.runBERTest('useLowpassFilter', true, 'pulseShape', Pulse.GAUS);
plot(x_f, y_f, '-s');
title('BER/SNR Comparison: No filter vs filter enabled. SINC Impulse over 400000 samples');
ylabel('BER - log10(Pb)');
xlabel('Eb/N0 (dB)');
legend('No Filter', '90% Lowpass Filter', 'Location', 'northeast');

