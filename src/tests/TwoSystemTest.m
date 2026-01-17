%% Init
s_raw = System;
s_bandpass = System;
len = 400000;
sinc = Pulse.COS_SQR;
s_raw.generateRandomInput(len);
s_bandpass.generateRandomInput(len);
fprintf(1, "Random inputs generated\n");
s_raw.pulseShape = sinc;
s_bandpass.pulseShape = sinc;
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

fprintf(1, "BER for a system without a bandpass filter: %.2f%%\n", ber_raw);
fprintf(1, "BER for a system with a bandpass filter %.2f%%\n", ber_bandpass);



