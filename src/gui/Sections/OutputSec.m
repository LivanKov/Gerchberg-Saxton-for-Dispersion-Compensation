classdef OutputSec < handle
    properties
        parent
        system
        Grid
        NestedGrid
        GenButton
        TopAxes
        Slider
        BottomAxes
        ValueLabel
        BottomGrid
        ApplyButton
        
        % Property to store the specific line object for the filter
        FilterLine 
        MagLine
    end
    
    methods
        function this = OutputSec(panel, s)
            this.parent = panel;
            this.system = s;
            
            this.Grid = uigridlayout(this.parent);
            this.Grid.ColumnWidth = {'1x'}; 
            this.Grid.RowHeight = {'1x', '1x'};
            
            this.NestedGrid = uigridlayout(this.Grid);
            this.NestedGrid.Layout.Row = 1;
            this.NestedGrid.Layout.Column = 1;
            this.NestedGrid.ColumnWidth = {'1x'};
            this.NestedGrid.RowHeight = {30, '1x', 20, 50};
            
            this.GenButton = uibutton(this.NestedGrid, 'Text', 'Generate');
            this.GenButton.Layout.Row = 1;
            this.GenButton.Layout.Column = 1;
            this.GenButton.ButtonPushedFcn = @(btn, event) this.generatePlot();
            
            this.TopAxes = uiaxes(this.NestedGrid);
            this.TopAxes.Layout.Row = 2;
            this.TopAxes.Layout.Column = 1;
            title(this.TopAxes, 'Original Magnitude');

            % 3. Value Label (New)
            this.ValueLabel = uilabel(this.NestedGrid);
            this.ValueLabel.Layout.Row = 3;
            this.ValueLabel.Layout.Column = 1;
            this.ValueLabel.HorizontalAlignment = 'center';
            this.ValueLabel.Text = '95%'; % Initial text
            
            this.Slider = uislider(this.NestedGrid);
            this.Slider.Layout.Row = 4;
            this.Slider.Layout.Column = 1;
            this.Slider.Value = 95;
            % Note: Added the event argument (src, event) or (~, event) to the callback
            this.Slider.ValueChangedFcn = @(src, event) this.onSliderChanged(src, event);
            
            this.BottomGrid = uigridlayout(this.Grid);
            this.BottomGrid.Layout.Row = 2;
            this.BottomGrid.Layout.Column = 1;
            this.BottomGrid.ColumnWidth = {'1x'};
            this.BottomGrid.RowHeight = {'1x', 20};
            
            this.BottomAxes = uiaxes(this.BottomGrid);
            this.BottomAxes.Layout.Row = 1;
            this.BottomAxes.Layout.Column = 1;
            title(this.BottomAxes, 'Bottom Axes');
            
            this.ApplyButton = uibutton(this.BottomGrid, 'Text', 'Apply');
            this.ApplyButton.Layout.Row = 2;
            this.ApplyButton.Layout.Column = 1;
            this.ApplyButton.ButtonPushedFcn = @(btn, event) this.applyFilter();
            
            N = length(this.system.currentVals);
        end
        
        function generatePlot(this)
            if ~isempty(this.MagLine) && isvalid(this.MagLine)
                delete(this.MagLine);
            end
            if ~isempty(this.FilterLine) && isvalid(this.FilterLine)
                delete(this.FilterLine);
            end
            spec = fftshift(fft(this.system.currentVals));
            N = length(this.system.t_vec);
            f = (-(N/2):(N/2-1)) * this.system.FS/N;
            this.MagLine = plot(this.TopAxes, f, abs(spec), 'b');
            this.TopAxes.YLim = [0 max(abs(spec)) * 1.2]
            this.FilterLine = [];
        end
        
        function onSliderChanged(this, ~, event)
            currentVal = round(event.Value);
            this.ValueLabel.Text = sprintf('%d%%', currentVal);
            o_f = this.system.outputFilter;
            N = length(this.system.t_vec);
            spec = fftshift(fft(this.system.shapedVals));
            noisy_spec = fftshift(fft(this.system.currentVals));
            f = (-(N/2):(N/2-1)) * this.system.FS/N;
            
            o_f.areaCovered = currentVal;
            designed_filt = o_f.construct(f, spec);
            hold(this.TopAxes, 'on');
            if ~isempty(this.FilterLine) && isvalid(this.FilterLine)
                delete(this.FilterLine);
            end
            this.FilterLine = plot(this.TopAxes, f, max(abs(noisy_spec)) * designed_filt, 'Color', [1, 0.5, 0]);
            plot(this.BottomAxes, this.system.t_vec, this.system.currentVals);
            this.BottomAxes.XLim = [0 16 * this.system.SAMPLING_INTERVAL];
            this.BottomAxes.YLim = [1.2 * min(this.system.currentVals) 1.2 * max(this.system.currentVals)];
        end
        
        function applyFilter(this)
            this.system.applyOutputFilter();
            plot(this.BottomAxes, this.system.t_vec, this.system.currentVals);
            this.BottomAxes.XLim = [0 16 * this.system.SAMPLING_INTERVAL];
            this.BottomAxes.YLim = [1.2 * min(this.system.currentVals) 1.2 * max(this.system.currentVals)];
        end
    end
end