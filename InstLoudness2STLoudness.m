function STLoudness = InstLoudness2STLoudness(InitialLoudness, WindowLength)
% Computes the short term loudness from the instantaneous one. WindowLength 
% is the time interval between two sucessive loudness values in ms.
% 
% Syntax:  STLoudness = InstLoudness2STLoudness(InitialLoudness, WindowLength)
%
% Inputs:
%    InitialLoudness  - loudness estimate as instantaneous loudness
%    WindowLength  - temporal integration window length
%
% Outputs:
%    STLoudness - short-term loudness vector
%
% Other m-files required: CreateWindowedMatrix
% Subfunctions: none
% MAT-files required: none
%
% Author: Florian Langner
% Karl-Wiechert-Allee 3, 30625 Hannover
% email: langner.florian@mh-hannover.de
% Website: https://auditoryprostheticgroup.weebly.com/blog
% February 2019; Last revision: 25-February-2019
%------------------------ BEGIN CODE --------------------------

WindowLength = WindowLength * 1000; % because windowlength is in seconds

% Attack and release constant from Glasberg & Moore 2002 (JAES)
AttackConst = -1 / (log(1 - 0.001));
ReleaseConst = -1 / (log(1 - 0.02));

% recalculate attack and release time considering the time between
% two loudness values based on knowledge of AttackConst and ReleaseConst
AttackTime = 1 - exp(-WindowLength / AttackConst);
ReleaseTime = 1 - exp(-WindowLength / ReleaseConst);

% the first value is equal to the original instantaneous loudness
STLoudness = zeros(length(InitialLoudness),1);
STLoudness(1) = AttackTime * InitialLoudness(1);

for n = 2:length(InitialLoudness)
   % Attack
   if InitialLoudness(n) > STLoudness(n-1)
       STLoudness(n) = AttackTime * InitialLoudness(n) + ...
                       (1-AttackTime) * STLoudness(n-1);
   % Release
   else
       STLoudness(n) = ReleaseTime * InitialLoudness(n) + ...
                       (1-ReleaseTime)*STLoudness(n-1);
   end 
end

% eof