%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%                    Practical method and its extension             %%%%
%%%%    after McKay et al. 2003 (JASA) and Francart et al. 2014 (JASA) %%%%
%%%%               coded and created by Florian Langner, M.Sc.         %%%%
%%%%                    at the Medical University Hanover              %%%%
%%%%                 Karl-Wiechert-Allee 3, 30625 Hannover             %%%%
%%%%                 email: langner.florian@mh-hannover.de             %%%%
%%%%      Website: https://auditoryprostheticgroup.weebly.com/blog     %%%%
%%%%            February 2019; Last revision: 25-February-2019         %%%%
%%%%                                                                   %%%%
%%%% McKay, C.M., Henshall, K.R., Farrell, R.J., McDermott, H.J., 2003.%%%%
%%%% A practical method of predicting the loudness of complex          %%%%
%%%% electrical stimuli. J. Acoust. Soc. Am. 113, 2054–2063.           %%%%
%%%% doi:10.1121/1.1558378                                             %%%%
%%%%                                                                   %%%%
%%%% Francart, T., Innes-Brown, H., McDermott, H.J., McKay, C.M., 2014.%%%%
%%%% Loudness of time-varying stimuli with electric stimulation.       %%%%
%%%% J. Acoust. Soc. Am. 135, 3513–9. doi:10.1121/1.4874597            %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% The model can be used to predict loudness based on a reference stimulus
% that is set to a desired sone (loudness) value (e.g. 16 sone, which
% should correspond to comfortable loudness). To set a reference, use the
% constant 'Const' to set the output of the model to 16 sone. Keep the 
% constant and use another Filename (another stimulation strategy) with 
% the same sound input and see what changed in terms of loudness.
% 
% The electrodograms used as input have 16 rows (representing the
% electrodes). Each column represents one pulse length (e.g. 18 µs), so the
% total length of an electrodogram depends on the length of the desired
% signal to be used with a sound coding strategy. Please note that the
% extension used in the code (ParallelStimConvert) uses the aspects of
% distance and ratio according to the manuscript, called variant DR,
% derived from figure 8.
% 
%                                                   Florian Langner,
%                                                   25.02.19

%% prepare data 
addpath 'examples\'
Filename = 'F120_Paired2_CCITT.mat';
load(Filename)
Electrodogram = elData;

PhaseWidth = 25; % Cochlear Ltd. standard
Reduction = 3.4; % this variable shows the difference in dB with respect 
               % to the reference. If a very large sone value is reached
               % with a simultaneous stimulation strategy, try something
               % like 3 dB. 

% Normalize to PhaseWidth
Electrodogram = (Electrodogram * updateIntervalUs) / PhaseWidth; 

% Make sure that no negative values are present 
Electrodogram(Electrodogram < 0) = 0; 

% Convert the M-by-16 matrix into something more readable
[ConvertedMatrix, ElectrodesUsed] = MatrixConversion( Electrodogram ); 

% Determine highest current per channel and declare it most comfortable level
MCL = max( Electrodogram ); 

% Determine smallest current per channel and declare it threshold
THL = min( Electrodogram ); 

% use current compensation if simultaneous/parallel stimulation is used 
% (here it is depending on the keyword "Paired" in Filename)
if strfind(Filename, 'Paired') > 0
    % apply the reduction declared in line 44
    ConvertedMatrix = 10.^((20*log10(ConvertedMatrix)-Reduction)/20);
    
    % use the new extension by compensating the current
    StimulationData = ParallelStimConvert(ConvertedMatrix, Filename, ...
                                                 ElectrodesUsed, MCL, THL);
else
    % convert to Cochlear CL units
    StimulationData = I2CL(ConvertedMatrix(1,:));
    
    % make sure that the CL units stay in the range of 1 and 255
    StimulationData(StimulationData < 0) = 0; 
    StimulationData(StimulationData > 255) = 255; 
end

%% loudness model 
% load loudness model variables 
% (explained in the LoudnessGrowthConversion function)
LinSlope = 14.3; Kneepoint = 174; ExpSlope = .019; 
CurrRange = 0:255; Const = -3.985; 
IndLoudnessContribs = LoudnessGrowthConversion(round(StimulationData), ...
                      ExpSlope, LinSlope, Kneepoint, CurrRange, Const);

% create the temporal integration windows and integrate for the first
% loudness estimated after McKay et al. 2003 (JASA)
WindowLength = .002; % temporal integration window length
InitialLoudness = CreateWindowedMatrix(IndLoudnessContribs, ...
                                StimulationData, WindowLength, PhaseWidth);

% use the initial loudness as instantaneous loudness in the formulas used
% for calculation of short-term loudness in Glasberg & Moore 2002 (JAES)
STLoudness = InstLoudness2STLoudness(InitialLoudness, WindowLength);

% compute long-term loudness from short-term loudness
LTLoudness = STLoudness2LTLoudness(STLoudness, WindowLength);

% average the loudness as the final output and loudness estimate after
% Francart et al. 2014 (JASA)
Loudness = round(mean(LTLoudness),1);
fprintf('Loudness estimate: %.1f sone\n',Loudness);
