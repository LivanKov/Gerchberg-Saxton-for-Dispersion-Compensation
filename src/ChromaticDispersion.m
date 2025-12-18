% Phase Spectrum of Centered vs Shifted Sinc Pulses
% Demonstrates zero phase, linear phase, and quadratic phase

clear; close all; clc;

%% Time and Frequency Setup
T = 10e-9;                    % Time window (10 ns)
fs = 100e9;                   % Sampling frequency (100 GHz)
dt = 1/fs;
N = 2^16;                     % Number of samples (power of 2 for FFT)
t = (0:N-1)*dt - T/2;         % Time vector (centered)

% Frequency vector
df = fs/N;
f = (-N/2:N/2-1)*df;

%% Generate Sinc Pulses
% Parameters
pulse_width = 100e-12;        % 100 ps pulse width
time_shift = 500e-12;         % 500 ps shift

% 1. Centered sinc pulse (even function)
sinc_centered = sinc(t / pulse_width);

% 2. Time-shifted sinc pulse
sinc_shifted = sinc((t - time_shift) / pulse_width);

% 3. For comparison: pulse with chromatic dispersion (quadratic phase)
% Apply dispersion to centered pulse
lambda = 1550e-9;
c = 3e8;
D = 17e-12;
fiber_length = 40e3;          % 40 km
beta2 = -(lambda^2 * D) / (2*pi*c);

omega = 2*pi*f;
H_dispersion = exp(-1j * beta2/2 * omega.^2 * fiber_length);
Sinc_dispersed_fft = fftshift(fft(sinc_centered)) .* H_dispersion;
sinc_dispersed = ifft(ifftshift(Sinc_dispersed_fft));

%% Compute Fourier Transforms
Sinc_centered_fft = fftshift(fft(sinc_centered));
Sinc_shifted_fft = fftshift(fft(sinc_shifted));

% Magnitude and phase
mag_centered = abs(Sinc_centered_fft);
phase_centered = angle(Sinc_centered_fft);

mag_shifted = abs(Sinc_shifted_fft);
phase_shifted = angle(Sinc_shifted_fft);

mag_dispersed = abs(Sinc_dispersed_fft);
phase_dispersed = angle(Sinc_dispersed_fft);

% Unwrap phase for better visualization
phase_centered_unwrap = unwrap(phase_centered);
phase_shifted_unwrap = unwrap(phase_shifted);
phase_dispersed_unwrap = unwrap(phase_dispersed);

% Theoretical linear phase for shifted pulse
phase_linear_theory = -2*pi*f*time_shift;

%% Plotting
figure('Position', [50 50 1400 900]);

% Frequency range for plotting (limit to relevant bandwidth)
f_GHz = f * 1e-9;
f_plot_range = abs(f_GHz) < 50;  % Plot ±50 GHz

%=== ROW 1: Time Domain Signals ===%
subplot(3,3,1)
t_ps = t * 1e12;
plot(t_ps, sinc_centered, 'b', 'LineWidth', 2)
xlabel('Time (ps)')
ylabel('Amplitude')
title('Centered Sinc: sinc(t)')
grid on
xlim([-1000 1000])

subplot(3,3,2)
plot(t_ps, sinc_shifted, 'r', 'LineWidth', 2)
xlabel('Time (ps)')
ylabel('Amplitude')
title(sprintf('Shifted Sinc: sinc(t - %.0f ps)', time_shift*1e12))
grid on
xlim([-1000 1500])

subplot(3,3,3)
plot(t_ps, real(sinc_dispersed), 'Color', [0.8 0.5 0], 'LineWidth', 2)
xlabel('Time (ps)')
ylabel('Amplitude')
title('After Chromatic Dispersion')
grid on
xlim([-1000 1000])

%=== ROW 2: Magnitude Spectrum ===%
subplot(3,3,4)
plot(f_GHz(f_plot_range), mag_centered(f_plot_range), 'b', 'LineWidth', 2)
xlabel('Frequency (GHz)')
ylabel('|X(f)|')
title('Magnitude Spectrum - Centered')
grid on

subplot(3,3,5)
plot(f_GHz(f_plot_range), mag_shifted(f_plot_range), 'r', 'LineWidth', 2)
xlabel('Frequency (GHz)')
ylabel('|X(f)|')
title('Magnitude Spectrum - Shifted')
grid on

subplot(3,3,6)
plot(f_GHz(f_plot_range), mag_dispersed(f_plot_range), ...
     'Color', [0.8 0.5 0], 'LineWidth', 2)
xlabel('Frequency (GHz)')
ylabel('|X(f)|')
title('Magnitude Spectrum - Dispersed')
grid on

%=== ROW 3: Phase Spectrum ===%
subplot(3,3,7)
plot(f_GHz(f_plot_range), phase_centered(f_plot_range), 'b.', 'MarkerSize', 4)
xlabel('Frequency (GHz)')
ylabel('Phase (rad)')
title('Phase Spectrum - Centered (≈ 0)')
grid on
ylim([-pi pi])
%% Additional figure: Direct phase comparison
%{
figure('Position', [100 100 1000 400]);

subplot(1,2,1)
hold on
plot(f_GHz(f_plot_range), phase_centered(f_plot_range), 'b.', ...
     'MarkerSize', 6, 'DisplayName', 'Centered (Zero Phase)')
plot(f_GHz(f_plot_range), phase_shifted_unwrap(f_plot_range)/max(abs(phase_shifted_unwrap(f_plot_range)))*pi, 'r', ...
     'LineWidth', 2, 'DisplayName', 'Shifted (Linear Phase)')
plot(f_GHz(f_plot_range), phase_dispersed_unwrap(f_plot_range)/max(abs(phase_dispersed_unwrap(f_plot_range)))*pi, ...
     'Color', [0.8 0.5 0], 'LineWidth', 2, 'DisplayName', 'Dispersed (Quadratic Phase)')
xlabel('Frequency (GHz)', 'FontSize', 11)
ylabel('Normalized Phase', 'FontSize', 11)
title('Phase Spectrum Comparison', 'FontSize', 12, 'FontWeight', 'bold')
legend('Location', 'best')
grid on
hold off

subplot(1,2,2)
% Show phase shapes more clearly
f_norm = f / max(abs(f));
phase_zero = zeros(size(f_norm));
phase_linear = -f_norm;
phase_quadratic = -f_norm.^2;

hold on
plot(f_norm(f_plot_range), phase_zero(f_plot_range), 'b', ...
     'LineWidth', 3, 'DisplayName', 'Zero Phase: φ = 0')
plot(f_norm(f_plot_range), phase_linear(f_plot_range), 'r', ...
     'LineWidth', 3, 'DisplayName', 'Linear Phase: φ ∝ f')
plot(f_norm(f_plot_range), phase_quadratic(f_plot_range), ...
     'Color', [0.8 0.5 0], 'LineWidth', 3, 'DisplayName', 'Quadratic Phase: φ ∝ f²')
xlabel('Normalized Frequency', 'FontSize', 11)
ylabel('Phase Shape', 'FontSize', 11)
title('Theoretical Phase Shapes', 'FontSize', 12, 'FontWeight', 'bold')
legend('Location', 'best')
grid on
hold off
%}