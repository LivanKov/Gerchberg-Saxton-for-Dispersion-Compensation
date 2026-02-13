function [predistorted_launch, predistorted_out] = ModifiedGS(system, mode)
    % ModifiedGS - Gerchberg-Saxton algorithm for chromatic dispersion compensation
    %
    % Inputs:
    %   system - System object containing pulse and channel parameters
    %   mode   - 0: Standard GS (transmitter->receiver->transmitter)
    %            1: Inverse GS (receiver->transmitter->receiver)
    %
    % Outputs:
    %   predistorted_launch - Optimized transmitter signal
    %   predistorted_out    - Received signal after CD
    
    target_launch = system.currentVals;
    target_envelope = abs(target_launch);
    max_iters = 150;
    
    if mode == 0
        % Standard GS approach (from PredistortionGS.m)
        % Start with arbitrary phase at transmitter
        predistorted_launch = target_envelope .* exp(1j * 2*pi*rand(size(target_envelope)));
        
        % Transmitter constraint: enforce target amplitude, vary phase
        % Receiver constraint: enforce target amplitude, keep phase
        for k = 1:max_iters
            propagated = applyCD(predistorted_launch, system);
            propagated = target_envelope .* exp(1j * angle(propagated));
            backpropagated = applyCDInverse(propagated, system);
            predistorted_launch = target_envelope .* exp(1j * angle(backpropagated));
        end
        
        predistorted_out = applyCD(predistorted_launch, system);
        
    elseif mode == 1
        % Inverse-CD-first GS approach (from PredistortionGS2.m)
        % Start with arbitrary phase at receiver
        receiver_side = target_envelope .* exp(1j * 2*pi*rand(size(target_envelope)));
        
        % Loop: receiver->transmitter->receiver
        % Transmitter constraint: keep amplitude, set phase to 0
        % Receiver constraint: enforce target amplitude, keep phase
        for k = 1:max_iters
            backpropagated = applyCDInverse(receiver_side, system);
            backpropagated = abs(backpropagated) .* exp(1j * 0);
            propagated = applyCD(backpropagated, system);
            receiver_side = target_envelope .* exp(1j * angle(propagated));
        end
        
        predistorted_launch = abs(backpropagated);
        predistorted_out = applyCD(predistorted_launch, system);
        
    else
        error('Invalid mode. Use 0 for standard GS or 1 for inverse GS.');
    end
end

function out = applyCD(signal, system)
    % Apply chromatic dispersion transfer function
    D = 17;
    beta2 = -(system.LAMBDA^2 / (2*pi*system.LIGHT)) * (D * 1e-3);
    N = length(signal);
    omega = (-((N-1)/2):(N/2)) * system.FS/N * 2*pi;
    H = exp(1i * (beta2/2) * omega.^2 * system.CHAN_LEN);
    out = ifft(ifftshift(fftshift(fft(signal)) .* H));
end

function out = applyCDInverse(signal, system)
    % Apply inverse chromatic dispersion transfer function
    D = 17;
    beta2 = -(system.LAMBDA^2 / (2*pi*system.LIGHT)) * (D * 1e-3);
    N = length(signal);
    omega = (-((N-1)/2):(N/2)) * system.FS/N * 2*pi;
    H_inv = exp(-1i * (beta2/2) * omega.^2 * system.CHAN_LEN);
    out = ifft(ifftshift(fftshift(fft(signal)) .* H_inv));
end