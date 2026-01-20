% This class encapsulates the communication system
% Core functionalities will be extended over 
% in order to simulate more conditions

% Properties: 
%   OutputFilter: used for signal reconstruction; matched filter 
%   Noise: basic noise simulation. Add support for multiple modes
%   Input: input raw data and perform various operations
%   Output: output of the filter. Use to reconstruct the initially sent
%   message

% Function definitions

classdef System < handle
    properties
        outputFilter OutputFilter
        input
        Output
        currentVals; % current values output by the filter etc.
        nonNoisyVals;
        duplicatedVals;
        t_vec
        oversampling_ratio
        freq
        multiplier
        sample_indices
        pulseShape Pulse
        noisePower
    end

    properties(Constant)
        SAMPLING_INTERVAL = 10e-12; % length of a single pulse
        SAMP_TIME = 200e-12;
        FS = 3000e9;
        CHAN_LEN = 5;
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
            o_f = OutputFilter;
            sysObj.outputFilter = o_f;
            sysObj.multiplier = 1;
            sysObj.pulseShape = Pulse.RECT;
            sysObj.noisePower = 0;
        end

        function ingest(this, stream)
            in = this.input;
            in.readInput(stream);
            this.rebuildTimeVec();
            [vals, indices] = Pulse.Dirac(this.t_vec, in.stream, ...
                System.SAMPLING_INTERVAL);
            this.currentVals = this.multiplier * vals;
            this.sample_indices = indices;
            this.duplicatedVals = this.currentVals;
        end

        function generateRandomInput(this, len)
            this.input.generateRandomBin(len);
            this.updateStream();
        end

        function updateStream(this)
            in = this.input;
            this.rebuildTimeVec();
            [vals, indices] = Pulse.Dirac(this.t_vec, in.stream, ...
                System.SAMPLING_INTERVAL);
            this.currentVals = this.multiplier * vals;
            this.sample_indices = indices;
            this.duplicatedVals = this.currentVals;
        end

        function shapeInput(this)
            dt = 1/System.FS;
            sym_time_vec = -System.SAMP_TIME:dt:System.SAMP_TIME;
            pulse = Pulse.GeneratePulse(sym_time_vec, this.pulseShape, this.multiplier);
            out = conv(this.currentVals, pulse, 'same');
            this.currentVals = out;
            this.duplicatedVals = this.currentVals;
            this.nonNoisyVals = this.currentVals;
        end

        function applyOutputFilter(this)
            N = length(this.t_vec);
            f = (-(N/2):(N/2-1)) * System.FS/N;
            no_noise_spec = fftshift(fft(this.nonNoisyVals));
            designed_filt = this.outputFilter.construct(f, no_noise_spec);
            noise_sig_mag = fftshift(fft(this.currentVals));
            filtered_spec = designed_filt .* noise_sig_mag;
            x = ifft(ifftshift(filtered_spec));
            this.currentVals = abs(x);
        end

        function addNoise(this, a)
            this.noisePower = a;
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

        function out = sqrLawDetect(this)
            out = this.currentVals.^2; % Square law detection
        end

        function rebuildTimeVec(this)
            dt = 1/System.FS;
            len = System.SAMP_TIME + System.SAMPLING_INTERVAL * length(this.input.stream);
            this.t_vec = -len:dt:len;
        end

        function applyChromaticDispersion(this)
            D = 17;
            beta2 = -(System.LAMBDA^2 / (2*pi*System.LIGHT)) * (D * 1e-3);
            N = length(this.currentVals);
            U0 = fftshift(fft(this.currentVals));
            f = (-((N-1)/2):(N/2)) * System.FS/N * 2*pi;
            H = exp(1i * (beta2/2) * f.^2 * System.CHAN_LEN); 
            U_out = U0 .* H;
            this.currentVals = abs(ifft(ifftshift(U_out)));
        end

        function applySquareLaw(this)
            this.currentVals = this.currentVals .^ 2;
        end

        function [ber, sampledValues] = sampleInput(this)
            sampledValues = this.currentVals(this.sample_indices) / this.multiplier;
            inputValues = this.input.stream;
            binarySampled = double(sampledValues >= 0.5);
            errors = sum(inputValues ~= binarySampled);
            totalBits = length(inputValues);
            ber = (errors / totalBits) * 100;
        end

        function [x, y] = plotBERGraph(~)
            x = -10:0.2:10;
            y = zeros(size(x));
            for i = 1:length(x)
                
            end
        end
    end
end