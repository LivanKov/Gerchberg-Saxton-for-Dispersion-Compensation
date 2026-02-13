function out = CustomGS(system, mode, convergenceMode, iterations)
    target_launch = system.currentVals;
    target_envelope = abs(target_launch);
    mseTolerance = 1e-10;
    maxIterations = 1000;

    if mode == 1
        % Phase-only predistortion
        predistorted_launch = target_launch;

        if convergenceMode == 1
            % Fixed number of iterations
            for k = 1:iterations
                propagated = applyCD(predistorted_launch, system);
                propagated = target_envelope .* exp(1j * angle(propagated));
                backpropagated = applyCDInverse(propagated, system);
                predistorted_launch = target_envelope .* exp(1j * angle(backpropagated));
            end

        elseif convergenceMode == 0
            % MSE-based convergence
            prevMSE = inf;
            k = 0;
            while k < maxIterations
                k = k + 1;
                propagated = applyCD(predistorted_launch, system);
                propagated = target_envelope .* exp(1j * angle(propagated));
                backpropagated = applyCDInverse(propagated, system);
                predistorted_launch = target_envelope .* exp(1j * angle(backpropagated));

                currentMSE = mean(abs(target_envelope - abs(propagated)).^2);
                if prevMSE - currentMSE < mseTolerance
                    fprintf("Phase-only predistortion converged after %d iterations (MSE: %.6e)\n", k, currentMSE);
                    break;
                end
                prevMSE = currentMSE;
            end
            if k == maxIterations
                fprintf(2, "Warning: Phase-only predistortion did not converge within %d iterations (MSE: %.6e)\n", maxIterations, currentMSE);
            end
        end

        out = predistorted_launch;

    elseif mode == 0
        % Amplitude-only predistortion
        receiver_side = target_launch;

        if convergenceMode == 1
            % Fixed number of iterations
            for k = 1:iterations
                backpropagated = applyCDInverse(receiver_side, system);
                backpropagated = abs(backpropagated) .* exp(1j * 0);
                propagated = applyCD(backpropagated, system);
                receiver_side = target_envelope .* exp(1j * angle(propagated));
            end

        elseif convergenceMode == 0
            % MSE-based convergence
            prevMSE = inf;
            k = 0;
            while k < maxIterations
                k = k + 1;
                backpropagated = applyCDInverse(receiver_side, system);
                backpropagated = abs(backpropagated) .* exp(1j * 0);
                propagated = applyCD(backpropagated, system);
                receiver_side = target_envelope .* exp(1j * angle(propagated));

                currentMSE = mean(abs(target_envelope - abs(propagated)).^2);
                if prevMSE - currentMSE < mseTolerance
                    fprintf("Amplitude-only predistortion converged after %d iterations (MSE: %.6e)\n", k, currentMSE);
                    break;
                end
                prevMSE = currentMSE;
            end
            if k == maxIterations
                fprintf(2, "Warning: Amplitude-only predistortion did not converge within %d iterations (MSE: %.6e)\n", maxIterations, currentMSE);
            end
        end

        out = backpropagated;

    else 
        fprintf(2, "Unknown mode! Supported Modes:\n1: Phase only predistortion.\n0: Amplitude only predistortion\n");
    end

end