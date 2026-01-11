classdef NoiseSec < handle
    properties
        parent % Parent panel
        system System % System object
        input_analysis_graph
    end
    
    methods
        function this = NoiseSec(panel, s)
            this.parent = panel;
            this.system = s;
            
            n_i = uigridlayout(panel, [2 1]);
            
            dt = 1/System.FS;
            x_noisy = -System.SAMPLING_INTERVAL:dt:System.SAMPLING_INTERVAL;
            pulse_shape = s.inputFilter.pulseShape;
            y_noisy = Pulse.GeneratePulse(x_noisy, pulse_shape,s.multiplier);
            
            n_ii = uigridlayout(n_i, [1 2]);
            n_ii.Layout.Row = 1;
            n_ii.Layout.Column = 1;
            
            noise = randn(1, length(y_noisy)) * sqrt(0);
            out_y = y_noisy + noise; 
            
            noisy_pulse = uiaxes(n_ii);
            
            noise_sld_panel = uipanel(n_ii);
            noise_sld_panel.Layout.Row = 1;
            noise_sld_panel.Layout.Column = 1;

            noise_sld = uislider(noise_sld_panel, "ValueChangedFcn",@(src,event) this.updateSlider(src,event, noisy_pulse, x_noisy));
            noise_sld.Limits = [0 2];
            noise_sld.Value = 0;
            noise_sld.Position(1:2) = [5 200];
            
            noisy_pulse.Layout.Row = 1;
            noisy_pulse.Layout.Column = 2;
            plot(noisy_pulse,x_noisy,out_y);
            ylim(noisy_pulse, [min(out_y) * 2 - 1  max(out_y) * 2]);
        
            this.input_analysis_graph = uiaxes(n_i);
            this.input_analysis_graph.Layout.Column = 1;
            this.input_analysis_graph.Layout.Row = 2;
            this.input_analysis_graph.Position(4) = 250;
            this.input_analysis_graph.YLim = [0 1];
            
        end
        
        function updateSlider(this, ~, event, noisy_pulse, x)
            p_s = this.system.inputFilter.pulseShape;
            y = Pulse.GeneratePulse(x, p_s, this.system.multiplier);
            noise = randn(1, length(y)) * sqrt(event.Value);
            plot(noisy_pulse, x, y + noise);
            ylim(noisy_pulse, [min(y + noise) * 2 - 1, max(y + noise) * 2]);
            this.system.addNoise(event.Value);
            plot(this.input_analysis_graph, this.system.t_vec, this.system.currentVals);
            this.input_analysis_graph.XLim = [0 16 * this.system.SAMPLING_INTERVAL];
        end
    end
end