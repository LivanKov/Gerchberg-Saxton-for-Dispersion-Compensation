% A simple Wrapper for matlab's builtin
% FFT function
% Simplifies creating a fitting frequency domain and scaling
% Treats the signal as a truly continuous
function [f, s] = FFT(x, toPlot)
    arguments
        x double
        toPlot string = 'false'
    end
    
    if nargin < 3
        toPlot = "false";
    end

    Y = fft(x);
    Y_shifted = fftshift(Y);
    
    N = length(x);
    fs = System.FS;
    f = (-N/2:N/2-1) * (fs/N);
    s = Y_shifted;
    
    if toPlot == 't' | toPlot == "true"
        plot(f, abs(s), 'Color', 'y', 'LineWidth', 1.5);
        ylim([min(s) * 2 max(s)*2]);
        GlobalPlotSettings();
        xlabel('Frequency (Hz)'); ylabel('|FFT|');
        title('Magnitude Spectrum');
        grid on;
        xlim([-20 20]);
    end

end