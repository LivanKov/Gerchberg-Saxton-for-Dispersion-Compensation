% Simple Gerchberg-Saxton: Two-Tone Interference
clear; clc; close all;

%% 1. The Signal (The Sum of Two Complex Sinusoids)
N = 100;
t = (0:N-1);

% We combine two frequencies:
% Tone 1: Constant phase
% Tone 2: Shifted by 90 degrees (pi/2)
% The "Interaction" between these two creates a specific beat pattern.
true_phase_shift = pi/2; 
ground_truth = exp(1j * 0.1 * t) + 0.8 * exp(1j * (0.3 * t + true_phase_shift));

% These are the only two things we are allowed to know:
measured_envelope = abs(ground_truth);    % The "Beat" pattern (Time Mag)
measured_spectrum = abs(fft(ground_truth)); % The Frequency Spikes (Freq Mag)

%% 2. The Algorithm (GS Loop)
% Start with a random guess (Random Phase)
% We keep the correct Envelope, but scramble the phase.
guess_signal = measured_envelope .* exp(1j * 2*pi*rand(1, N));

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

%% 4. Visual Plot
figure;
subplot(2,1,1);
plot(t, measured_envelope);

subplot(2,1,2);
plot(angle(ground_truth)); hold on;
plot(angle(guess_signal));
legend('True Phase Pattern', 'Recovered Phase Pattern');
title('Phase Comparison');
xlabel('Time'); ylabel('Phase (rad)');