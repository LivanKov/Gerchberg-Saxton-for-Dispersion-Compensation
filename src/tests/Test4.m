s = System;
s.ingest('111001');
s.updatePulse(Pulse.SINC);
s.outputFilter.areaCovered = 99;
s.shapeInput();
s.plot();
spec = fft(s.currentVals);
figure;
plot(abs(spec));



