function figureHandle = plot_Vres(Vin, VresIdeal, VresMismatch, VresOffset, finiteResidue, VREF)
    figureHandle = figure('Color', 'w', 'Position', [100 100 1200 380]);
    tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    residue = {VresMismatch, VresOffset, finiteResidue};
    panelTitle = {'(a) Capacitor mismatch', '(b) Comparator offset', '(c) Finite op-amp gain'};

    for panelIndex = 1:numel(residue)
        axesHandle = nexttile;
        plot(axesHandle, Vin, VresIdeal, 'k--', Vin, residue{panelIndex}, 'b-', 'LineWidth', 1.5);
        yline(axesHandle, VREF, ':', 'Color', [0.6 0.6 0.6], 'HandleVisibility', 'off');
        xlim(axesHandle, [0 VREF]);
        ylim(axesHandle, [-0.25 1.3] * VREF);
        set(axesHandle, 'FontName', 'Times New Roman', 'FontSize', 12, 'Box', 'off', 'TickDir', 'out');
        set(axesHandle, 'XTick', [0 0.5 1] * VREF, 'XTickLabel', {'0', 'V_{REF}/2', 'V_{REF}'}, 'YTick', [0 VREF], 'YTickLabel', {'0', 'V_{REF}'});
        xlabel(axesHandle, 'V_{in}');
        ylabel(axesHandle, 'V_{res}');
        title(axesHandle, panelTitle{panelIndex});
        legend(axesHandle, 'Ideal', 'Nonideal', 'Location', 'southoutside', 'Orientation', 'horizontal', 'Box', 'off');
    end

    saveSimulationFigure(figureHandle, 'Vres');
end
