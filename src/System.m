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
        t_vec
        f_vec
        spectrum
        oversampling_ratio
        freq
        multiplier
    end

    properties(Constant)
        SYMBOL_PRECISION = 0.01 % vector granularity / Precision
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
            this.currentVals = this.multiplier * DiscPulse(this.t_vec, this.input.stream, ...
                System.SAMPLING_INTERVAL, 0);
        end

        function ingest(this, stream)
            in = this.input;
            in.readInput(stream);
            this.rebuildTimeVec();
            this.currentVals = this.multiplier * DiscPulse(this.t_vec, in.stream, ...
                System.SAMPLING_INTERVAL, 0);
        end

        function updateStream(this)
            in = this.input;
            this.rebuildTimeVec();
            this.currentVals = this.multiplier * DiscPulse(this.t_vec, in.stream, ...
                System.SAMPLING_INTERVAL, 0);
        end

        function shapeInput(this)
            out = this.inputFilter.passThrough(this.currentVals, this.multiplier);
            this.currentVals = out;
            this.buildSpectrum();
        end

        function sqr_filter =  applyOutputFilter(this)
            sqr_filter = this.outputFilter.construct(this.f_vec, this.spectrum);
            
            filtered_spec = sqr_filter .* this.spectrum;
            [~, x] = IFFT(filtered_spec);
            this.currentVals = abs(x);
        end

        function buildSpectrum(this)
            [f, spec] = FFT(this.currentVals);
            this.f_vec = f;
            this.spectrum = spec;
        end

        function addNoise(this, a)
            noisy_vals = ApplyNoise(this.currentVals, a);
            this.currentVals = noisy_vals;
        end

        function plot(this, color)
            if nargin == 1
                color = 'y';
            end

            if isempty(this.t_vec) || isempty(this.currentVals)
                return
            end
            figure;
            plot(this.t_vec, this.currentVals, 'Color', color, 'LineWidth', 1.5);
            ylim([min(this.currentVals) * 2 max(this.currentVals)*2]);
            GlobalPlotSettings();
            xlim([0 (length(this.input.stream) - 1) * System.SAMPLING_INTERVAL]);
        end

        function plotFT(this, color)
            if nargin == 1
                color = 'y';
            end

            if isempty(this.t_vec) || isempty(this.currentVals)
                return
            end
            figure;
            [f, spec] = FFT(this.currentVals);
            plot(f, abs(spec), 'Color', color, 'LineWidth', 1.5);
            ylim([min(this.currentVals) * 2 max(this.currentVals)*2]);
            xlim([-20 20]);
            GlobalPlotSettings();
        
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
    end

    methods(Access = private)
        function rebuildTimeVec(this)
            stream = this.input.stream;
            len = System.SAMPLING_INTERVAL * length(stream);
            this.t_vec = -(System.SAMP_TIME/2 + len - 1):1/System.FS:(System.SAMP_TIME/2 + len - 1);
        end
    end
end