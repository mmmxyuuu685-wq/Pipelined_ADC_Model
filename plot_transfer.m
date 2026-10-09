function figureHandle = plot_transfer(Vin, codeIdeal, codeMismatch, codeOffset, codeFinite, VREF, Nbits)
    figureHandle = figure('Color', 'w', 'Position', [100 100 1200 380]);
    tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    codes = {codeMismatch, codeOffset, codeFinite};
    panelTitle = {'(a) Capacitor mismatch', '(b) Comparator offset', '(c) Finite op-amp gain'};

    for panelIndex = 1:numel(codes)
        axesHandle = nexttile;
        stairs(axesHandle, Vin, codeIdeal, 'k--', 'LineWidth', 1.2);
        hold(axesHandle, 'on');
        stairs(axesHandle, Vin, codes{panelIndex}, 'b-', 'LineWidth', 1.2);
        xlim(axesHandle, [0 VREF]);
        ylim(axesHandle, [0 2^Nbits - 1]);
        set(axesHandle, 'FontName', 'Times New Roman', 'FontSize', 12, 'Box', 'off', 'TickDir', 'out');
        xlabel(axesHandle, 'V_{in} (V)');
        ylabel(axesHandle, 'Output code');
        title(axesHandle, panelTitle{panelIndex});
        legend(axesHandle, 'Ideal', 'Nonideal', 'Location', 'southoutside', 'Orientation', 'horizontal', 'Box', 'off');
    end

    saveSimulationFigure(figureHandle, 'dc_transfer');
end
