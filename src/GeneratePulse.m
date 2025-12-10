% Take vector of  time discrete impulses
% Convolve them with a pulse shape
% Output a vector containing the result of the convolution
% TODO: Output a plot showcasing the input signal and the output
% TODO: Different colors for specific each input
% TODO: FFT convolution
% Current goal: minimize dependency on external toolboxes

function mult_pulse = GeneratePulse(input, shape, multi)
arguments
    input double
    shape PulseShape
    multi double
end
    switch shape 
        case PulseShape.RECT
            pulse = RectPulse(input, 1, System.SAMPLING_INTERVAL/2, "false");
        case PulseShape.COS_SQR
            pulse = CosSqr(input, 1, 1, "false");
        case PulseShape.RCOS
            pulse = RCos(input, 1, "false");
        case PulseShape.RRCOS
            pulse = RRCos(input, 1, "false");
        case PulseShape.SINC
            pulse = Sinc(input, "false");
        case PulseShape.MANCHESTER
            pulse = Manchester(input);
        otherwise 
            pulse = RectPulse(input, 1, 0, 1, "false");
    end
    mult_pulse = multi * pulse;
end

