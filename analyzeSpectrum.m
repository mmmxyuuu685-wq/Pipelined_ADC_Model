function result = analyzeSpectrum(vout, Fs, Fin, Vref, useHann)
    nSamples = size(vout, 1);
    toneBin = Fin * nSamples / Fs;
    window = ones(nSamples, 1);
    if useHann
        window = 0.5 - 0.5 * cos(2 * pi * (0:nSamples - 1).' / nSamples);
    end

    vout = vout - mean(vout, 1);
    spectrum = fft(vout .* window) / sqrt(nSamples * sum(window.^2));
    binPower = abs(spectrum(1:nSamples / 2 + 1, :)).^2;
    binPower(2:end - 1, :) = 2 * binPower(2:end - 1, :);
    signalBins = round(toneBin) + 1 + (-double(useHann):double(useHann));
    signalPower = sum(binPower(signalBins, :), 1);
    noiseAndDistortionPower = binPower;
    noiseAndDistortionPower([1 signalBins], :) = 0;

    result.f = (0:nSamples / 2).' * Fs / nSamples;
    result.PSD = binPower / (Fs / nSamples);
    result.FFT_dBFS = 10 * log10(max(binPower / (Vref^2 / 8), realmin));
    result.SINAD = 10 * log10(signalPower ./ sum(noiseAndDistortionPower, 1));
    result.ENOB = (result.SINAD - 1.76) / 6.02;
end
