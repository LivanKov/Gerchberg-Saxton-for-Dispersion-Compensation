s = System;
s.ingest('1010101010100001');
disp("Input Sequence");
disp(s.input.stream);
s.pulseShape = Pulse.SINC;
s.shapeInput;
pulse = s.currentVals;
t = s.t_vec;
disp(length(s.t_vec));
disp(length(s.currentVals));

spec = fft(pulse);
N = length(pulse);
fs = System.FS;
f = (-N/2:N/2-1) * (fs/N);

subplot(4,1,1);
plot(abs(spec));
xlabel('Frequency (Hz)'); ylabel('|FFT|');
title('Magnitude Spectrum');
grid on;
xlim([-20 20]);  % Zoom in to see sinc structure


subplot(4,1,2);
plot(t, pulse);
grid on;
title('Time Domain');
grid on;
xlabel('Time (t)'); ylabel('x(t)');

f_pos_ids = f >= 0;
abs_spec = abs(spec);
f_pos = f(f_pos_ids);
spec_pos = abs_spec(f_pos_ids);

subplot(4,1,3);
plot(f_pos, spec_pos);
grid on;
title('Magnitude Spectrum');
xlabel('Frequency (Hz)'); ylabel('|FFT|');

% Inverse Fourier-Transform
subplot(4,1,4);

x_new = ifft(ifftshift(spec));

plot(x_new);
title("Time Domain (Reconstructed via IFFT)");
xlabel('Time (t)'); ylabel('x(t)');
grid on;

% 90% esd filter

%{
esd = abs(spec_pos) .^ 2;
figure;
subplot(4,1,1);
plot(f_pos, esd);
xlim([0 10]);

int = cumtrapz(f_pos, esd);
%}

subplot(4,1,2);
% plot(int);
xlim([0 10]);



s.outputFilter.areaCovered = 90;
square_filter = s.outputFilter.construct(f, spec);

square_filter_2 = s.outputFilter.construct(f, spec);

subplot(4, 1, 3);
plot(f_pos, square_filter(f_pos_ids));
xlim([0 20]);

subplot(4, 1, 4);
plot(f, square_filter);
xlim([-10 10]);


figure;

% Noise panel 
s.addNoise(100);
% Durch das hinzufügen des Rauschens verändert sich der Filter -> darf
pulse_noise = s.currentVals;
subplot(4, 1, 1);
plot(t, pulse_noise);
title('Time Domain (Noisy)');
xlabel('Time (t)'); ylabel('x(t)');
grid on;

spec_noisy_new = fft(pulse_noise);

subplot(4, 1, 2);
plot(abs(spec_noisy_new));
xlabel('Frequency (Hz)'); ylabel('|FFT|');
title('Magnitude Spectrum (Noisy)');
grid on;
xlim([-20 20]);

filtered = square_filter .* spec_noisy_new;
% s.applyOutputFilter();

subplot(4, 1, 3);
plot(f, abs(filtered));
xlabel('Frequency (Hz)'); ylabel('|FFT|');
title('Magnitude Spectrum (Filtered)');
grid on;
xlim([-20 20]);


% Inverse Fourier Transform of the Filtered Magnitude spectrum
subplot(4,1,4);
x_new_alpha = ifft(ifftshift(filtered));
plot(abs(x_new_alpha));
title("Filtered Time Domain (Reconstructed via IFFT)");
xlabel('Time (t)'); ylabel('x(t)');
grid on;


% Faltung vom Rauschen und Filter berechnen
% Falls die Leistung sehr klein im vergleich zu der Faltung vom Nutzsignal
% von dem Nutzsignal und dem Filter -> richtig
% Oversampling factor charakterisiert das Nachrichtensystem

