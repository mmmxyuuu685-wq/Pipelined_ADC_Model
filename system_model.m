stagesIdeal = repmat(pIdeal, 1, Nbits);

stagesMismatch = stagesIdeal;
stagesMismatch(1) = pMismatch;

stagesOffset = stagesIdeal;
stagesOffset(1) = pOffset;

stagesFinite = stagesIdeal;
stagesFinite(1) = pFinite;

model.mdacStage = @mdacStage;
model.pipelineADC = @pipelineADC;
