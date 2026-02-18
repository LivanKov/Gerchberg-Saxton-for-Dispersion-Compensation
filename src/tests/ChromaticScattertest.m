s = System;
num_samples = 10000;
s.generateRandomInput(num_samples);
s.pulseShape = Pulse.SINC;
s.shapeInput();
s.CHAN_LEN = 30;

% With chromatic dispersion enabled
figure;
s.applyChromaticDispersion();
s.applySquareLaw();
s.scatterPlot(); grid on;
title("Scatter plot. Chromatic Dispersion ("+ s.CHAN_LEN+ "km channel). " + num_samples + "Samples. Square-Law-Detection enabled");
s.resetCD();

mode = 0;

if mode == 1
    label = "Phase-only";
else
    label = "Amplitude only";
end

figure;
ModifiedGS(s, mode, 1, 400, 1);
s.applyChromaticDispersion();
s.applySquareLaw();
s.scatterPlot(); grid on;
title("Scatter plot. Chromatic Dispersion (" + s.CHAN_LEN + "km channel) + GS Predistortion. " + label +". " + num_samples + " Samples. Square-Law-Detection enabled");
s.resetCD();