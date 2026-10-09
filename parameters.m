VREF = 1;
C1 = 1e-12;
mismatch = 0.30;
Vos = 0.10 * VREF;
A0 = 20;
nPoints = 4001;
Nbits = 8;

Fs = 1e6;
Nfft = 2^14;
nCycles = 127;
Fin = nCycles * Fs / Nfft;
Ain = 0.499 * VREF;
Vcm = VREF / 2;

pIdeal = struct('Vref', VREF, 'C1', C1, 'C2', C1, 'A0', Inf, 'Vos', 0);

pMismatch = pIdeal;
pMismatch.C2 = (1 + mismatch) * C1;
pOffset = pIdeal;
pOffset.Vos = Vos;
pFinite = pIdeal;
pFinite.A0 = A0;

