classdef Pulse
    enumeration
        RECT, 
        COS_SQR, 
        RCOS,
        SINC,
        RRCOS,
        MANCHESTER
    end

    methods(Static)
        function mult_pulse = GeneratePulse(input, shape, multi)
        arguments
            input double
            shape Pulse
            multi double
        end
            switch shape 
                case Pulse.RECT
                    pulse = Pulse.RectPulse(input, 1, System.SAMPLING_INTERVAL/2, "false");
                case Pulse.COS_SQR
                    pulse = Pulse.CosSqr(input, 1, System.SAMPLING_INTERVAL, "false");
                case Pulse.RCOS
                    pulse = Pulse.RCos(input/System.SAMPLING_INTERVAL, 1, "false");
                case Pulse.RRCOS
                    pulse = Pulse.RRCos(input, 1, "false");
                case Pulse.SINC
                    pulse = Pulse.Sinc(input/(System.SAMPLING_INTERVAL/2), "false");
                case Pulse.MANCHESTER
                    pulse = Pulse.Manchester(input/System.SAMPLING_INTERVAL);
                otherwise 
                    pulse = Pulse.RectPulse(input, 1, 0, 1, "false");
            end
            mult_pulse = multi * pulse;
        end


        function y = CosSqr(x, a, width, toPlot)
            arguments
                x double
                a double = 1
                width (1,1) double = 1
                toPlot string = 'false'
            end
                y = Pulse.RectPulse(x, a, width, 'f');
                cossqr = a * cos(pi*x/width).^2;
            
                y = y .* cossqr;
            
            if toPlot == 't' | toPlot == "true"
                plot(x, y, 'Color', 'y', 'LineWidth', 1.5);
                ylim([min(y) * 2 max(y)*2]);
            end 
        end

        function y = Dirac(x, a, rate, toPlot)
            arguments
                x double
                a double
                rate (1,1) double = 1
                toPlot string = 'false'
            end
            
            y = zeros(1, length(x));
            x_vals = 0:rate:rate*length(a);
            x_vals_it = 1;
            a_vals_it = 1;
            for i = 1:length(x)
                if (x_vals_it < length(x_vals) && abs(x(i) - x_vals(x_vals_it)) < 1e-12)
                    y(i) = a(a_vals_it);
                    a_vals_it = a_vals_it + 1;
                    x_vals_it = x_vals_it + 1;
                end
            end
            
            if toPlot == 't' | toPlot == "true"
                plot(x, y, 'Color', 'y', 'LineWidth', 1.5);
                ylim([min(y) * 2 max(y)*2]);
            end 
        end

        function y = Gaus(x, a, width, toPlot)
            arguments
                x double
                a double = 1
                width (1,1) double = 1
                toPlot string = 'false'
            end
            
            sigma = width / (2 * sqrt(2 * log(2)));
            y = a .* exp(- (x.^2) / (2 * sigma^2));
            
            if toPlot == "t" | toPlot == "true"
                plot(x, y, 'Color', 'y', 'LineWidth', 1.5);
            end 
        end
        
        function y = Manchester(x)
            T = 1;
            y = zeros(size(x));
            low = abs(x) > T/4 & abs(x) < T/2;
            y(low) = -1;
            high = abs(x) < T/4;
            y(high) = 1;
        end

        function y = RCos(x, a, toPlot)
            arguments
            x double
            a (1,1) double = 1 % Rolloff
            toPlot string = 'false'
            end
            % temporary value
            T = 1;
            
            sinc = Pulse.Sinc(x/T, 'false');
            y = sinc;
            
            if a ~= 0
                denom = (1 - 4 * a^2 * (x/T).^2);
                s_t = cos(a * pi * x/T) ./ denom;
                y = y .* s_t;
                e = (abs(x) == T/(2*a));
                y(e) = pi / (4 * T) * Pulse.Sinc(1/(2*a));
            end
            
            if toPlot == 't' | toPlot == "true"
                plot(x, y, 'Color', 'y', 'LineWidth', 1.5);
                ylim([min(y) * 2 max(y)*2]);
            end 
        end

        function y = RectPulse(x, a, width, toPlot)
            arguments
                x double
                a double = 1
                width (1,1) double = 1
                toPlot string = 'false'
            end
                y = (abs(x) <= width/2) * a;
            
                if toPlot == 't' | toPlot == "true"
                    plot(x, y, 'Color', 'y', 'LineWidth', 1.5);
                    ylim([min(y) * 2 max(y)*2]);
                end 
        end

        function y = RRCos(x, a , toPlot)
            arguments
                x double
                a (1,1) double = 1
                toPlot string = 'false'
            end
            
            T = 1;
            z = x == 0;
            q = abs(x) == T/(4 * a);
        
            y = 1 * T * Pulse.numer(x, a, T) ./ Pulse.denom(x, a, T);
            y(q) = a/(T * sqrt(2)) * ((1 + 2/pi) * sin(pi/(4*a)) + (1 - 2/pi) * cos(pi/(4*a)));
            y(z) = 1 / T * (1 + a*(4 / pi - 1));
            
            if toPlot == 't' | toPlot == "true"
                plot(x, y, 'Color', 'y', 'LineWidth', 1.5);
                ylim([min(y) * 2 max(y)*2]);
            end 
        end
            
        function y = numer(x, a, T) 
            arguments
                x double
                a double
                T double
            end
            y = sin(pi*x/T*(1-a)) + 4 * a * x/T .* cos(pi*x/T*(1 + a));
        end
        
        function y = denom(x, a, T)
            arguments
                x double
                a double
                T double
            end
            y = pi * x/T .* (1 - (4*a*x/T).^2); 
        end

        function y = Sinc(x, toPlot)
            arguments
                x double
                toPlot string = 'false'
            end
            y = ones(size(x));
            nz = (x ~= 0);
            px = pi * x(nz);
            y(nz) = sin(px) ./ px; 
        
            if toPlot == 't' | toPlot == "true"
                plot(x, y, 'Color', 'y', 'LineWidth', 1.5);
                % check if this is a singular value
                ylim([min(y) * 2 max(y)*2])
            end 
        end
   end
end