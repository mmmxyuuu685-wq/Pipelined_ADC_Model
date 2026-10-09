function [code, bits, residues] = pipelineADC(vin, stages)
    nBits = numel(stages);
    residues = zeros(numel(vin), nBits);
    residues(:, 1) = vin(:);
    bits = zeros(numel(vin), nBits);

    for stageIndex = 1:nBits - 1
        [residues(:, stageIndex + 1), bits(:, stageIndex)] = mdacStage(residues(:, stageIndex), stages(stageIndex));
    end

    bits(:, nBits) = double(residues(:, nBits) >= stages(nBits).Vref / 2 + stages(nBits).Vos);
    code = bits * (2.^(nBits - 1:-1:0)).';
end
