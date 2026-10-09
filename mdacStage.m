function [vout, decision] = mdacStage(vin, stage)
    capacitorRatio = stage.C2 / stage.C1;
    decision = double(vin >= stage.Vref / 2 + stage.Vos);
    vout = ((1 + capacitorRatio) .* vin - capacitorRatio .* decision * stage.Vref) / (1 + (1 + capacitorRatio) / stage.A0);
end
