s = System;
s.input.generateRandomBin(15);
s.updateStream();
s.plot();
s.shapeInput();
s.plot();
s.addNoise(1);
s.plot();

%{
Low fs​: The "noise floor" is high because the noise power is crammed into a small frequency range.

High fs​: The same total noise power is spread out over a much wider
frequency range. The "noise floor" drops.
%}