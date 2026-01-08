classdef InputSec < handle
    properties (Access = private)
        parent % Parent panel
        system System % System object reference
        mode_label % Access the data mode label
        size_label % Access the data size label
        input_analysis_graph % Access the input analysis graph
        pulse_plot % Access the single pulse plot
    end

    methods
        function this = InputSec(panel, s)
            this.parent = panel;
            this.system = s;
            g_i = uigridlayout(this.parent, [3 1]);
            g_i.RowHeight = {180, 130, '1x'};
            
            g_i1 = uigridlayout(g_i);
            g_i1.ColumnWidth = {110, '1x', '1x'};
            g_i1.RowHeight = {160};
            g_i1.Layout.Column = 1;
            g_i1.Layout.Row = 1;
            g_i1.Padding(1) = 30;
            
            x = -System.SAMPLING_INTERVAL:1/System.FS:System.SAMPLING_INTERVAL;
            p_s = s.inputFilter.pulseShape;
            y = GeneratePulse(x, p_s, s.multiplier);
            this.pulse_plot = uiaxes(g_i1);
            f_pulse = uiaxes(g_i1);
        
            dd_panel = uipanel(g_i1);
            dd_panel.Layout.Row = 1;
            dd_panel.Layout.Column = 1;
            dd_panel.BorderType = 'none';
        
            dd_label = uilabel(dd_panel);
            dd_label.Text = "Pulse Shape";
            dd_label.FontSize = 12;
            dd_label.Position(1:3) = [10 120 80];
        
        
            pulse_dd = uidropdown(dd_panel, ...
                "ValueChangedFcn",@(src,event) this.updatePulse(src,event));
            pulse_dd.Placeholder = 'Pulse Shape';
            pulse_dd.Items = this.getPulseShapes();
            pulse_dd.Position(1:3) = [5 100 80];
            pulse_dd.FontSize = 10;

            mult_label = uilabel(dd_panel);
            mult_label.Text = "Multiplier";
            mult_label.Position = [5 70 100 20];
            mult_label.FontSize = 10;
            uieditfield(dd_panel, 'numeric', ...
                'Position', [5 50 100 22], ...
                'Value', 1.0, ...
                'ValueChangedFcn', @(src,event) this.changeMultiplier(src, event));  


            this.pulse_plot.Layout.Row = 1;
            this.pulse_plot.Layout.Column = 2;
            this.pulse_plot.YLim = [2 * min(y) 2 * max(y)];
        
            f_pulse.Layout.Row = 1;
            f_pulse.Layout.Column = 3;
        
            plot(this.pulse_plot,x,y);
            
            g_i2 = uigridlayout(g_i);
            g_i2.ColumnWidth = {120, '1x'};
            g_i2.RowHeight = {110};
            g_i2.Layout.Column = 1;
            g_i2.Layout.Row = 2;
            g_i2.Padding(1) = 30;
        
            input_panel = uipanel(g_i2);
            input_panel.Layout.Row = 1;
            input_panel.Layout.Column = 2;
            input_panel.BorderType = 'none';
        
            input_txt_area = uitextarea(input_panel, "Placeholder", "Enter message");
            input_txt_area.Position(1:4) = [5 1 180 110];
        
            upload_txt_btn = uibutton(input_panel, ...
                "Text", "Upload Text", ...
                "ButtonPushedFcn", @(src, event) this.readInputText(src, event, input_txt_area, s));
            upload_txt_btn.Position(1:4) = [200 90 80 20];
            
            input_mode_panel = uipanel(g_i2);
            input_mode_panel.Layout.Row = 1;
            input_mode_panel.Layout.Column = 1;
        
            bg = uibuttongroup(input_mode_panel, "SelectionChangedFcn", @(bg, event) this.uploadSelectionChange(bg, event, ...
               input_txt_area, upload_txt_btn));
            bg.BorderType = 'none';
            
            opt_1 = uiradiobutton(bg,"Text","Enter message", ...
                "Position",[5 40 100 22]);
            opt_1.Tag = 'msg';

            opt_3 = uiradiobutton(bg, "Text", "Generate random stream", ...
                "Position",[5 15 100 22]);
            opt_3.Tag = 'random';
            
            bg.Position(1:4) = [5 25 100 200];
            opt_1.FontSize = 10;
            opt_3.FontSize = 10;
        
            this.mode_label = uilabel(input_mode_panel);
            this.mode_label.Text = " ";
            this.mode_label.Position(1:3) = [8 25 80];
            this.mode_label.FontSize = 10;
        
            this.size_label = uilabel(input_mode_panel);
            this.size_label.Position(1:3) = [8 5 80];
            this.size_label.Text = " ";
            this.size_label.FontSize = 10;
        
            input_analysis_panel = uipanel(g_i);
            input_analysis_panel.Layout.Column = 1;
            input_analysis_panel.Layout.Row = 3;
        
            this.input_analysis_graph = uiaxes(input_analysis_panel);
            this.input_analysis_graph.Position(4) = 250;
            this.input_analysis_graph.YLim = [0 1];
        end

        function names_str = getPulseShapes(~)
           names = enumeration(PulseShape.RECT);
           names_str = string(names);
        end

        function redrawPulse(this)
            p_s = this.system.inputFilter.pulseShape;
            x = -System.SAMPLING_INTERVAL:1/System.FS:System.SAMPLING_INTERVAL;
            y = GeneratePulse(x, p_s, this.system.multiplier);
            plot(this.pulse_plot,x, y);
            this.pulse_plot.YLim = [2*min(y) 2*max(y)];
        end

        function updatePulse(this, src, ~)
            new_pulse = src.Value;
            this.system.updatePulse(new_pulse);
            this.redrawPulse();
        end

        function readInputText(this ,~ , ~, input_txt_area, sys)
            text = input_txt_area.Value{1};
            if (~~isempty(text))
                fprintf(2, "Error: Empty message string\n");
            else 
                if input_txt_area.Placeholder == "Enter message"
                    sys.ingest(text);
                else 
                    sys.input.generateRandomBin(str2double(text));
                    sys.updateStream();
                end
                
                bin_stream = sys.input.stream;

                if ~isempty(bin_stream)
                    % this.updateDataLabels();
                    this.refreshInputPlot();
                    plot(this.input_analysis_graph, sys.t_vec, sys.currentVals);
                    disp(this.input_analysis_graph.XLim);
                    sys.shapeInput();
                    hold(this.input_analysis_graph, 'on');
                    plot(this.input_analysis_graph, sys.t_vec, sys.currentVals);
                    %this.input_analysis_graph.YLim = [min(sys.currentVals)*2 max(sys.currentVals)*2];
                    %this.input_analysis_graph.XLim = [0 System.SAMPLING_INTERVAL * (length(bin_stream) - 1)];
                end
            end
        end

        function uploadSelectionChange(~, ~, event, ...
            input_txt_area, upload_txt_btn)
           opt = event.NewValue.Tag;
           if opt == "file"
               input_txt_area.Enable = 'off';
               upload_txt_btn.Enable = 'off';
               input_txt_area.Placeholder = "Enter message";
               upload_txt_btn.Text = "Upload Text";
           elseif opt == "msg"
               input_txt_area.Enable = 'on';
               upload_txt_btn.Enable = 'on';
               input_txt_area.Placeholder = "Enter message";                              
               upload_txt_btn.Text = "Upload Text";
           elseif opt == "random"
               input_txt_area.Placeholder = "Enter length";
               upload_txt_btn.Enable = 'on';
               upload_txt_btn.Text = "Create";
           end
        end

        function updateDataLabels(this)
            this.size_label.Text = this.system.input.size(1) + " Bits, " + this.system.input.size(2) + " Bytes";
            this.mode_label.Text = string(this.system.input.mode);
        end

        function refreshInputPlot(this)
            cla(this.input_analysis_graph);
        end

        function changeMultiplier(this, src , ~)
            this.system.multiplier = src.Value;
            this.redrawPulse;
        end
    end
end