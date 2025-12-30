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
            bin_stream = StrToBin(input);
            this.stream = bin_stream; 
            this.updateSize();
        end

        function generateRandomBin(this, len)
            this.stream = randi([0 1], 1, len);
            this.updateSize();
            fprintf(1,"Generated a random string of bits of length: %d\n", len);
        end

        % modulation vs source coding?
        % Implement BPSK and OOK
        % Is OOK even needed when dealing with binary data?
        function modulate(this)
            this.stream = [];
        end
    end

    methods (Access = private)
        function updateSize(this)
            this.size(1) = length(this.stream);
            this.size(2) = length(this.stream)/8;
        end
    end
end