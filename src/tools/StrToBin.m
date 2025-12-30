% "..." vs '...' difference:
% - '...' char vector, use strcmp
% - "..." string

function y = StrToBin(input)
   if (~isa(input, 'string') & ~isa(input, 'char'))
        fprintf(2, "Error: StrToBin only accepts char and string types as input\n");
        y = [];
        return;
   end 

   if (isa(input, 'string'))
       input = char(input);
   end 

   check = input ~= '0' & input ~= '1';

   if any(check)
        fprintf(2, "Error: Binary mode only accepts 1's and 0's");
        y = [];
        return;
   end

   y = input - '0';
   return;
end