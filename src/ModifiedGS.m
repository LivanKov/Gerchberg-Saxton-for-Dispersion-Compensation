function ModifiedGS(system, mode, convergenceMode, iterations, verbose)
    target_envelope = abs(system.currentVals);
    mseTolerance = 10e-10;
    maxIterations = 10000;

    % Convergence mode: 
    % 1 -> Fixed number of iterations
    % 0 -> Run until a specific rmse is reached


    % Phase-only predistortion mode
    % Corresponds to the method in PredistortionGS.m
    if mode == 1
        fprintf(1, "Running phase-only predistortion custom GS\n");
        system.currentVals = target_envelope .* exp(1j * 2*pi*rand(size(target_envelope)));
        prev = target_envelope;
        if convergenceMode == 1
            fprintf(1, "Convergence Mode: Fixed iterations.\n");
            fprintf(1, "Using %d iterations\n", iterations);

            for k = 1:iterations
                system.applyChromaticDispersion();                                
                err = rmse(prev, abs(system.currentVals));
                prev = abs(system.currentVals);
                system.currentVals = target_envelope .* exp(1j * angle(system.currentVals));
                [~, comp] = system.applyChromaticDispersionInv();
                system.currentVals = target_envelope .* exp(1j * angle(comp));
                if verbose == 1
                    fprintf(1, "Current error: %d\n", err);
                end
            end

        elseif convergenceMode == 0
            fprintf(1, "Convergence Mode: RMSE\n");
            err = inf;
            k = 1;

            while err > mseTolerance && k <= maxIterations
                system.applyChromaticDispersion();
                err = rmse(prev, abs(system.currentVals));
                prev = abs(system.currentVals);
                system.currentVals = target_envelope .* exp(1j * angle(system.currentVals));
                [~, comp] = system.applyChromaticDispersionInv();
                system.currentVals = target_envelope .* exp(1j * angle(comp));
                k = k + 1;
                if verbose == 1
                    fprintf(1, "Current error: %d\n", err);
                end
            end

            fprintf(1, "Iterations completed:%d\n", k);

            if k > maxIterations
                fprintf(2, "Warning: Phase-only predistortion did not converge within %d iterations (MSE: %.6e)\n", maxIterations, err);
            end
        else 
            fprintf(2, "Unknown convergence mode! Supported Modes:\n1: Fixed iteration count\n0: Conversion via RMSE\n");
            return;
        end

    elseif mode == 0
        % Amplitude-only predistortion
        % Corresponds to the method in PredistortionGS2.m
        fprintf(1, "Running amplitude-only predistortion custom GS\n");
        system.currentVals = target_envelope .* exp(1j * 2*pi*rand(size(target_envelope)));
        prev = target_envelope;

        if convergenceMode == 1
            fprintf(1, "Convergence Mode: Fixed iterations.\n Using %d iterations", iterations);
            for k = 1:iterations
                [ab, ~] = system.applyChromaticDispersionInv();
                system.currentVals = ab .* exp(1j * 0);
                copy = system.currentVals;
                err = rmse(prev, abs(system.currentVals));
                prev = abs(system.currentVals);
                system.applyChromaticDispersion();
                system.currentVals = target_envelope .* exp(1j * angle(system.currentVals));
                if verbose == 1
                    fprintf(1, "Current error: %d\n", err);
                end
            end

            system.currentVals = copy;

        elseif convergenceMode == 0
            fprintf(1, "Convergence Mode: RMSE\n");
            err = inf;
            k = 1;
            prev = target_envelope;

            while err > mseTolerance && k <= maxIterations
                [ab, ~] = system.applyChromaticDispersionInv();
                system.currentVals = ab .* exp(1j * 0);
                err = rmse(prev, abs(system.currentVals));
                prev = abs(system.currentVals);            
                system.applyChromaticDispersion();
                system.currentVals = target_envelope .* exp(1j * angle(system.currentVals));
                k = k + 1;
                if verbose == 1
                    fprintf(1, "Current error: %d\n", err);
                end
            end

            fprintf(1, "Iterations completed:%d\n", k);

            [ab, ~] = system.applyChromaticDispersionInv();
            system.currentVals = ab;

            if k == maxIterations
                fprintf(2, "Warning: Amplitude-only predistortion did not converge within %d iterations (MSE: %.6e)\n", maxIterations, currentMSE);
            end

        else
            fprintf(2, "Unknown convergence mode! Supported Modes:\n1: Fixed iteration count\n0: Conversion via RMSE\n");
            return;
        end

    else 
        fprintf(2, "Unknown mode! Supported Modes:\n1: Phase only predistortion.\n0: Amplitude only predistortion\n");
    end

end