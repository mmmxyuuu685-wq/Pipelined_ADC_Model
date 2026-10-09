function saveSimulationFigure(figureHandle, figureName)
    projectDirectory = fileparts(mfilename('fullpath'));
    resultsDirectory = fullfile(projectDirectory, 'simulation_results');
    if ~isfolder(resultsDirectory)
        mkdir(resultsDirectory);
    end

    exportgraphics(figureHandle, fullfile(resultsDirectory, [figureName '.png']), 'Resolution', 200);
    savefig(figureHandle, fullfile(resultsDirectory, [figureName '.fig']));
end
