clc; clear; close all;

L = 50;         
D = 17;            
lambda = 1000e-9;    
c = 3e8;     

beta2 = -(lambda^2 / (2*pi*c)) * (D * 1e-3);

T0 = 5 * 10e-12; 
fs = 1000e9;   
dt = 1/fs;
t = -200e-12 : dt : 200e-12;
sig = Pulse.CosSqr(t/T0, 1, 1) + Pulse.CosSqr((t-T0)/T0, 1, 1);

N = length(sig);
U0 = fftshift(fft(sig));
% conver to radian/angular freq
f = (-((N-1)/2):(N/2)) * fs/N * 2*pi;

H = exp(1i * (beta2/2) * f.^2 * L); 
U_out = U0 .* H;

sig_out = ifft(ifftshift(U_out));

figure;
plot(t*1e12, abs(sig), 'blue'); hold on;
plot(t*1e12, abs(sig_out), 'red');
grid on;