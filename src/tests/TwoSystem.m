sys = System;
% Test without filter
results1 = sys.runTest('length', 1000000, 'useBandpassFilter', false);
% Test with filter
results2 = sys.runTest('length', 1000000, 'useBandpassFilter', true);
% Compare manually
disp(results1.ber);
disp(results2.ber);