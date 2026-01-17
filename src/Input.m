classdef Input < handle
    properties
         mod_mode 
         stream int8
         size (1, 2) int8
         path char
    end

    methods
        function inputObj = Input()
            inputObj.stream = [];
            inputObj.size = [0 0];
        end

        function readInput(this, input)
            if (~isa(input, 'string') & ~isa(input, 'char'))
                fprintf(2, "Error: StrToBin only accepts char and string types as input\n");
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
            this.updateSize();
        end

        function generateRandomBin(this, len)
            this.stream = randi([0 1], 1, len);
            this.updateSize();
            fprintf(1,"Generated a random string of bits of length: %d\n", len);
        end
    end

    methods (Access = private)
        function updateSize(this)
            this.size(1) = length(this.stream);
            this.size(2) = length(this.stream)/8;
        end
    end
end