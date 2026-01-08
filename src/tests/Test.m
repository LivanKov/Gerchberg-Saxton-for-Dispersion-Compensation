% Eye Diagram Construction for Sinc Pulse
% This script generates an eye diagram showing the received signal quality
% for a baseband digital transmission using sinc pulse shaping

clear all; close all; clc;

%% Parameters
T = 1;                    % Symbol period
fs = 100;                 % Sampling frequency (samples per symbol)
dt = T/fs;                % Sampling interval
num_symbols = 100;        % Number of data symbols
span = 6;                 % Sinc pulse span in symbols

%% Generate random binary data
data = randi([0 1], num_symbols, 1);
data_bipolar = 2*data - 1;  % Convert to bipolar (-1, +1)

%% Create sinc pulse (ideal Nyquist pulse)
t_pulse = -span*T:dt:span*T;
sinc_pulse = sinc(t_pulse/T);  % sinc(t/T) = sin(pi*t/T)/(pi*t/T)

%% Upsample data and convolve with pulse
data_upsampled = zeros(num_symbols*fs, 1);
data_upsampled(1:fs:end) = data_bipolar;

% Filter with sinc pulse
tx_signal = conv(data_upsampled, sinc_pulse, 'same');

%% Add noise (optional - adjust SNR as needed)
SNR_dB = 5000;  % Signal-to-Noise Ratio in dB
tx_signal_noisy = awgn(tx_signal, SNR_dB, 'measured');

%% Construct Eye Diagram
eye_period = 2*T;  % Two symbol periods for eye diagram
samples_per_eye = 2*fs;  % Samples in eye period

% Discard initial and final transients
skip_symbols = span + 5;
start_idx = skip_symbols * fs;
end_idx = length(tx_signal_noisy) - skip_symbols * fs;
signal_segment = tx_signal_noisy(start_idx:end_idx);

% Reshape signal into eye diagram traces
num_traces = floor(length(signal_segment) / samples_per_eye);
eye_data = reshape(signal_segment(1:num_traces*samples_per_eye), ...
                   samples_per_eye, num_traces);

%% Plot Eye Diagram
figure('Position', [100 100 800 600]);
t_eye = (0:samples_per_eye-1) * dt;

% Plot all traces
plot(t_eye, eye_data, 'b', 'LineWidth', 0.5);
hold on;
plot([T T], ylim, 'r--', 'LineWidth', 2);  % Optimal sampling point
grid on;

xlabel('Time (Symbol Periods)', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
title(sprintf('Eye Diagram - Sinc Pulse (SNR = %d dB)', SNR_dB), ...
      'FontSize', 14, 'FontWeight', 'bold');
xlim([0 eye_period]);

% Add annotations
text(T, max(ylim)*0.9, 'Optimal Sampling Point', ...
     'Color', 'r', 'FontSize', 10, 'HorizontalAlignment', 'center');

%% Plot original sinc pulse for reference
figure('Position', [920 100 800 600]);
subplot(2,1,1);
plot(t_pulse, sinc_pulse, 'LineWidth', 2);
grid on;
xlabel('Time (Symbol Periods)', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
title('Sinc Pulse Shape', 'FontSize', 14, 'FontWeight', 'bold');
xlim([-span*T, span*T]);

% Plot frequency response
subplot(2,1,2);
N = 2048;
H = fft(sinc_pulse, N);
f = (-N/2:N/2-1)/(N*dt);
plot(f, fftshift(abs(H)), 'LineWidth', 2);
grid on;
xlabel('Frequency (Hz)', 'FontSize', 12);
ylabel('Magnitude', 'FontSize', 12);
title('Frequency Response of Sinc Pulse', 'FontSize', 14, 'FontWeight', 'bold');
xlim([-2/T, 2/T]);

%% Display eye diagram metrics
fprintf('=== Eye Diagram Analysis ===\n');
fprintf('Number of traces: %d\n', num_traces);
fprintf('Symbol period: %.2f\n', T);
fprintf('Samples per symbol: %d\n', fs);
fprintf('SNR: %d dB\n', SNR_dB);

% Calculate eye opening at optimal sampling point
sampling_idx = fs + 1;  % At T (one symbol period)
eye_heights = eye_data(sampling_idx, :);
eye_opening = max(eye_heights) - min(eye_heights);
fprintf('Eye opening at optimal sampling: %.3f\n', eye_opening);

%% Demonstrate ISI at different sampling points
figure('Position', [100 100 1000 700]);

% Create a detailed example with 5 symbols
example_data = [1, -1, 1, -1, 1];
t_example = -2*T:dt:7*T;

% Plot individual sinc pulses and their sum
subplot(2,1,1);
colors = lines(5);
sum_signal = zeros(size(t_example));

for i = 1:length(example_data)
    t_shifted = t_example - (i-1)*T;
    pulse_i = example_data(i) * sinc(t_shifted/T);
    plot(t_example/T, pulse_i, 'Color', colors(i,:), 'LineWidth', 1.5);
    hold on;
    sum_signal = sum_signal + pulse_i;
    
    % Mark the zero-crossings
    for j = 1:length(example_data)
        if i ~= j
            plot((j-1), 0, 'o', 'Color', colors(i,:), ...
                 'MarkerSize', 6, 'LineWidth', 2);
        end
    end
end

% Plot the sum
plot(t_example/T, sum_signal, 'k', 'LineWidth', 3);

% Mark optimal sampling points
for i = 1:length(example_data)
    plot((i-1), example_data(i), 'r*', 'MarkerSize', 15, 'LineWidth', 3);
end

grid on;
xlabel('Time (Symbol Periods)', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
title('ISI Demonstration: Individual Sinc Pulses and Their Sum', ...
      'FontSize', 13, 'FontWeight', 'bold');
legend([repmat({'Sinc pulse '}, 1, 5), 'Sum (actual signal)', ...
        'Optimal sampling'], 'Location', 'eastoutside');
xlim([-1 5]);
ylim([-2 2]);

% Add vertical lines at sampling instants
for i = 0:4
    plot([i i], ylim, 'r--', 'LineWidth', 1);
end

% Subplot 2: Show signal value vs sampling time offset
subplot(2,1,2);
time_offsets = linspace(-0.5*T, 0.5*T, 200);
signal_values = zeros(size(time_offsets));

for idx = 1:length(time_offsets)
    t_sample = 2*T + time_offsets(idx);  % Sample around the 3rd symbol
    
    % Calculate signal value at this time
    val = 0;
    for i = 1:length(example_data)
        val = val + example_data(i) * sinc((t_sample - (i-1)*T)/T);
    end
    signal_values(idx) = val;
end

plot(time_offsets/T, signal_values, 'b', 'LineWidth', 2);
hold on;
plot(0, example_data(3), 'r*', 'MarkerSize', 15, 'LineWidth', 3);
plot(0, example_data(3), 'ro', 'MarkerSize', 12, 'LineWidth', 2);
grid on;
xlabel('Sampling Time Offset (Symbol Periods)', 'FontSize', 12);
ylabel('Sampled Signal Value', 'FontSize', 12);
title('ISI Effect: Signal Value vs Timing Offset from Optimal Point', ...
      'FontSize', 13, 'FontWeight', 'bold');
ylim([-1.5 1.5]);

% Highlight ISI regions
y_lim = ylim;
patch([time_offsets(1)/T, time_offsets(end)/T, time_offsets(end)/T, time_offsets(1)/T], ...
      [1, 1, y_lim(2), y_lim(2)], 'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
patch([time_offsets(1)/T, time_offsets(end)/T, time_offsets(end)/T, time_offsets(1)/T], ...
      [-1, -1, y_lim(1), y_lim(1)], 'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
text(0.3, 1.3, 'ISI Region', 'Color', 'r', 'FontSize', 10, 'FontWeight', 'bold');

fprintf('\n=== Key Insight ===\n');
fprintf('At optimal sampling (offset = 0): Signal = %.3f (clean!)\n', example_data(3));
fprintf('Maximum ISI observed: %.3f (%.1f%% error)\n', ...
        max(abs(signal_values - example_data(3))), ...
        100*max(abs(signal_values - example_data(3))));
fprintf('\nThe sinc pulse guarantees zero ISI ONLY at optimal sampling points.\n');
fprintf('Between these points, ISI can cause values to exceed ±1.\n');