%% Init
s_raw = System;
s_bandpass = System;
len = 400000;
bandpass_percentage = 95;
pulse = Pulse.SINC;
s_raw.generateRandomInput(len);
s_bandpass.generateRandomInput(len);
s_raw.outputFilter.areaCovered = bandpass_percentage;
s_bandpass.outputFilter.areaCovered = bandpass_percentage;
fprintf(1, "Random inputs generated\n");
s_raw.pulseShape = pulse;
s_bandpass.pulseShape = pulse;
s_raw.shapeInput();
s_bandpass.shapeInput();
fprintf(1, "Inputs shaped\n");

%% Add noise
noise_var = 0.5;
s_raw.addNoise(noise_var);
s_bandpass.addNoise(noise_var);
fprintf("Noise applied\n");
s_bandpass.applyOutputFilter();
fprintf("Filter applied\n");

%% Sample
[ber_raw, ~ ] = s_raw.sampleInput();
[ber_bandpass, ~] = s_bandpass.sampleInput();
dt = 1/System.FS;
sym_time_vec = -System.SAMPLING_INTERVAL:dt:System.SAMPLING_INTERVAL;
y = Pulse.GeneratePulse(sym_time_vec, pulse, s_raw.multiplier);
energy_per_symbol = trapz(sym_time_vec, abs(y).^2);
snr = energy_per_symbol / (s_raw.noisePower / (1/System.SAMPLING_INTERVAL));
snr_db = 10 * log10(snr);
fprintf("SNR: %.4f; SNR(dB): %.4f\n", snr, snr_db);
fprintf(1, "Bandpass filter percentage %.2f%%\n", s_raw.outputFilter.areaCovered);
fprintf(1, "BER for a system without a bandpass filter: %.2f%%\n", ber_raw);
fprintf(1, "BER for a system with a bandpass filter %.2f%%\n", ber_bandpass);



