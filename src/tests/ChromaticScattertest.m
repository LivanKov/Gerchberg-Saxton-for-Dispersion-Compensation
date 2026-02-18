s = System;
s.generateRandomInput(1000);
s.pulseShape = Pulse.SINC;
s.shapeInput();
s.CHAN_LEN = 30;

% With chromatic dispersion enabled
figure;
s.applyChromaticDispersion();
s.applySquareLaw();
s.scatterPlot(); grid on;
title("Scatter plot. Chromatic Dispersion (30km channel). 10000 Samples. Square-Law-Detection enabled");
s.resetCD();

figure;
ModifiedGS(s, 0, 1, 2000);
s.applyChromaticDispersion();
s.applySquareLaw();
s.scatterPlot(); grid on;
title("Scatter plot. Chromatic Dispersion (30km channel) + GS Predistortion. 10000 Samples. Square-Law-Detection enabled");
s.resetCD();