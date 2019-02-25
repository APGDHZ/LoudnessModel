function [InitialLoudness] = CreateWindowedMatrix(IndLoudnessContribs, ...
                                    StimulationData, WindowLength, PhaseWidth)
% Creates a temporal integration with an integration window of given
% length.
% 
% Syntax:  [ConvertedMatrix, ElectrodesUsed] = MatrixConversion(Electrodogram)
%
% Inputs:
%    IndLoudnessContribs  - vector with individual loudness contributions
%    StimulationData  - original data vector with electric current
%    WindowLength  - temporal integration window length
%    PhaseWidth  - phase width of Cochlear Ltd.
%
% Outputs:
%    InitialLoudness - loudness estimate according to McKay et al. 2003
%
% Other m-files required: LoudnessGrowthConversion
% Subfunctions: none
% MAT-files required: none
%
% Author: Florian Langner
% Karl-Wiechert-Allee 3, 30625 Hannover
% email: langner.florian@mh-hannover.de
% Website: https://auditoryprostheticgroup.weebly.com/blog
% February 2019; Last revision: 25-February-2019
%------------------------ BEGIN CODE --------------------------

Stepsize = round((10^6*WindowLength)/PhaseWidth);
InitialLoudness = zeros(floor(length(StimulationData)/Stepsize),1);
Steps = 1:Stepsize:length(StimulationData);

for j = 1:length(InitialLoudness)
    if j < length(InitialLoudness)
        % place the current value on the specific electrode location
        InitialLoudness(j,1) = sum(IndLoudnessContribs(Steps(j):Steps(j+1)));  
    else
        % last window is the same as the second to last since we 
        % can't access the last entry + 1
        InitialLoudness(j,1) = InitialLoudness(j-1,1);  
    end                                 
end

% eof