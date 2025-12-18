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
    y = (abs(x) <= width/2) * a;

    if toPlot == 't' | toPlot == "true"
        plot(x, y, 'Color', 'y', 'LineWidth', 1.5);
        ylim([min(y) * 2 max(y)*2]);
        GlobalPlotSettings();
    end 
end
