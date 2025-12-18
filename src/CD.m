% The following class represents the block responsible for chromatic
% dispersion within the IM/DD system.



classdef CD < handle
    properties
        disp_coeff double % Dispersion coefficient, set to 17 by default
    end

    methods
        function cd_obj = CD(disp_coeff)
            cd_obj.disp_coeff = disp_coeff;
        end

        function out = input(this, input_sig)
        
        
        end


        function plot(this)
            
        end
    end

    methods(Access = private)
        function convert_to_gvd()
            
        end
    end
end