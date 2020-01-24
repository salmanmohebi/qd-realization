function matlabRtNetRunTimeTab = getMatlabNetRunTimeTab(rtNetResults)

matlabRtNetRunTimeTab  = table();
for i = 1:length(rtNetResults)
    scenarioTab = getScenarioTab(rtNetResults(i).scenario);
    scenarioTab.matlabRtNetSimTime = rtNetResults(i).fullSimTime;
    
    matlabRtNetRunTimeTab = [matlabRtNetRunTimeTab; scenarioTab];
end

end