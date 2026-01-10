% This class encapsulates the communication system
% Core functionalities will be extended over 
% in order to simulate more conditions

% Properties:
%   InputFilter: used for pulse shaping via convolution 
%   OutputFilter: used for signal reconstruction; matched filter 
%   Noise: basic noise simulation. Add support for multiple modes
%   Input: input raw data and perform various operations
%   Output: output of the filter. Use to reconstruct the initially sent
%   message

% Function definitions

classdef System < handle
    properties
        inputFilter InputFilter
        outputFilter OutputFilter
        chromaticDispersion CD
        input
        Output
        currentVals; % current values output by the filter etc.        
        duplicatedVals;
        t_vec
        f_vec
        spectrum
        oversampling_ratio
        freq
        multiplier
    end

    properties(Constant)
        SAMPLING_INTERVAL = 10e-12; % length of a single pulse
        SAMP_TIME = 200e-12;
        FS = 3000e9;
        CHAN_LEN = 50;
        LIGHT = 3e8;    
        LAMBDA = 1550e-9; % Carrier wavelength, default value for an optical comms system  
    end

    methods
        function sysObj = System(input)
            if nargin == 1
                sysObj.input = input;
            else
                i = Input;
                sysObj.input = i;
            end
            i_f = InputFilter;
            sysObj.inputFilter = i_f;
            o_f = OutputFilter;
            sysObj.outputFilter = o_f;
            sysObj.multiplier = 1;
        end

        function updatePulse(this, pulse)
            i_f = this.inputFilter;
            i_f.pulseShape = pulse;
            this.currentVals = this.multiplier * Pulse.Dirac(this.t_vec, this.input.stream, ...
                System.SAMPLING_INTERVAL);
            this.duplicatedVals = this.currentVals;
        end

        function ingest(this, stream)
            in = this.input;
            in.readInput(stream);
            this.rebuildTimeVec();
            this.currentVals = this.multiplier * Pulse.Dirac(this.t_vec, in.stream, ...
                System.SAMPLING_INTERVAL);
            this.duplicatedVals = this.currentVals;
        end

        function updateStream(this)
            in = this.input;
            this.rebuildTimeVec();
            this.currentVals = this.multiplier * Pulse.Dirac(this.t_vec, in.stream, ...
                System.SAMPLING_INTERVAL);
            this.duplicatedVals = this.currentVals;
        end

        function shapeInput(this)
            out = this.inputFilter.passThrough(this.currentVals, this.multiplier);
            this.currentVals = out;
            this.duplicatedVals = this.currentVals;
        end

        function applyOutputFilter(this)
            this.outputFilter.construct(this.f_vec, this.spectrum);
            filtered_spec = sqr_filter .* this.spectrum;
            x = ifft(ifftshift(filtered_spec));
            this.currentVals = abs(x);
        end

        function addNoise(this, a)
            noise = randn(1, length(this.currentVals)) * sqrt(a);
            this.currentVals = this.duplicatedVals + noise;
        end

        function plot(this)
            if isempty(this.t_vec) || isempty(this.currentVals)
                return
            end
            figure;
            plot(this.t_vec, this.currentVals);
        end

        function out = sampleOutput(this)
            mods = mod(this.t_vec, System.SAMPLING_INTERVAL);
            ids = mods == 0;
            nums = this.currentVals(ids);
            rounded = nums > 0.5;
            out = num2str(rounded);
        end

        function addCD(this)
            this.currentVals = this.chromaticDispersion.input();
        end

        function rebuildTimeVec(this)
            dt = 1/System.FS;
            len = System.SAMP_TIME + System.SAMPLING_INTERVAL * length(this.input.stream);
            this.t_vec = -len:dt:len;
        end
    end
end