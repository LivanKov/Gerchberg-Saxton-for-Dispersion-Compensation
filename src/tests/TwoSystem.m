sys = System;
% Test without filter
results1 = sys.runTest('length', 400000, 'useBandpassFilter', false, 'verbose', false);

% Test with filter
results2 = sys.runTest('length', 400000, 'useBandpassFilter', true, 'verbose', false);

% Compare manually
disp(results1);
disp(results2);