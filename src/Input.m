classdef Input < handle
    properties
         mod_mode 
         stream int8
         size (1, 2) int8
    end

    methods
        function inputObj = Input()
            inputObj.stream = [];
            inputObj.size = [0 0];
        end

        function readInput(this, input)
            % Check if input is numeric (vector of 0s and 1s)
            if isnumeric(input)
                % Validate that all values are 0 or 1
                if ~all(input == 0 | input == 1)
                    fprintf(2, "Error: Numeric input must contain only 0s and 1s\n");
                    return;
                end
                this.stream = int8(input);
                return;
            end
            
            % Handle string/char input
            if (~isa(input, 'string') & ~isa(input, 'char'))
                fprintf(2, "Error: readInput accepts numeric vectors, char, or string types as input\n");
                return;
            end 
        
            if (isa(input, 'string'))
                input = char(input);
            end 
        
            check = input ~= '0' & input ~= '1';
        
            if any(check)
                fprintf(2, "Error: Binary mode only accepts 1's and 0's");
                return
            end
            this.stream = input - '0'; 
        end

        function generateRandomBin(this, len)
            this.stream = randi([0 1], 1, len);
            % fprintf(1,"Generated a random string of bits of length: %d\n", len);
        end
    end
end