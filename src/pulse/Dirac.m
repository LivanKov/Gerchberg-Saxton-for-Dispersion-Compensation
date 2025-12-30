% Naive implementation of a discrete dirac impulse
% over a given vector x, multiplied by factor a
% No external dependencies i.e the symbolic math toolbox
% Plots a graph based on the arguments passed, that doesn not interfere
% with the return variables
function y = Dirac(x, a, rate, toPlot)
arguments
    x double
    a double
    rate (1,1) double = 1
    toPlot string = 'false'
end
    y = zeros(1, length(x));
    x_vals = 0:rate:rate*length(a);
    x_vals_it = 1;
    a_vals_it = 1;
    for i = 1:length(x)
        if (x_vals_it < length(x_vals) && abs(x(i) - x_vals(x_vals_it)) < 1e-12)
            y(i) = a(a_vals_it);
            a_vals_it = a_vals_it + 1;
            x_vals_it = x_vals_it + 1;
        end
    end

    if toPlot == 't' | toPlot == "true"
        plot(x, y, 'Color', 'y', 'LineWidth', 1.5);
        ylim([min(y) * 2 max(y)*2]);
        GlobalPlotSettings();
    end 
end
