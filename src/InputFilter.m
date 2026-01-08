classdef InputFilter < handle
    properties
        pulseShape
    end
    methods
        function inputFilterObj = InputFilter
            inputFilterObj.pulseShape = Pulse.RECT;
        end

        function out = passThrough(this, input, multiplier)
            dt = 1/System.FS;
            sym_time_vec = -System.SAMP_TIME:dt:System.SAMP_TIME;
            pulse = Pulse.GeneratePulse(sym_time_vec, this.pulseShape, multiplier);
            out = conv(input, pulse, 'same');
        end
    end
end