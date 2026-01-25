%% Init
s_raw = System;
s_lowpass = System;
len = 100000;
lowpass_percentage = 95;
pulse = Pulse.SINC;
s_raw.generateRandomInput(len);
s_lowpass.generateRandomInput(len);
s_raw.outputFilter.areaCovered = lowpass_percentage;
s_lowpass.outputFilter.areaCovered = lowpass_percentage;
fprintf(1, "Random inputs generated\n");
s_raw.pulseShape = pulse;
s_lowpass.pulseShape = pulse;
s_raw.shapeInput();
s_lowpass.shapeInput();
fprintf(1, "Inputs shaped\n");

%% Add noise
noise_var = 0.5;
s_raw.addNoise(noise_var);
s_lowpass.addNoise(noise_var);
fprintf("Noise applied\n");
s_lowpass.applyOutputFilter();
fprintf("Filter applied\n");

%% Sample
[ber_raw, ~ ] = s_raw.sampleInput();
[ber_lowpass, ~] = s_lowpass.sampleInput();
dt = 1/s_raw.FS;
sym_time_vec = -s_raw.SAMPLING_INTERVAL:dt:s_raw.SAMPLING_INTERVAL;
y = Pulse.GeneratePulse(sym_time_vec, s_raw);
energy_per_symbol = trapz(sym_time_vec, abs(y).^2);
snr = energy_per_symbol / (s_raw.noisePower / (1/s_raw.SAMPLING_INTERVAL));
snr_db = 10 * log10(snr);
fprintf("SNR: %.4f; SNR(dB): %.4f\n", snr, snr_db);
fprintf(1, "Lowpass filter percentage %.2f%%\n", s_raw.outputFilter.areaCovered);
fprintf(1, "BER for a system without a lowpass filter: %.2f%%\n", ber_raw);
fprintf(1, "BER for a system with a lowpass filter %.2f%%\n", ber_lowpass);



