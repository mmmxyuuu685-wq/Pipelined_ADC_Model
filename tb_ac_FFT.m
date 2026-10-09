clear;
clc;
close all;
addpath(fileparts(mfilename('fullpath')));

parameters;
system_model;

noisePower = 1e-8;
useHann = true;
rng(1);

assert(isscalar(noisePower) && isfinite(noisePower) && noisePower >= 0, 'noisePower must be a finite nonnegative scalar (V^2).');
t = (0:Nfft - 1).' / Fs;
Vin = Vcm + Ain * sin(2 * pi * Fin * t) + sqrt(noisePower) * randn(Nfft, 1);
stages = {stagesIdeal, stagesMismatch, stagesOffset, stagesFinite};
codes = zeros(Nfft, numel(stages));
for caseIndex = 1:numel(stages)
    codes(:, caseIndex) = model.pipelineADC(Vin, stages{caseIndex});
end

result = analyzeSpectrum(codes * VREF / 2^Nbits, Fs, Fin, VREF, useHann);

plot_FFT(result, Fs);
plot_PSD(result, Fs);
