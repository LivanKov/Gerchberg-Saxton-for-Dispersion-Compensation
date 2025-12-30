classdef InputFilter < handle
    properties
        pulseShape PulseShape
    end
    methods
        function inputFilterObj = InputFilter
            inputFilterObj.pulseShape = PulseShape.RECT;
        end

        function out = passThrough(this, input, multiplier)
            dt = 1/System.FS;
            sym_time_vec = -System.SAMP_TIME:dt:System.SAMP_TIME;
            pulse = GeneratePulse(sym_time_vec, this.pulseShape, multiplier);
            out = conv(input, pulse, 'same');
        end
    end
end