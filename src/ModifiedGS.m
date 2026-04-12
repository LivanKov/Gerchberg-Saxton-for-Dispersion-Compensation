function ModifiedGS(system, varargin)
    p = inputParser;
    addParameter(p, 'mode', 1, @isnumeric);  % 1: phase-only, 0: amplitude-only
    addParameter(p, 'convergenceMode', 1, @isnumeric);  % 1: fixed iterations, 0: RMSE
    addParameter(p, 'iterations', 100, @isnumeric);
    addParameter(p, 'verbose', false, @islogical);
    addParameter(p, 'mseTolerance', 10e-10, @isnumeric);
    addParameter(p, 'maxIterations', 10000, @isnumeric);
    addParameter(p, 'plotRMSE', false, @islogical);
    parse(p, varargin{:});

    mode = p.Results.mode;
    convergenceMode = p.Results.convergenceMode;
    iterations = p.Results.iterations;
    verbose = p.Results.verbose;
    mseTolerance = p.Results.mseTolerance;
    maxIterations = p.Results.maxIterations;
    plotRMSE = p.Results.plotRMSE;

    target_envelope = abs(system.currentVals);
    rmse_history = [];

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
                rmse_history(end+1) = err;
                prev = abs(system.currentVals);
                system.currentVals = target_envelope .* exp(1j * angle(system.currentVals));
                [~, comp] = system.applyChromaticDispersionInv();
                system.currentVals = target_envelope .* exp(1j * angle(comp));
                if verbose
                    fprintf(1, "Current error: %d\n", err);
                end
            end

            if plotRMSE
                figure;
                plot(1:iterations, rmse_history, '-o');
                xlabel('Iteration');
                ylabel('RMSE');
                title('RMSE Convergence (Phase-only, Fixed Iterations)');
                grid on;
            end

        elseif convergenceMode == 0
            fprintf(1, "Convergence Mode: RMSE\n");
            err = inf;
            k = 1;

            while err > mseTolerance && k <= maxIterations
                system.applyChromaticDispersion();
                err = rmse(prev, abs(system.currentVals));
                rmse_history(end+1) = err;
                prev = abs(system.currentVals);
                system.currentVals = target_envelope .* exp(1j * angle(system.currentVals));
                [~, comp] = system.applyChromaticDispersionInv();
                system.currentVals = target_envelope .* exp(1j * angle(comp));
                k = k + 1;
                if verbose
                    fprintf(1, "Current error: %d\n", err);
                end
            end

            fprintf(1, "Iterations completed:%d\n", k);

            if plotRMSE
                figure;
                plot(1:length(rmse_history), rmse_history, '-o');
                xlabel('Iteration');
                ylabel('RMSE');
                title('RMSE Convergence (Phase-only, RMSE Mode)');
                grid on;
            end

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
                rmse_history(end+1) = err;
                prev = abs(system.currentVals);
                system.applyChromaticDispersion();
                system.currentVals = target_envelope .* exp(1j * angle(system.currentVals));
                if verbose
                    fprintf(1, "Current error: %d\n", err);
                end
            end

            system.currentVals = copy;

            if plotRMSE
                figure;
                plot(1:iterations, rmse_history, '-o');
                xlabel('Iteration');
                ylabel('RMSE');
                title('RMSE Convergence (Amplitude-only, Fixed Iterations)');
                grid on;
            end

        elseif convergenceMode == 0
            fprintf(1, "Convergence Mode: RMSE\n");
            err = inf;
            k = 1;
            prev = target_envelope;

            while err > mseTolerance && k <= maxIterations
                [ab, ~] = system.applyChromaticDispersionInv();
                system.currentVals = ab .* exp(1j * 0);
                err = rmse(prev, abs(system.currentVals));
                rmse_history(end+1) = err;
                prev = abs(system.currentVals);            
                system.applyChromaticDispersion();
                system.currentVals = target_envelope .* exp(1j * angle(system.currentVals));
                k = k + 1;
                if verbose
                    fprintf(1, "Current error: %d\n", err);
                end
            end

            fprintf(1, "Iterations completed:%d\n", k);

            [ab, ~] = system.applyChromaticDispersionInv();
            system.currentVals = ab;

            if plotRMSE
                figure;
                plot(1:length(rmse_history), rmse_history, '-o');
                xlabel('Iteration');
                ylabel('RMSE');
                title('RMSE Convergence (Amplitude-only, RMSE Mode)');
                grid on;
            end

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