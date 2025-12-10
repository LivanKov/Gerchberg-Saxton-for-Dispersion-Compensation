classdef InputFilter < handle
    properties
        pulseShape PulseShape
    end
    methods
        function inputFilterObj = InputFilter
            inputFilterObj.pulseShape = PulseShape.RECT;
        end

        function out = passThrough(this, input, multiplier)
            len = System.SAMPLING_INTERVAL * length(input);
            start = System.START - len/2;
            sym_time_vec = start:System.SYMBOL_PRECISION:len/2;
            pulse = GeneratePulse(sym_time_vec, this.pulseShape, multiplier);
            out = conv(input, pulse, 'same');
        end
    end
end