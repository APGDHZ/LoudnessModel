function StimulationData = ParallelStimConvert(ConvertedMatrix, Filename, ...
                                                    ElectrodesUsed, MCL, THL)
% converts a two channel stimulus into a one channel stimulus with the current 
% resulting in the same perceived loudness
% 
% Syntax:  ParallelStimConvert(ConvertedMatrix, Filename, ...
%                                                   ElectrodesUsed, MCL, THL)
%
% Inputs:
%    ConvertedMatrix  - 2-by-N matrix with electric current in µA across time
%    Filename  - name of the file with keyword "Paired"
%    ElectrodesUsed  - ElectrodesUsedition of stimulating electrodes from ConvertedMatrix
%    MCL  - highest current across matrix
%    THL  - smallest current across matrix
%
% Outputs:
%    StimulationData - 1-by-N matrix with current compensated 
%                      electric current across time
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

% load current compensation function variables
x = 4.913; y = 0.24; SimLGF = y.*(0:1:12)-x;

% use the base current compensation which is altered later depending on the
% current ratio between channels and the place of stimulation
if strfind(Filename,'Paired2') > 0
    Compensation = SimLGF(2); 
elseif strfind(Filename,'Paired4') > 0
    Compensation = SimLGF(4); 
elseif strfind(Filename,'Paired6') > 0
    Compensation = SimLGF(6); 
else
    Compensation = SimLGF(8);
end

% functions for current ratios from Exp. 3 according to equation 6
RatioFunctionBelow25 = -0.0537*(0.01:0.01:0.24);
RatioFunctionFromExp = -1.342-0.0115*(0:0.01:0.5);
RatioFunctionAbove75 = (((Compensation + 1.919) / (1 - 0.75)) * ((0.76:0.01:0.99) - 0.75) - 1.919)*-1;

% divide the matrix if you want to process it with parfor
q1 = ConvertedMatrix(1,:); q2 = ConvertedMatrix(2,:);
StimulationData = zeros(1,length(ConvertedMatrix)); % pre-allocate vector

% convert the µA current to Cochlear units and add the current compensation
% based on the 
for i = 1:length(ConvertedMatrix)
    
    % when the channel is not stimulated skip it
    if q1(i) == 0                    
        StimulationData(1,i) = 0;
        
    % if we have single channel stimulation
    elseif q1(i) > 0 && q2(i) == 0  
        StimulationData(1,i) = q1(i);
        
    % if we have simultaneous stimulation
    elseif q1(i) > 0 && q2(i) > 0    
        
        % if stimulation in the first channel has a higher current than the second
        if q1(i) > q2(i)
            if mod(ElectrodesUsed(i,1),1) ~= 0 && mod(ElectrodesUsed(i,2),1) ~= 0
                
                % get the % dynamic range of the current of the first channel
                Perc1 = 100/(mean([MCL(ElectrodesUsed(i,1)-.5) MCL(ElectrodesUsed(i,1)+.5)]));
                THL1 = mean([THL(ElectrodesUsed(i,1)-.5) THL(ElectrodesUsed(i,1)+.5)]);
                PointDR1 = (q1(i)-THL1)*Perc1;
                
                % get the % dynamic range of the current of the second channel
                Perc2 = 100/(mean([MCL(ElectrodesUsed(i,2)-.5) MCL(ElectrodesUsed(i,2)+.5)]));
                THL2 = mean([THL(ElectrodesUsed(i,2)-.5) THL(ElectrodesUsed(i,2)+.5)]);
                PointDR2 = (q2(i)-THL2)*Perc2;
               
            elseif mod(ElectrodesUsed(i,1),1) == 0 && mod(ElectrodesUsed(i,2),1) ~= 0
                Perc1 = 100/MCL(ElectrodesUsed(i,1));
                THL1 = THL(ElectrodesUsed(i,1));
                PointDR1 = (q1(i)-THL1)*Perc1;
                
                Perc2 = 100/(mean([MCL(ElectrodesUsed(i,2)-.5) MCL(ElectrodesUsed(i,2)+.5)]));
                THL2 = mean([THL(ElectrodesUsed(i,2)-.5) THL(ElectrodesUsed(i,2)+.5)]);
                PointDR2 = (q2(i)-THL2)*Perc2;
                
            elseif mod(ElectrodesUsed(i,1),1) ~= 0 && mod(ElectrodesUsed(i,2),1) == 0
                Perc1 = 100/(mean([MCL(ElectrodesUsed(i,1)-.5) MCL(ElectrodesUsed(i,1)+.5)]));
                THL1 = mean([THL(ElectrodesUsed(i,1)-.5) THL(ElectrodesUsed(i,1)+.5)]);
                PointDR1 = (q1(i)-THL1)*Perc1;
                
                Perc2 = 100/MCL(ElectrodesUsed(i,2));
                THL2 = THL(ElectrodesUsed(i,2));
                PointDR2 = (q2(i)-THL2)*Perc2;
                
            else
                Perc1 = 100/MCL(ElectrodesUsed(i,1));
                THL1 = THL(ElectrodesUsed(i,1));
                PointDR1 = (q1(i)-THL1)*Perc1;
                
                Perc2 = 100/MCL(ElectrodesUsed(i,2));
                THL2 = THL(ElectrodesUsed(i,2));
                PointDR2 = (q2(i)-THL2)*Perc2;
                
            end
            % calculate the dynamic range ratio between the dual-channels
            if PointDR1 > PointDR2; RealRatio = 100-floor(round(PointDR2/PointDR1,2)*100);
                else; RealRatio = 100-floor(round(PointDR1/PointDR2,2)*100); end

            % apply compensation and reduce depending on the current ratio
            if RealRatio == 0
                StimulationData(1,i) = 20*log10(q1(i)) - Compensation;
            elseif RealRatio == 100
                StimulationData(1,i) = 20*log10(q1(i));
            elseif RealRatio <= 24
                StimulationData(1,i) = 20*log10(q1(i)) - Compensation + RatioFunctionBelow25(RealRatio);
            elseif RealRatio >= 25 && RealRatio <= 75
                StimulationData(1,i) = 20*log10(q1(i)) - Compensation + RatioFunctionFromExp(RealRatio-24);
            elseif RealRatio > 75
                StimulationData(1,i) = 20*log10(q1(i)) - Compensation - RatioFunctionAbove75(RealRatio-75);
            end
        % if stimulation in the second channel has a higher current than the first
        else
            if mod(ElectrodesUsed(i,1),1) ~= 0 && mod(ElectrodesUsed(i,2),1) ~= 0
                Perc1 = 100/(mean([MCL(ElectrodesUsed(i,1)-.5) MCL(ElectrodesUsed(i,1)+.5)]));
                THL1 = mean([THL(ElectrodesUsed(i,1)-.5) THL(ElectrodesUsed(i,1)+.5)]);
                PointDR1 = (q1(i)-THL1)*Perc1;
                
                Perc2 = 100/(mean([MCL(ElectrodesUsed(i,2)-.5) MCL(ElectrodesUsed(i,2)+.5)]));
                THL2 = mean([THL(ElectrodesUsed(i,2)-.5) THL(ElectrodesUsed(i,2)+.5)]);
                PointDR2 = (q2(i)-THL2)*Perc2;

            elseif mod(ElectrodesUsed(i,1),1) == 0 && mod(ElectrodesUsed(i,2),1) ~= 0
                Perc1 = 100/MCL(ElectrodesUsed(i,1));
                THL1 = THL(ElectrodesUsed(i,1));
                PointDR1 = (q1(i)-THL1)*Perc1;
                
                Perc2 = 100/(mean([MCL(ElectrodesUsed(i,2)-.5) MCL(ElectrodesUsed(i,2)+.5)]));
                THL2 = mean([THL(ElectrodesUsed(i,2)-.5) THL(ElectrodesUsed(i,2)+.5)]);
                PointDR2 = (q2(i)-THL2)*Perc2;

            elseif mod(ElectrodesUsed(i,1),1) ~= 0 && mod(ElectrodesUsed(i,2),1) == 0
                Perc1 = 100/(mean([MCL(ElectrodesUsed(i,1)-.5) MCL(ElectrodesUsed(i,1)+.5)]));
                THL1 = mean([THL(ElectrodesUsed(i,1)-.5) THL(ElectrodesUsed(i,1)+.5)]);
                PointDR1 = (q1(i)-THL1)*Perc1;
                
                Perc2 = 100/MCL(ElectrodesUsed(i,2));
                THL2 = THL(ElectrodesUsed(i,2));
                PointDR2 = (q2(i)-THL2)*Perc2;

            else
                Perc1 = 100/MCL(ElectrodesUsed(i,1));
                THL1 = THL(ElectrodesUsed(i,1));
                PointDR1 = (q1(i)-THL1)*Perc1;
                
                Perc2 = 100/MCL(ElectrodesUsed(i,2));
                THL2 = THL(ElectrodesUsed(i,2));
                PointDR2 = (q2(i)-THL2)*Perc2;
            end
            
                % calculate the dynamic range ratio between the dual-channels
                if PointDR1 > PointDR2; RealRatio = 100-floor(round(PointDR2/PointDR1,2)*100);
                else; RealRatio = 100-floor(round(PointDR1/PointDR2,2)*100); end
                
                % apply compensation and reduce depending on the current ratio
                if RealRatio == 0
                    StimulationData(1,i) = 20*log10(q1(i)) - Compensation;
                elseif RealRatio == 100
                    StimulationData(1,i) = 20*log10(q1(i));
                elseif RealRatio <= 24
                    StimulationData(1,i) = 20*log10(q1(i)) - Compensation + RatioFunctionBelow25(RealRatio);
                elseif RealRatio >= 25 && RealRatio <= 75
                    StimulationData(1,i) = 20*log10(q1(i)) - Compensation + RatioFunctionFromExp(RealRatio-24);
                elseif RealRatio > 75
                    StimulationData(1,i) = 20*log10(q1(i)) - Compensation - RatioFunctionAbove75(RealRatio-75);
                end
        end
        % return from dB to µA
        StimulationData(1,i) = 10.^(StimulationData(1,i)/20);
    end
end

% make sure that after converting the µA to Cochlear CL units, the values
% stay in the range of the system (1 - 255) which is usually the case
StimulationData = I2CL(StimulationData); 
StimulationData(StimulationData < 1) = 1; 
StimulationData(StimulationData > 255) = 255;

% eof