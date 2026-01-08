classdef OutputSec < handle
    properties
        parent         
        system          
        Grid         
        TopAxes      
        TimeSlider
        BottomAxes      
    end
    
    methods
        function this = OutputSec(panel, s)
            this.parent = panel;
            this.system = s;
            this.Grid = uigridlayout(this.parent);
            this.Grid.ColumnWidth = {'1x'}; 
            
            this.Grid.RowHeight = {'1x', 50, '1x'};
            
            this.TopAxes = uiaxes(this.Grid);
            this.TopAxes.Layout.Row = 1;
            this.TopAxes.Layout.Column = 1;
            title(this.TopAxes, 'Top Axes');
            
            this.TimeSlider = uislider(this.Grid);
            this.TimeSlider.Layout.Row = 2;
            this.TimeSlider.Layout.Column = 1;
            
            this.BottomAxes = uiaxes(this.Grid);
            this.BottomAxes.Layout.Row = 3;
            this.BottomAxes.Layout.Column = 1;
            title(this.BottomAxes, 'Bottom Axes');
            
            N = length(this.system.currentVals);
            spec = fftshift(fft(this.system.currentVals));
            f = (-(N/2):(N/2-1)) * System.FS/N;
        end
    end
end