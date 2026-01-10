clc;close all; clear all;

freq = 2;
samp_time = 100;
fs = 200;

N_plots = 7;

t = -samp_time/2:1/fs:samp_time/2;
% t = 0:1/fs:samp_time;
disp(length(t));
N = length(t);

% s = sinc(freq*t) + sinc(freq*(t - 10)) + sinc(freq*(t - 20));
% s = sin(freq*2*pi*t);
s = Pulse.RectPulse(freq*t, 1, 1) + Pulse.RectPulse(freq*(t-10), 1, 1) + Pulse.RectPulse(freq*(t-20), 1, 1);
figure;
subplot(N_plots, 1, 1);
plot(t, s);
title('Original signal');

spec = fftshift(fft(s));
subplot(N_plots,1,2);
f = (-(N/2):(N/2-1)) * fs/N;
plot(f, abs(spec));
xlim([-20 20]);
title('Original magnitude');


SNR = 10;

noise_sig = awgn(s, SNR);
subplot(N_plots,1,3);
plot(t, noise_sig);
text = ['Noisy Signal. SNR: ' num2str(SNR)];
title(text);

subplot(N_plots, 1, 4);
noise_sig_mag = fftshift(fft(noise_sig));
plot(f, abs(noise_sig_mag));
title('Noisy Signal Magnitude');
xlim([-20 20]);



o_f = OutputFilter;
o_f.areaCovered = 90;
designed_filt = o_f.construct(f, spec);

perf_filt = zeros(1, length(f));
idx = abs(f) <= 2.5;
perf_filt(idx) = 1;
subplot(N_plots, 1, 5);
plot(f, designed_filt);
xlim([-20 20]);
title('Perfect Filter');

filtered = designed_filt .* noise_sig_mag;

subplot(N_plots, 1, 6);
plot(f, abs(filtered));
xlim([-20 20]);
title('Filtered Magnitude');

subplot(N_plots, 1, 7);
res = abs(ifft(ifftshift(filtered)));
plot(t, res);
title('Original Signal reconstructed via IFFT');
lol = t == 20;
ids = find(t == 20, 1);


%{
Sampling at a higher rate will distribute the quantization noise over a wider frequency, thus reducing the noise spectral density due to quantization noise specifically, with a lot of caveats. For more details on that see What are advantages of having higher sampling rate of a signal?

So when the SNR is limited by quantization noise, then increasing the sampling rate can increase the SNR by reducing that portion of quantization noise that is in the signal bandwidth. However if the quantization noise is significantly less (such that we are actually sampling the actual in-band noise), then increasing the sampling rate will not improve that in-band SNR.

In your last paragraph, if you are referring to running the same filter at a lower rate versus a higher rate, 
at a lower sampling rate the digital filter will require LESS taps for the same filter performance. 
For more details on that see Filter Order Rule of Thumb and How many taps does an FIR filter need?.

An effective strategy to consider is to use a higher sampling rate which relaxes the 
analog filtering requirements and can give you more effective bits if needed at the analog to digital boundary 
(which are realized after subsequent filtering digitally). 
This is then followed by efficient resampling techniques in the digital domain to get to a 
lower sampling frequency prior to providing the final filtering as required in your system design 
(coarse and simpler filters are done at the higher rate, and then final "shaping filters" are done at the lowest rate 
possible thus minimizing number of taps, power dissipation and resources).

For a further details on decimating to a lower rate for improved filter performance see Fast Integer 8 Hz 2nd Order LP for Microcontroller.
%}

% Effective SNR??

%% Using system components

