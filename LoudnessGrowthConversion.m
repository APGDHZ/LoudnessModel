function [IndLoudnessContribs] = LoudnessGrowthConversion(Currents, ...
                            LinSlope, ExpSlope, Kneepoint, CurrRange, Const) 
% Converts the electric current values in µA to loudness contributions 
% in log loudness via a loudness growth function (LGF).
% 
% Syntax:  [IndLoudnessContribs] = LoudnessGrowthConversion(Currents, ...
%                          LinSlope, ExpSlope, Kneepoint, CurrRange, Const) 
%
% Inputs:
%    Currents  - electric current values across time
%    LinSlope  - slope of the linear part of the LGF
%    ExpSlope  - slope of the exponential part of the LGF
%    Kneepoint - kneepoint for the transition between linear and exp. part
%    CurrRange - electric current range (1 - 255 for Cochlear Ltd.)
%    Const     - constant for adjusting the reference
%
% Outputs:
%    IndLoudnessContribs - individual loudness contributions across time
%
% Example: 
%    b = 14.3; c_0 = 174; T_win = .002; a = .019; c_s = 0; c_e = 255; 
%    EDF = AddLoudnessGrowth(round(DataNew), a, b, c_0, c_s:1:c_e, k);
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Author: Florian Langner
% Karl-Wiechert-Allee 3, 30625 Hannover
% email: langner.florian@mh-hannover.de
% Website: https://auditoryprostheticgroup.weebly.com/blog
% February 2019; Last revision: 25-February-2019

%------------------------ BEGIN CODE --------------------------

% loudness growth function (LGF) from McKay et al. 2003 (JASA)
LGF = 10.^(LinSlope * CurrRange + 0.03 * ExpSlope * ...
                        exp( (CurrRange - Kneepoint) / ExpSlope ) + Const);
                    
% LGF = a * c + k; % if the linear part of the equation is desired

% convert the current values to the loudness contribution value of the LGF
IndLoudnessContribs = zeros(1,size(Currents,2));
for i = 1:size(Currents,2)
         if Currents(1,i) == 0 
             IndLoudnessContribs(1,i) = LGF(1);
         else
             IndLoudnessContribs(1,i) = LGF(Currents(1,i)); 
         end
end

% eof