sys = System;
results = sys.runTest('length', 200000, 'noiseVariance', 0.3, 'pulseShape', Pulse.RRC);
fprintf('BER improvement: %.4f%%\n', results.improvement);
