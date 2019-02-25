
function CL = I2CL(I)
% Converts current in µA to clinical levels of Cochlear (range 1-255).
% 
% Syntax:  CL = I2CL(I)
%
% Inputs:
%    I  - matrix or array with electric current values in µA
%
% Outputs:
%    CL - matrix or array with Cochlear clinical units
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

CL = ( 255 / 2 ) * log10( I / 17.5 );

% eof