s = System;
[x, y] = s.runBERTest('useLowpassFilter', true, 'pulseShape', Pulse.GAUS);
plot(x, y, '-s');