function writeQdFile(qdFile, filepath, precision)
fid = fopen(filepath, 'Wt');

for t = 1:length(qdFile)
    dopplerShifts = zeros(size(qdFile(t).delay));
    output = fillOutputQd(qdFile(t).delay, qdFile(t).pathGain,...
        qdFile(t).aodAz, qdFile(t).aodEl, qdFile(t).aoaAz,...
        qdFile(t).aoaEl, qdFile(t).phaseOffset, dopplerShifts);
    writeQdFileOutput(output, true, fid, 1, 1, filepath, precision); % TODO: improve fid handling
end

fclose(fid);

end