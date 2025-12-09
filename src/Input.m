classdef Input < handle
    properties
         mode InputMode
         mod_mode 
         stream int8
         size (1, 2) int8
         path char
    end

    methods
        function inputObj = Input()
            inputObj.mode = InputMode.TEXT_RAW;
            inputObj.stream = [];
            inputObj.size = [0 0];
        end

        function updateFileContents(this, path)
            fid = fopen(path, 'rb');

            if this.mode ~= InputMode.FILE
                fprintf(2, "Error: Cannot read file due to wrong Input mode. Aborting\n");
                return;
            end

            if fid ~= -1
                this.stream = fread(fid, "ubit1", 'b')';
                len = length(bin_stream);
                fprintf(1, "Read %s\nSize:\n   %d bits\n   %d bytes\n", path, len, len/8);
                fclose(fid);
                this.updateSize();
            else 
                this.stream = [];
                fprintf(2, "Error: the input file does not exist or could not be opened\n");
            end
        end


        function readInput(this, input)
            if this.mode == InputMode.FILE
                fprintf(2, "Error: Cannot read input due to wrong Input mode. Aborting\n");
                return;
            end
            bin_stream = StrToBin(input, this.mode);
            this.stream = bin_stream; 
            this.updateSize();
        end

        function switchToRaw(this)
            this.mode = InputMode.TEXT_RAW;
        end

        function switchToBinary(this)
            this.mode = InputMode.TEXT_BINARY;
        end

        function generateRandomBin(this, len)
            this.switchToBinary();
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