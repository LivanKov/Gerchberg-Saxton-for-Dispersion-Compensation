function [t_new, pulse_new, info] = construct_percentage_pulse(t, pulse, percentage)

% CONSTRUCT_PERCENTAGE_PULSE - Constructs a pulse containing a specified
% percentage of the area of the input pulse by finding symmetric bounds
%
% Inputs:
%   t          - Time vector
%   pulse      - Original pulse values
%   percentage - Desired percentage of area (e.g., 99 for 99%)
%
% Outputs:
%   t_new      - Time vector for new pulse (same as input)
%   pulse_new  - New pulse with specified percentage of area
%   info       - Struct with diagnostic information

    % Find center of the pulse (assume symmetric about this point)
    center_idx = find_pulse_center(t, pulse);
    center_time = t(center_idx);
    
    % Calculate total area of original pulse
    area_total = trapz(t, abs(pulse));
    target_area = (percentage / 100) * area_total;
    
    % Binary search to find the half-width that gives target area
    % Start with full range
    left = 0;
    right = max(abs(t - center_time));
    tolerance = 1e-6 * area_total;
    
    while (right - left) > 1e-9
        mid = (left + right) / 2;
        
        % Create mask for symmetric window around center
        mask = abs(t - center_time) <= mid;
        area_current = trapz(t, abs(pulse) .* mask);
        
        if area_current < target_area
            left = mid;
        else
            right = mid;
        end
    end
    
    half_width = (left + right) / 2;
    
    % Construct the new pulse
    mask = abs(t - center_time) <= half_width;
    pulse_new = pulse .* mask;
    
    % Calculate actual area achieved
    area_achieved = trapz(t, abs(pulse_new));
    percentage_achieved = (area_achieved / area_total) * 100;
    
    % Package output information
    info.center_time = center_time;
    info.half_width = half_width;
    info.area_original = area_total;
    info.area_new = area_achieved;
    info.percentage_target = percentage;
    info.percentage_achieved = percentage_achieved;
    info.bounds = [center_time - half_width, center_time + half_width];
    
    t_new = t;
end

function center_idx = find_pulse_center(t, pulse)
% Find the center of mass of the pulse
    total_moment = trapz(t, abs(pulse) .* t);
    total_area = trapz(t, abs(pulse));
    center_time = total_moment / total_area;
    
    % Find closest index
    [~, center_idx] = min(abs(t - center_time));
end

%% Example usage and demonstration
if ~exist('pulse_original', 'var')
    % Create example signals
    N = 1000;
    t = linspace(-5, 5, N);
    
    % Example 1: Rectangular pulse
    pulse_rect = double(abs(t) <= 1);
    
    % Example 2: Gaussian pulse
    pulse_gauss = exp(-t.^2 / 0.5);
    
    % Example 3: Triangular pulse
    pulse_tri = max(0, 1 - abs(t)/1.5);
    
    % Example 4: Sinc-like pulse
    pulse_sinc = sinc(2*t);
    
    % Apply function to all examples
    [~, rect_99, info_rect] = construct_percentage_pulse(t, pulse_rect, 99);
    [~, gauss_99, info_gauss] = construct_percentage_pulse(t, pulse_gauss, 99);
    [~, tri_99, info_tri] = construct_percentage_pulse(t, pulse_tri, 99);
    [~, sinc_99, info_sinc] = construct_percentage_pulse(t, pulse_sinc, 99);
    
    % Plotting
    figure('Position', [100, 100, 1200, 800]);
    
    subplot(2,2,1);
    plot(t, pulse_rect, 'b-', 'LineWidth', 2); hold on;
    plot(t, rect_99, 'r--', 'LineWidth', 2);
    xline(info_rect.bounds(1), 'k:', 'LineWidth', 1);
    xline(info_rect.bounds(2), 'k:', 'LineWidth', 1);
    xlabel('Time'); ylabel('Amplitude');
    title(sprintf('Rectangular: %.2f%% area', info_rect.percentage_achieved));
    legend('Original', '99% pulse', 'Bounds');
    grid on;
    
    subplot(2,2,2);
    plot(t, pulse_gauss, 'b-', 'LineWidth', 2); hold on;
    plot(t, gauss_99, 'r--', 'LineWidth', 2);
    xline(info_gauss.bounds(1), 'k:', 'LineWidth', 1);
    xline(info_gauss.bounds(2), 'k:', 'LineWidth', 1);
    xlabel('Time'); ylabel('Amplitude');
    title(sprintf('Gaussian: %.2f%% area', info_gauss.percentage_achieved));
    legend('Original', '99% pulse', 'Bounds');
    grid on;
    
    subplot(2,2,3);
    plot(t, pulse_tri, 'b-', 'LineWidth', 2); hold on;
    plot(t, tri_99, 'r--', 'LineWidth', 2);
    xline(info_tri.bounds(1), 'k:', 'LineWidth', 1);
    xline(info_tri.bounds(2), 'k:', 'LineWidth', 1);
    xlabel('Time'); ylabel('Amplitude');
    title(sprintf('Triangular: %.2f%% area', info_tri.percentage_achieved));
    legend('Original', '99% pulse', 'Bounds');
    grid on;
    
    subplot(2,2,4);
    plot(t, pulse_sinc, 'b-', 'LineWidth', 2); hold on;
    plot(t, sinc_99, 'r--', 'LineWidth', 2);
    xline(info_sinc.bounds(1), 'k:', 'LineWidth', 1);
    xline(info_sinc.bounds(2), 'k:', 'LineWidth', 1);
    xlabel('Time'); ylabel('Amplitude');
    title(sprintf('Sinc: %.2f%% area', info_sinc.percentage_achieved));
    legend('Original', '99% pulse', 'Bounds');
    grid on;
    
    % Display summary
    fprintf('\n=== Summary of Results ===\n');
    fprintf('Rectangular pulse: %.4f to %.4f (width: %.4f)\n', ...
        info_rect.bounds(1), info_rect.bounds(2), 2*info_rect.half_width);
    fprintf('Gaussian pulse: %.4f to %.4f (width: %.4f)\n', ...
        info_gauss.bounds(1), info_gauss.bounds(2), 2*info_gauss.half_width);
    fprintf('Triangular pulse: %.4f to %.4f (width: %.4f)\n', ...
        info_tri.bounds(1), info_tri.bounds(2), 2*info_tri.half_width);
    fprintf('Sinc pulse: %.4f to %.4f (width: %.4f)\n', ...
        info_sinc.bounds(1), info_sinc.bounds(2), 2*info_sinc.half_width);
end