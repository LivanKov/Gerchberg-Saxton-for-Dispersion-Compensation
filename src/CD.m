% The following class represents the block responsible for chromatic
% dispersion within the IM/DD system.
% Currently operates within the the nanometer/picoseconds units


classdef CD < handle
    properties
        disp_coeff double % Dispersion coefficient, set to 17 by default
        gvd double % group velocity dispersion parameter. Necessary for the transfer function
    end

    methods
        function cd_obj = CD(disp_coeff)
            arguments
                disp_coeff double = 17
            end

            if nargin > 0
                cd_obj.disp_coeff = disp_coeff;
            end

            cd_obj.gvd = -(System.LAMBDA^2 / (2*pi*System.LIGHT)) * (cd_obj.disp_coeff * 1e-3);
        end

        function out = input(this, sig)

            fs = 1000e9;   
            dt = 1/fs;
            t = -200e-12 : dt : 200e-12;

            N = length(t);
            U0 = fftshift(fft(sig));
            f = (-((N-1)/2):(N/2)) * fs/N * 2*pi;

            H = exp(1i * (this.gvd/2) * f.^2 * L); 
            U_out = U0 .* H;
            out = ifft(ifftshift(U_out));
        end
    end
end