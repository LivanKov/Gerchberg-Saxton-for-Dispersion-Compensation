classdef NoiseSec < handle
    properties
        parent % Parent panel
        system System % System object
    end
    
    methods
        function this = NoiseSec(panel, s)
            this.parent = panel;
            this.system = s;
            
            n_i = uigridlayout(panel, [2 2]);
            
            x_noisy = -5:0.01:5;
            pulse_shape = s.inputFilter.pulseShape;
            y_noisy = GeneratePulse(x_noisy, pulse_shape,s.multiplier);
            
            n_ii = uigridlayout(n_i, [5 1]);
            n_ii.Layout.Row = 1;
            n_ii.Layout.Column = 1;
            
            out_y = ApplyNoise(y_noisy, 0);
            
            noisy_pulse = uiaxes(n_i);
            
            mode_dd = uidropdown(n_ii);
            mode_dd.Items = {'Additive White Noise'};
            mode_dd.Layout.Row = 1;
            mode_dd.Layout.Column = 1;
            mode_dd.FontColor = [0.9 0.9 0.9];
            
            noise_sld = uislider(n_ii, "ValueChangedFcn",@(src,event) this.updateSlider(src,event, noisy_pulse, x_noisy));
            noise_sld.Limits = [0 5];
            noise_sld.Value = 0;
            noise_sld.Layout.Row = 5;
            noise_sld.Layout.Column = 1;
            noise_sld.FontColor = [0.85 0.85 0.85];
            
            noisy_pulse.Layout.Row = 1;
            noisy_pulse.Layout.Column = 2;
            noisy_pulse.Color = [0.18 0.18 0.21];
            noisy_pulse.XColor = [0.6 0.6 0.65];
            noisy_pulse.YColor = [0.6 0.6 0.65];
            noisy_pulse.GridColor = [0.3 0.3 0.35];
            noisy_pulse.MinorGridColor = [0.25 0.25 0.28];
            
            plot(noisy_pulse,x_noisy,out_y);
            ylim(noisy_pulse, [min(out_y) * 2 - 1  max(out_y) * 2]);
        end
        
        function updateSlider(this, ~, event, noisy_pulse, x)
            p_s = this.system.inputFilter.pulseShape;
            y = GeneratePulse(x, p_s, this.system.multiplier);
            new_out_y = ApplyNoise(y, event.Value);
            plot(noisy_pulse, x, new_out_y);
            noisy_pulse.YLim = [min(new_out_y) * 2 - 1 max(new_out_y) * 2];
        end
    end
end