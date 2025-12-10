% Naive implementation of a discrete symmetrical rectangular impulse
% over a given vector x, multiplied by factor a
% No external dependencies, i.e the communication toolbox
% Plots a graph based on the arguments passed, that doesn not interfere
% with the return variables
% TODO: check for communications toolbox and fallback onto rectpuls function
% if available
function y = RectPulse(x, a, width, toPlot)
arguments
    x double
    a double = 1
    width (1,1) double = 1
    toPlot string = 'false'
end
    samp_rate = System.SYMBOL_PRECISION;
    x_vals = -width/2:samp_rate:width/2;
    y = (abs(x) <= x_vals(end)) * a;

    if toPlot == 't' | toPlot == "true"
        plot(x, y, 'Color', 'y', 'LineWidth', 1.5);
        ylim([min(y) * 2 max(y)*2]);
        GlobalPlotSettings();
    end 
end
