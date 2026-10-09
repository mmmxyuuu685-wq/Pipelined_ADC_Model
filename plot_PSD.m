function figureHandle = plot_PSD(result, Fs)
    caseName = {'Ideal', 'Capacitor mismatch', 'Comparator offset', 'Finite op-amp gain'};
    figureHandle = figure('Color', 'w', 'Position', [100 100 1100 650]);
    tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    for caseIndex = 1:numel(caseName)
        axesHandle = nexttile;
        plot(axesHandle, result.f / 1e3, 10 * log10(max(result.PSD(:, caseIndex), realmin)), 'b-', 'LineWidth', 1);
        xlim(axesHandle, [0 Fs / 2e3]);
        ylim(axesHandle, 10 * log10(max(result.PSD(:))) + [-120 5]);
        set(axesHandle, 'FontName', 'Times New Roman', 'FontSize', 12, 'Box', 'off', 'TickDir', 'out');
        xlabel(axesHandle, 'Frequency (kHz)');
        ylabel(axesHandle, 'PSD (dB re 1 V^2/Hz)');
        title(axesHandle, caseName{caseIndex});
    end

    saveSimulationFigure(figureHandle, 'ac_PSD');
end
