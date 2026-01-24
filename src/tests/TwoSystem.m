sys = System;
% Test without filter
results1 = sys.runTest('length', 100000, 'useLowpassFilter', false);
% Test with filter
results2 = sys.runTest('length', 100000, 'useLowpassFilter', true, 'lowpassPercentage', 95);
% Compare manually
disp("Without lowpass filter");
disp(results1.ber);
disp("With lowpass filter");
disp(results2.ber);