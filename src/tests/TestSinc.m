% Sinc Function and its Fourier Transform
% Demonstrates that the Fourier Transform of a sinc is a rectangle

clear all; close all; clc;

% Time domain parameters
T = 0.5;              % Time span
fs = 1000;           % Sampling frequency
dt = 1/fs;           % Time step
t = -T/2:dt:T/2;     % Time vector

f_cutoff = 5;        % Cutoff frequency for the sinc
sinc_wave = sinc(2*f_cutoff*t);


N = length(t);
freq = (-N/2:N/2-1)*(fs/N);  % Frequency vector (centered)
sinc_fft = fftshift(fft(sinc_wave))*dt;  % Centered FFT with proper scaling


figure;

subplot(1,2,1);
plot(t, sinc_wave);
subplot(1,2,2);
plot(freq, abs(sinc_fft));
xlim([-20 20]);
