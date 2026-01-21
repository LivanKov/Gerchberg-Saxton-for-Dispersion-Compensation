sys = System;
% Test without filter
results1 = sys.runTest('length', 100000, 'useBandpassFilter', false);
% Test with filter
results2 = sys.runTest('length', 100000, 'useBandpassFilter', true, 'bandpassPercentage', 90, 'noiseVariance', 0.05);
% Compare manually
disp(results1.ber);
disp(results2.ber);