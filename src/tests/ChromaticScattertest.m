s = System;
s.generateRandomInput(5000);
s.pulseShape = Pulse.SINC;
s.shapeInput();

% With chromatic dispersion enabled
figure;
s.applyChromaticDispersion();
s.applySquareLaw();
s.scatterPlot(); grid on;
title("Scatter plot. Chromatic Dispersion (20km channel). 10000 Samples. Square-Law-Detection enabled");
s.resetCD();

figure;
ModifiedGS(s, 0, 1, 500);
s.applyChromaticDispersion();
s.applySquareLaw();
s.scatterPlot(); grid on;
title("Scatter plot. Chromatic Dispersion (20km channel) + GS Predistortion. 10000 Samples. Square-Law-Detection enabled");
s.resetCD();