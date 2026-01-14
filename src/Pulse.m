classdef Pulse
    enumeration
        RECT, 
        COS_SQR, 
        RCOS,
        SINC,
        RRCOS,
        MANCHESTER,
        GAUS
    end

    methods(Static)
        function mult_pulse = GeneratePulse(input, shape, multi)
            switch shape 
                case Pulse.RECT
                    pulse = Pulse.RectPulse(input, 1, System.SAMPLING_INTERVAL/2);
                case Pulse.COS_SQR
                    pulse = Pulse.CosSqr(input, 1, System.SAMPLING_INTERVAL);
                case Pulse.RCOS
                    pulse = Pulse.RCos(input/System.SAMPLING_INTERVAL, 1);
                case Pulse.RRCOS
                    pulse = Pulse.RRCos(input/System.SAMPLING_INTERVAL, 1);
                case Pulse.SINC
                    pulse = Pulse.Sinc(input/(System.SAMPLING_INTERVAL/2));
                case Pulse.MANCHESTER
                    pulse = Pulse.Manchester(input/System.SAMPLING_INTERVAL);
                case Pulse.GAUS
                    pulse = Pulse.Gaus(input, 1, System.SAMPLING_INTERVAL);
                otherwise 
                    pulse = Pulse.RectPulse(input, 1, 0, 1);
            end
            mult_pulse = multi * pulse;
        end


        function y = CosSqr(x, a, width)
                y = Pulse.RectPulse(x, a, width);
                cossqr = a * cos(pi*x/width).^2;
                y = y .* cossqr;
        end

        function [y, samp_indices] = Dirac(x, a, rate)
            arguments
                x double
                a double
                rate (1,1) double = 1
            end
            
            y = zeros(1, length(x));
            x_vals = 0:rate:rate*length(a);
            x_vals_it = 1;
            a_vals_it = 1;
            tol = 1e-13;
            samp_indices = zeros(size(a));

            for i = 1:length(x)
                if (x_vals_it < length(x_vals) && abs(x(i) - x_vals(x_vals_it)) < tol)
                    y(i) = a(a_vals_it);
                    samp_indices(a_vals_it) = i;
                    a_vals_it = a_vals_it + 1;
                    x_vals_it = x_vals_it + 1;
                end
            end
        end

        function y = Gaus(x, a, width)
            arguments
                x double
                a double = 1
                width (1,1) double = 1
            end
            
            sigma = width / (2 * sqrt(2 * log(2)));
            y = a .* exp(- (x.^2) / (2 * sigma^2));
        end
        
        function y = Manchester(x)
            T = 1;
            y = zeros(size(x));
            low = abs(x) > T/4 & abs(x) < T/2;
            y(low) = -1;
            high = abs(x) < T/4;
            y(high) = 1;
        end

        function y = RCos(x, a)
            arguments
            x double
            a (1,1) double = 1 % Rolloff
            end
            y = Pulse.Sinc(x);
            
            tol = 1e-10;

            if a ~= 0
                denom = (1 - 4 * a^2 * x.^2);
                s_t = cos(a * pi * x) ./ denom;
                y = y .* s_t;
                e = (abs(abs(x) - 1/(2*a)) < tol);
                y(e) = pi / (4) * Pulse.Sinc(1/(2*a));
            end
        end

        function y = RectPulse(x, a, width)
            arguments
                x double
                a double = 1
                width (1,1) double = 1
            end
                y = (abs(x) <= width/2) * a;
        end

        function y = RRCos(x, a)
            arguments
                x double
                a (1,1) double = 1
            end

            if a < 0 || a > 1
                fprintf(2, "Incorrect value of alpha, should be between 0 and 1\n");
            end
            
            T = 1;
            z = x == 0;
            q = abs(x) == T/(4 * a);

            numer = sin(pi*x/T*(1-a)) + 4 * a * x/T .* cos(pi*x/T*(1 + a));
            denom = pi * x/T .* (1 - (4*a*x/T).^2); 

            y = 1 * T * numer ./ denom;
            y(q) = a/(T * sqrt(2)) * ((1 + 2/pi) * sin(pi/(4*a)) + (1 - 2/pi) * cos(pi/(4*a)));
            y(z) = 1 / T * (1 + a*(4 / pi - 1));
        end
            
        function y = numer(x, a, T) 
            y = sin(pi*x/T*(1-a)) + 4 * a * x/T .* cos(pi*x/T*(1 + a));
        end
        
        function y = denom(x, a, T)
            y = pi * x/T .* (1 - (4*a*x/T).^2); 
        end

        function y = Sinc(x)
            y = ones(size(x));
            nz = (x ~= 0);
            px = pi * x(nz);
            y(nz) = sin(px) ./ px; 
        end
   end
end