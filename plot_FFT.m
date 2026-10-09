function figureHandle = plot_FFT(result, Fs)
    caseName = {'Ideal', 'Capacitor mismatch', 'Comparator offset', 'Finite op-amp gain'};
    figureHandle = figure('Color', 'w', 'Position', [100 100 1100 650]);
    tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    for caseIndex = 1:numel(caseName)
        axesHandle = nexttile;
        plot(axesHandle, result.f / 1e3, result.FFT_dBFS(:, caseIndex), 'b-', 'LineWidth', 1);
        xlim(axesHandle, [0 Fs / 2e3]);
        ylim(axesHandle, [-140 5]);
        set(axesHandle, 'FontName', 'Times New Roman', 'FontSize', 12, 'Box', 'off', 'TickDir', 'out');
        xlabel(axesHandle, 'Frequency (kHz)');
        ylabel(axesHandle, 'Power/bin (dBFS)');
        title(axesHandle, sprintf('%s: SINAD %.2f dB, ENOB %.2f', caseName{caseIndex}, result.SINAD(caseIndex), result.ENOB(caseIndex)));
    end

    saveSimulationFigure(figureHandle, 'ac_FFT');
end
