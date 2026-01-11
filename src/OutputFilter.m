classdef OutputFilter < handle
    properties
        areaCovered double
    end

    methods
        function outputFilterObj =  OutputFilter()
            outputFilterObj.areaCovered = 95;
        end

        % returns a perfect lowpass, retaining 99% of the spectral energy
        % of the impulse
        function out = construct(this, f, spec)
            f_pos_ids = f >= 0;
            abs_spec = abs(spec);
            f_pos = f(f_pos_ids);
            spec_pos = abs_spec(f_pos_ids);
            esd = abs(spec_pos) .^ 2;
            int = cumtrapz(f_pos, esd);
            total_energy = trapz(f_pos, esd);
            desired = total_energy * this.areaCovered / 100;
            [~, idx] = find(int > desired, 1);  
            square_filter_full = zeros(1, length(f));
            square_filter_full(ceil(length(f)/2) - idx + 2: ceil(length(f)/2) + idx - 1) = 1;
            out = square_filter_full;
        end
    end
end