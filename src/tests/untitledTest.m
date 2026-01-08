s = System;
s.ingest('1101');
s.shapeInput();
s.plot();
s.addNoise(0.005);
s.plot();
s.applyOutputFilter();
