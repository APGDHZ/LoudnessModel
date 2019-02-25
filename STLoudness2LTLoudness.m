function LTLoudness = STLoudness2LTLoudness(STLoudness, WindowLength)
% computes the long term loudness (LTL) from the short term one. WindowLength 
% is the time interval between two sucessive loudness values in ms
% 
% Syntax:  LTLoudness = STLoudness2LTLoudness(STLoudness, WindowLength)
%
% Inputs:
%    STLoudness  - short-term loudness vector
%    WindowLength  - temporal integration window length
%
% Outputs:
%    LTLoudness - long-term loudness vector
%
% Other m-files required: InstLoudness2STLoudness
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

% the first value is equeal to the origimal instantaneous loudness
LTLoudness = zeros(length(STLoudness),1);
LTLoudness(1) = AttackTime * STLoudness(1);

for n = 2:length(STLoudness)
   % Attack
   if STLoudness(n) > LTLoudness(n-1) 
       LTLoudness(n) = AttackTime * STLoudness(n) + ...
                       (1 - AttackTime) * LTLoudness(n - 1);
   % Release
   else    
       LTLoudness(n) = ReleaseTime * STLoudness(n) + ...
                       (1 - ReleaseTime) * LTLoudness(n - 1);
   end 
end

% eof