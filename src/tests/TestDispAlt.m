clc; clear; close all;

L = 20;         
D = 17;            
lambda = 1550e-9;    
c = 3e8;     

beta2 = -(lambda^2 / (2*pi*c)) * (D * 1e-3);

T0 = 5*10e-12; 
fs = 1000e9;   
dt = 1/fs;
t = -200e-12 : dt : 200e-12;
sig = Pulse.CosSqr(t, 1, T0);

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

figure;
plot(t*1e12, abs(sig), 'blue'); hold on;
plot(t*1e12, abs(sig_out), 'red');
grid on;