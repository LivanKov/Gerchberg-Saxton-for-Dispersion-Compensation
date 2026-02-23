L = 20;         
D = 17;            
lambda = 1550e-9;    
c = 3e8;     

beta2 = -(lambda^2 / (2*pi*c)) * (D * 1e-3);
system = System;
fs = 1000e9;   
dt = 1/fs;
t = -200e-12 : dt : 200e-12;
sig = Pulse.Sinc(t/(system.SAMPLING_INTERVAL/2));

N = length(sig);
U0 = fftshift(fft(sig));

% Correct Frequency Vector Construction
df = fs / N;   % Frequency resolution (Hz)
f_hz = (-N/2 : N/2-1) * df; % Frequency axis in Hz (centered)
omega = 2 * pi * f_hz;      % Angular frequency axis (rad/s)

% Now apply the transfer function using omega
H = exp(1i * (beta2/2) * omega.^2 * L);
U_out = U0 .* H;
sig_out = ifft(ifftshift(U_out));

T = system.SAMPLING_INTERVAL;
t_normalized = t / T;

plot(t_normalized, sig); hold on
plot(t_normalized, abs(sig_out));

title("Effects of Chromatic Dispersion on a single SINC Impulse");
xlabel('t/T');
legend("Pulse","Abs()^2 of a pulse affected by CD", 'Location', 'northeast');

grid on;

%% Symbol rate anpassen
%% 30 ghz