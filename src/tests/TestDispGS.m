%% Initialize a signal affected by chromatic dispersion

figure;
system.pulseShape = Pulse.SINC;
system.ingest('1');
system.CHAN_LEN = 4;
system.shapeInput();
[ab, comp] = system.applyChromaticDispersion();
plot(system.t_vec, ab); hold on;
plot(system.t_vec, comp); grid on;
figure;
plot(angle(comp)); grid on;
measured_envelope = abs(comp);    % The "Beat" pattern (Time Mag)
measured_spectrum = abs(fft(comp));
guess_signal = measured_envelope .* exp(1j * 2*pi*rand(size(measured_envelope)));

for k = 1:50
    % A. Go to Frequency Domain
    F = fft(guess_signal);
    
    % B. Enforce Frequency Magnitude (Keep calculated phase, use KNOWN Mag)
    F = measured_spectrum .* exp(1j * angle(F));
    
    % C. Go back to Time Domain
    guess_signal = ifft(F);
    
    % D. Enforce Time Envelope (Keep calculated phase, use KNOWN Envelope)
    guess_signal = measured_envelope .* exp(1j * angle(guess_signal));
end