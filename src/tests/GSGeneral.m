L = 20;         
D = 17;            
lambda = 1550e-9;    
c = 3e8;     

beta2 = -(lambda^2 / (2*pi*c)) * (D * 1e-3);
system = System;
fs = 1000e9;   
dt = 1/fs;
t = -200e-12 : dt : 200e-12;
sig = Pulse.Sinc(t/(system.SAMPLING_INTERVAL*2));

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

plot(t, sig); hold on;
plot(t, sig_out); hold on;
plot(t, abs(sig_out));


A = fftshift(ifft2(fftshift(Target)));
for i=1:25
  B = abs(Source) .* exp(1i*angle(A));
  C = fftshift(fft(fftshift(B)));
  D = abs(Target) .* exp(1i*angle(C));
  A = fftshift(ifft(fftshift(D)));

    plot(abs(C)) %Present current pattern
    title(sprintf('%d',i));
    pause(0.5)
end