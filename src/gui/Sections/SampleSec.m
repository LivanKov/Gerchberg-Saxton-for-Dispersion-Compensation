classdef SampleSec < handle
    properties
        parent
        system
        Grid
        InputLabel
        InputValueLabel
        SampledLabel
        SampledValueLabel
        BERLabel
        BERValueLabel
        SampleButton
    end
    
    methods
        function this = SampleSec(panel, s)
            this.parent = panel;
            this.system = s;
            
            this.Grid = uigridlayout(this.parent);
            this.Grid.ColumnWidth = {'fit', '1x'}; 
            this.Grid.RowHeight = {'fit', 'fit', 'fit', 'fit'};
            
            % First row: Input values label and value
            this.InputLabel = uilabel(this.Grid);
            this.InputLabel.Layout.Row = 1;
            this.InputLabel.Layout.Column = 1;
            this.InputLabel.Text = 'Input values: ';
            
            this.InputValueLabel = uilabel(this.Grid);
            this.InputValueLabel.Layout.Row = 1;
            this.InputValueLabel.Layout.Column = 2;
            this.InputValueLabel.Text = mat2str(this.system.input.stream);
          
            this.SampledLabel = uilabel(this.Grid);
            this.SampledLabel.Layout.Row = 2;
            this.SampledLabel.Layout.Column = 1;
            this.SampledLabel.Text = 'Sampled values: ';
            
            this.SampledValueLabel = uilabel(this.Grid);
            this.SampledValueLabel.Layout.Row = 2;
            this.SampledValueLabel.Layout.Column = 2;
            this.SampledValueLabel.Text = '';
          
            this.BERLabel = uilabel(this.Grid);
            this.BERLabel.Layout.Row = 3;
            this.BERLabel.Layout.Column = 1;
            this.BERLabel.Text = 'Bit Error Rate (%): ';
            
            this.BERValueLabel = uilabel(this.Grid);
            this.BERValueLabel.Layout.Row = 3;
            this.BERValueLabel.Layout.Column = 2;
            this.BERValueLabel.Text = '';
          
            this.SampleButton = uibutton(this.Grid, 'Text', 'Sample');
            this.SampleButton.Layout.Row = 4;
            this.SampleButton.Layout.Column = [1 2];
            this.SampleButton.ButtonPushedFcn = @(src, event) this.onSampleButtonPushed(src, event);
        end
        
        function onSampleButtonPushed(this, ~, ~)
            [ber, sampledValues] = this.system.sampleInput();
            inputValues = this.system.input.stream;
            this.InputValueLabel.Text = mat2str(inputValues);
            this.SampledValueLabel.Text = mat2str(round(sampledValues, 2));
            this.BERValueLabel.Text = sprintf('%.2f%%', ber);
        end
    end
end
