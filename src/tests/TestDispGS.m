%% Initialize a signal affected by chromatic dispersion
clc; close all; clear all;
system = System;

figure;
system.pulseShape = Pulse.SINC;
system.ingest('1');
system.CHAN_LEN = 20;
system.shapeInput();
plot(system.t_vec, system.currentVals);grid on;
title("Initial pulse");
[ab, comp] = system.applyChromaticDispersion();
plot(system.t_vec, ab); hold on;
plot(system.t_vec, comp); grid on;
title('Pulse affected by chromatic dispersion');
legend("Absolute", "Real + Complex", "Location", "Northeast");
figure;
plot(angle(comp)); grid on;
title('Chromatic dispersion phase');
measured_envelope = abs(comp);
measured_spectrum = abs(fft(comp));
guess_signal = measured_envelope .* exp(1j * 2*pi*rand(size(measured_envelope)));

for k = 1:100
    F = fft(guess_signal);
    F = measured_spectrum .* exp(1j * angle(F));
    guess_signal = ifft(F);
    guess_signal = measured_envelope .* exp(1j * angle(guess_signal));
end

figure;
plot(angle(guess_signal)); grid on;
title('Recovered signal phase');
figure;
plot(system.t_vec, abs(guess_signal)); hold on;
plot(system.t_vec, guess_signal); grid on;
legend("Absolute", "Real + Complex", "Location", "Northeast");
title('Total recovered pulse');