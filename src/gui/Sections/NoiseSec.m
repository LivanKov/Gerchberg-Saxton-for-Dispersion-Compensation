classdef NoiseSec < handle
    properties
        parent % Parent panel
        system System % System object
        input_analysis_graph
        noise_switch % Access the noise analysis switch
        disabled_plot % Flag to disable plotting
        energy_label % Label to display pulse energy per symbol
        noise_power_label % Label to display noise power
    end
    
    methods
        function this = NoiseSec(panel, s)
            this.parent = panel;
            this.system = s;
            this.disabled_plot = true;
            
            n_i = uigridlayout(panel, [2 1]);
            n_i.RowHeight = {'1x', 300};
            
            dt = 1/System.FS;
            x_noisy = -System.SAMPLING_INTERVAL:dt:System.SAMPLING_INTERVAL;
            pulse_shape = s.pulseShape;
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
            noise_sld.Limits = [0 5];
            noise_sld.Value = 0;
            noise_sld.Position(1:2) = [5 200];
            
            this.energy_label = uilabel(noise_sld_panel);
            this.energy_label.Position = [5 100 200 20];
            this.energy_label.FontSize = 15;
            energy_per_symbol = trapz(x_noisy, abs(y_noisy).^2);
            this.energy_label.Text = "Energy/Symbol: " + string(energy_per_symbol) + " J";
            
            this.noise_power_label = uilabel(noise_sld_panel);
            this.noise_power_label.Position = [5 75 200 20];
            this.noise_power_label.FontSize = 15;
            this.noise_power_label.Text = "Noise Power: 0 W";
            
            noisy_pulse.Layout.Row = 1;
            noisy_pulse.Layout.Column = 2;
            plot(noisy_pulse,x_noisy,out_y);
            ylim(noisy_pulse, [min(out_y) * 2 - 1  max(out_y) * 2]);
        
            switch_panel = uipanel(n_i);
            switch_panel.Layout.Column = 1;
            switch_panel.Layout.Row = 2;
            switch_panel.BorderType = 'none';
        
            this.noise_switch = uiswitch(switch_panel, 'slider', ...
                'ValueChangedFcn', @(src, event) this.onNoiseSwitchChanged(src, event));
            this.noise_switch.Position = [30 260 45 20];
        
            this.input_analysis_graph = uiaxes(switch_panel);
            this.input_analysis_graph.Position(4) = 250;
            this.input_analysis_graph.YLim = [0 1];
            
        end
        
        function updateSlider(this, ~, event, noisy_pulse, x)
            p_s = this.system.pulseShape;
            y = Pulse.GeneratePulse(x, p_s, this.system.multiplier);
            noise = randn(1, length(y)) * sqrt(event.Value);
            noisy_signal = y + noise;
            plot(noisy_pulse, x, noisy_signal);
            ylim(noisy_pulse, [min(noisy_signal) * 2 - 1, max(noisy_signal) * 2]);
            
            energy_per_symbol = trapz(x, abs(y).^2);
            this.energy_label.Text = "Energy/Symbol: " + string(energy_per_symbol) + " J";
            
            noise_power = event.Value;
            this.noise_power_label.Text = "Noise Power: " + string(noise_power) + " W";
            
            this.system.addNoise(event.Value);
            if ~this.disabled_plot
                plot(this.input_analysis_graph, this.system.t_vec, this.system.currentVals);
                this.input_analysis_graph.XLim = [0 16 * this.system.SAMPLING_INTERVAL];
                this.input_analysis_graph.YLim = [1.2 * min(this.system.currentVals) 1.2 * max(this.system.currentVals)];
            end
            
        end

        function onNoiseSwitchChanged(this, src, ~)
            % Callback function for noise analysis switch
            if strcmp(src.Value, 'On')
                this.disabled_plot = false;
            else
                this.disabled_plot = true;
            end
        end
    end
end