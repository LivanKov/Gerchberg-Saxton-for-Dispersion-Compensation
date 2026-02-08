classdef Settings < handle
    properties
        parent % Parent panel
        system System % System object
        % UI components
        samplingIntervalField
        sampTimeField
        fsField
        chanLenField
        lambdaField
        dataRateLabel
    end
    
    methods
        function this = Settings(panel, s)
            this.parent = panel;
            this.system = s;
            
            g = uigridlayout(this.parent, [7 2]);
            g.RowHeight = {'fit', 'fit', 'fit', 'fit', 'fit', 'fit', '1x'};
            g.ColumnWidth = {'fit', '1x'};
            g.Padding = [10 10 10 10];
            g.RowSpacing = 10;
            g.ColumnSpacing = 10;
            
            lbl1 = uilabel(g, 'Text', 'Sampling Interval (ps):');
            lbl1.Layout.Row = 1;
            lbl1.Layout.Column = 1;
            
            this.samplingIntervalField = uieditfield(g, 'numeric', ...
                'Value', this.system.SAMPLING_INTERVAL * 1e12, ...
                'ValueChangedFcn', @(src, event) this.updateSamplingInterval(src));
            this.samplingIntervalField.Layout.Row = 1;
            this.samplingIntervalField.Layout.Column = 2;
            
            lbl2 = uilabel(g, 'Text', 'Sample Time (ps):');
            lbl2.Layout.Row = 2;
            lbl2.Layout.Column = 1;
            
            this.sampTimeField = uieditfield(g, 'numeric', ...
                'Value', this.system.SAMP_TIME * 1e12, ...
                'ValueChangedFcn', @(src, event) this.updateSampTime(src));
            this.sampTimeField.Layout.Row = 2;
            this.sampTimeField.Layout.Column = 2;
            
            lbl3 = uilabel(g, 'Text', 'Sampling Frequency (GHz):');
            lbl3.Layout.Row = 3;
            lbl3.Layout.Column = 1;
            
            this.fsField = uieditfield(g, 'numeric', ...
                'Value', this.system.FS / 1e9, ...
                'ValueChangedFcn', @(src, event) this.updateFs(src));
            this.fsField.Layout.Row = 3;
            this.fsField.Layout.Column = 2;
            
            % Channel Length
            lbl4 = uilabel(g, 'Text', 'Channel Length (km):');
            lbl4.Layout.Row = 4;
            lbl4.Layout.Column = 1;
            
            this.chanLenField = uieditfield(g, 'numeric', ...
                'Value', this.system.CHAN_LEN, ...
                'ValueChangedFcn', @(src, event) this.updateChanLen(src));
            this.chanLenField.Layout.Row = 4;
            this.chanLenField.Layout.Column = 2;
            
            lbl5 = uilabel(g, 'Text', 'Wavelength (nm):');
            lbl5.Layout.Row = 5;
            lbl5.Layout.Column = 1;
            
            this.lambdaField = uieditfield(g, 'numeric', ...
                'Value', this.system.LAMBDA * 1e9, ...
                'ValueChangedFcn', @(src, event) this.updateLambda(src));
            this.lambdaField.Layout.Row = 5;
            this.lambdaField.Layout.Column = 2;
            
            lbl6 = uilabel(g, 'Text', 'Data Rate:');
            lbl6.Layout.Row = 6;
            lbl6.Layout.Column = 1;
            
            this.dataRateLabel = uilabel(g);
            this.dataRateLabel.Layout.Row = 6;
            this.dataRateLabel.Layout.Column = 2;
            this.refreshDataRate();
        end
        
        % Callback functions to update system parameters
        function updateSamplingInterval(this, src)
            this.system.SAMPLING_INTERVAL = src.Value * 1e-12;
            this.refreshDataRate();
        end
        
        function updateSampTime(this, src)
            this.system.SAMP_TIME = src.Value * 1e-12;
        end
        
        function updateFs(this, src)
            this.system.FS = src.Value * 1e9;
        end
        
        function updateChanLen(this, src)
            this.system.CHAN_LEN = src.Value;
        end
        
        function updateLambda(this, src)
            this.system.LAMBDA = src.Value * 1e-9;
        end
        
        function refreshDataRate(this)
            rate = 1 / this.system.SAMPLING_INTERVAL;
            if rate >= 1e12
                this.dataRateLabel.Text = sprintf('%.2f Tbps', rate / 1e12);
            elseif rate >= 1e9
                this.dataRateLabel.Text = sprintf('%.2f Gbps', rate / 1e9);
            elseif rate >= 1e6
                this.dataRateLabel.Text = sprintf('%.2f Mbps', rate / 1e6);
            else
                this.dataRateLabel.Text = sprintf('%.2f bps', rate);
            end
        end
    end
end