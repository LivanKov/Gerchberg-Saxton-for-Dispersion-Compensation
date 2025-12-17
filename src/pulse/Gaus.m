function y = Gaus(x, a, width, toPlot)
    arguments
        x double
        a double = 1
        width (1,1) double = 1
        toPlot string = 'false'
    end

    sigma = width / (2 * sqrt(2 * log(2)));
    y = a .* exp(- (x.^2) / (2 * sigma^2));

    if toPlot == "t" | toPlot == "true"
        plot(x, y, 'Color', 'y', 'LineWidth', 1.5);
        GlobalPlotSettings();
    end 
end