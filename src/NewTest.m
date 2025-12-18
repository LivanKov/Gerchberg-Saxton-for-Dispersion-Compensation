clear all; close all; clc;

t = -10:0.01:10; 

% 1. Create Sinc
s = sinc(10*t);

% 2. Shift to move Peak to Index 1 (Crucial for 0 phase!)
s_fft = ifftshift(s);

% 3. FFT and shift back for plotting
spec = fftshift(fft(s_fft));

% --- THE FIX FOR THE SPIKES ---
magnitude = abs(spec);
phase = angle(spec);

% Define a small threshold (noise floor)
threshold = max(magnitude) * 1e-4; 

% Force phase to 0 where magnitude is negligible
phase(magnitude < threshold) = 0; 
% ------------------------------

subplot(2,1,1);
plot(magnitude); 
title('Magnitude (The Rect)');
grid on;

subplot(2,1,2);
plot(phase); 
title('Phase (Cleaned with Threshold)');
ylim([-1 1]);
grid on;