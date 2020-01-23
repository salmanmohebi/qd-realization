function tab = getScenarioTab(scenario)

t = regexp(scenario, 'refl(.+)_qd(.+)_relTh(.+)_floor(.+)', 'tokens');

totalNumberOfReflections = str2double(t{1}{1});
switchQDGenerator = str2double(t{1}{2});
minRelativePathGainThreshold = str2double(t{1}{3});
floorMaterial = string(t{1}{4});

tab = table(totalNumberOfReflections, switchQDGenerator, minRelativePathGainThreshold, floorMaterial);

end