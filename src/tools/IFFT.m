% A simple Wrapper for matlab's builtin
% IFFT function
% Simplifies creating a fitting frequency domain and scaling
% Treats the signal as truly continouous
function [t, x] = IFFT(s, toPlot)
    arguments
        s double
        toPlot string = "false"
    end

    X_1 = ifftshift(s);
    x = ifft(X_1);

    t = (0:length(x)- 1);

    if toPlot == 't' || toPlot == "true"
        plot(t, x, 'Color', 'y', 'LineWidth', 1.5);
        ylim([min(x) * 2 max(x)*2]);
        GlobalPlotSettings();
        title("Time Domain (Reconstructed via IFFT)");
        xlabel('Time (t)'); ylabel('x(t)');
        grid on;
    end

end