D = 17;                

system = System;

beta2 = -(system.LAMBDA^2 / (2*pi*system.LIGHT)) * (D * 1e-3);

fs = 3000e9;   
dt = 1/fs;
t = -system.SAMP_TIME:dt:system.SAMP_TIME;
sig = Pulse.Sinc(t/(system.SAMPLING_INTERVAL/2));

N = length(sig);
U0 = fftshift(fft(sig));

% Correct Frequency Vector Construction
df = fs / N;   % Frequency resolution (Hz)
f_hz = (-N/2 : N/2-1) * df; % Frequency axis in Hz (centered)
omega = 2 * pi * f_hz;      % Angular frequency axis (rad/s)

% Now apply the transfer function using omega
H = exp(1i * (beta2/2) * omega.^2 * 4);
U_out = U0 .* H;
sig_out = ifft(ifftshift(U_out));

figure;
plot(t, sig); hold on;
plot(t, abs(sig_out)); hold on;
plot(t, sig_out);
grid on;

system.CHAN_LEN = 4;
figure;
system.pulseShape = Pulse.SINC;
system.ingest('1');
system.shapeInput();
system.plot(); hold on;
[ab, comp] = system.applyChromaticDispersion();
plot(system.t_vec, ab); hold on;
plot(system.t_vec, comp); hold on;
grid on;


