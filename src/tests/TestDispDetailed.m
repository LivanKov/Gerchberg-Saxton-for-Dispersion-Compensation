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
H = exp(1i * (beta2/2) * omega.^2 * system.CHAN_LEN);
U_out = U0 .* H;
sig_out = ifft(ifftshift(U_out));

figure;
plot(t*1e12, sig); hold on;
plot(t*1e12, abs(sig_out));
grid on;


figure;
s.pulseShape = Pulse.SINC;
s.ingest('1');
s.shapeInput();
s.plot(); hold on;
s.applyChromaticDispersion();
s.plot();
grid on;


