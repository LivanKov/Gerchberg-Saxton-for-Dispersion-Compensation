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
        %important for noise application and filter derivation
        shapedVals;
        diracVals;
        duplicatedVals;
        t_vec
        multiplier
        sample_indices
        pulseShape Pulse
        noisePower
        filterPreBuilt
        filter
        alpha


        SAMPLING_INTERVAL = 33e-12; % length of a single pulse
        SAMP_TIME = 200e-12;
        FS = 3000e9;
        CHAN_LEN = 20;
        LIGHT = 3e8;    
        LAMBDA = 1550e-9; % Carrier wavelength, default value for an optical comms system  
        TEST_LEN = 400000;
    end

    methods
        function this = System(input)
            if nargin == 1
                this.input = input;
            else
                i = Input;
                this.input = i;
            end
            o_f = OutputFilter;
            this.outputFilter = o_f;
            this.multiplier = 1;
            this.pulseShape = Pulse.RECT;
            this.noisePower = 0;
            this.filterPreBuilt = false;
            this.alpha = 0.5;
        end

        function ingest(this, stream)
            in = this.input;
            in.readInput(stream);
            this.rebuildTimeVec();
            [vals, indices] = Pulse.Dirac(this.t_vec, in.stream, ...
                this.SAMPLING_INTERVAL);
            this.currentVals = this.multiplier * vals;
            this.diracVals = this.currentVals;
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
                this.SAMPLING_INTERVAL);
            this.currentVals = this.multiplier * vals;
            this.sample_indices = indices;
            this.duplicatedVals = this.currentVals;
        end

        function shapeInput(this)
            dt = 1/this.FS;
            sym_time_vec = -this.SAMP_TIME:dt:this.SAMP_TIME;
            pulse = Pulse.GeneratePulse(sym_time_vec, this);
            out = conv(this.currentVals, pulse, 'same');
            this.currentVals = out;
            this.duplicatedVals = this.currentVals;
            this.shapedVals = this.currentVals;
        end

        function applyOutputFilter(this)
            N = length(this.t_vec);
            f = (-(N/2):(N/2-1)) * this.FS/N;
            
            if ~this.filterPreBuilt
                no_noise_spec = fftshift(fft(this.shapedVals));
                this.filter = this.outputFilter.construct(f, no_noise_spec);
                this.filterPreBuilt = true;
                disp("No filter");
            end
            
            noise_sig_mag = fftshift(fft(this.currentVals));
            filtered_spec = this.filter .* noise_sig_mag;
            x = ifft(ifftshift(filtered_spec));
            this.currentVals = abs(x);
        end

        function resetFilter(this)
            this.filterPreBuilt = false;
            this.filter = [];
        end

        function addNoise(this, a)
            this.noisePower = a;
            noise = randn(1, length(this.currentVals)) * sqrt(a);
            this.currentVals = this.duplicatedVals + noise;
        end

        function removeNoise(this)
            this.noisePower = 0;
            this.currentVals = this.duplicatedVals;
        end

        function plot(this)
            if isempty(this.t_vec) || isempty(this.currentVals)
                return
            end
            plot(this.t_vec, this.currentVals);
            xlim([0, this.t_vec(end)]);
        end

        function scatterPlot(this)
            if isempty(this.t_vec) || isempty(this.currentVals)
                return
            end
            sampledValues = this.currentVals(this.sample_indices);
            scatter(this.t_vec(this.sample_indices), sampledValues);
            xlim([0 this.t_vec(end)]);
        end

        function out = sqrLawDetect(this)
            out = this.currentVals.^2; % Square law detection
        end

        function rebuildTimeVec(this)
            dt = 1/this.FS;
            len = this.SAMP_TIME + this.SAMPLING_INTERVAL * length(this.input.stream);
            this.t_vec = -len:dt:len;
        end

        function [ab, comp] = applyChromaticDispersion(this)
            D = 17;
            beta2 = -(this.LAMBDA^2 / (2*pi*this.LIGHT)) * (D * 1e-3);
            N = length(this.currentVals);
            U0 = fftshift(fft(this.currentVals));
            f = (-((N-1)/2):(N/2)) * this.FS/N * 2*pi;
            H = exp(1i * (beta2/2) * f.^2 * this.CHAN_LEN); 
            U_out = U0 .* H;
            comp = ifft(ifftshift(U_out));
            ab = abs(comp);
            this.currentVals = comp;
        end

        function [ab, comp] = applyChromaticDispersionInv(this)
            D = 17;
            beta2 = -(this.LAMBDA^2 / (2*pi*this.LIGHT)) * (D * 1e-3);
            N = length(this.currentVals);
            U0 = fftshift(fft(this.currentVals));
            f = (-((N-1)/2):(N/2)) * this.FS/N * 2*pi;
            H_inv = exp(-1i * (beta2/2) * f.^2 * this.CHAN_LEN);
            U_out = U0 .* H_inv;
            comp = ifft(ifftshift(U_out));
            ab = abs(comp);
        end


        function applySquareLaw(this)
            this.currentVals = (abs(this.currentVals)) .^ 2;
        end

        function [ber, sampledValues] = sampleInput(this)
            sampledValues = this.currentVals(this.sample_indices) / this.multiplier;
            inputValues = this.input.stream;
            binarySampled = double(sampledValues >= 0.5);
            errors = sum(inputValues ~= binarySampled);
            totalBits = length(inputValues);
            ber = (errors / totalBits) * 100;
        end

        function [x,y] =  runBERTest(this, varargin)
            p = inputParser;
            addParameter(p, 'length', this.TEST_LEN, @isnumeric);
            addParameter(p, 'lowpassPercentage', 90, @isnumeric);
            addParameter(p, 'pulseShape', Pulse.SINC);
            addParameter(p, 'useLowpassFilter', true, @islogical);
            addParameter(p, 'enableOpticalChannel', false, @islogical);
            parse(p, varargin{:});
            
            len = p.Results.length;
            lowpass_percentage = p.Results.lowpassPercentage;
            pulse = p.Results.pulseShape;
            use_filter = p.Results.useLowpassFilter;
            enable_optical_channel = p.Results.enableOpticalChannel;
            
            temp_input = Input;
            temp_input.generateRandomBin(len);
            test_stream = temp_input.stream;
            
            x = -10:0.5:18;
            y = zeros(size(x));
            dt = 1/this.FS;
            sym_time_vec = -this.SAMPLING_INTERVAL:dt:this.SAMPLING_INTERVAL;
            pulse_waveform = Pulse.GeneratePulse(sym_time_vec, this);
            energy_per_symbol = trapz(sym_time_vec, abs(pulse_waveform).^2);
            for i = 1:length(x)
                snr_db = x(i);
                snr_lin = 10^(snr_db/10);
                required_noise = (energy_per_symbol / snr_lin) * (1/this.SAMPLING_INTERVAL);
                disp("Required noise: " + required_noise);
                disp("Required linear snr: " + snr_lin);
                disp("SNR_DB: " + snr_db);
                fprintf(1,"\n");
                result = this.runTest('inputStream', test_stream, 'noiseVariance', required_noise, ...
                    'lowpassPercentage', lowpass_percentage, 'pulseShape', pulse, ...
                    'useLowpassFilter', use_filter, 'enableOpticalChannel', enable_optical_channel);
                y(i) = result.ber/100;
            end
            this.clear();
            y = log10(y);
        end

        function clear(this)
            % clear - Resets the system object to its initial state
            % Clears all signal data, noise, and resets configuration to defaults
            this.currentVals = [];
            this.shapedVals = [];
            this.duplicatedVals = [];
            this.t_vec = [];
            this.sample_indices = [];
            this.noisePower = 0;
            this.pulseShape = Pulse.RECT;
            this.multiplier = 1;
            this.input = Input;
            this.outputFilter = OutputFilter;
            this.filterPreBuilt = false;
            this.filter = [];
        end

        function results = runTest(this, varargin) 
            p = inputParser;
            addParameter(p, 'inputStream', [], @(x) isempty(x) || isnumeric(x));
            addParameter(p, 'length', 400000, @isnumeric);
            addParameter(p, 'lowpassPercentage', 90, @isnumeric);
            addParameter(p, 'pulseShape', Pulse.SINC);
            addParameter(p, 'noiseVariance', 0.5, @isnumeric);
            addParameter(p, 'useLowpassFilter', true, @islogical);
            addParameter(p, 'enableOpticalChannel', false, @islogical);
            parse(p, varargin{:});
            
            input_stream = p.Results.inputStream;
            len = p.Results.length;
            lowpass_percentage = p.Results.lowpassPercentage;
            pulse = p.Results.pulseShape;
            noise_var = p.Results.noiseVariance;
            use_filter = p.Results.useLowpassFilter;
            enable_optical_channel = p.Results.enableOpticalChannel;
            this.pulseShape = pulse;
            
            this.outputFilter.areaCovered = lowpass_percentage;
            if isempty(input_stream)
                this.generateRandomInput(len);
            else
                this.ingest(input_stream);
            end
            this.shapeInput();
            if enable_optical_channel
                disp("Applying Chromatic Dispersion");
                this.applyChromaticDispersion();
                this.applySquareLaw();
            end
            this.addNoise(noise_var);
            
            if use_filter
                this.applyOutputFilter();
            end
            [ber, ~] = this.sampleInput();
            dt = 1/this.FS;
            sym_time_vec = -this.SAMPLING_INTERVAL:dt:this.SAMPLING_INTERVAL;
            y = Pulse.GeneratePulse(sym_time_vec, this);
            energy_per_symbol = trapz(sym_time_vec, abs(y).^2);
            snr = energy_per_symbol / (this.noisePower / (1/this.SAMPLING_INTERVAL));
            snr_db = 10 * log10(snr);
            results.ber = ber;
            results.snr = snr;
            results.snr_db = snr_db;
            results.lowpass_percentage = lowpass_percentage;
            results.filter_applied = use_filter;
        end

        function resetCD(this)
            this.currentVals = this.duplicatedVals;
        end
    end
end