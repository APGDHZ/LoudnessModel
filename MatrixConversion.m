
function [ConvertedMatrix, ElectrodesUsed] = MatrixConversion(Electrodogram)
% Converse the electrodogram to a 2xN matrix in which electrode pairs are
% summed up to one current source. If only one electrode pair is active,
% leave the second line untouched (= 0). 
% 
% Syntax:  [ConvertedMatrix, ElectrodesUsed] = MatrixConversion(Electrodogram)
%
% Inputs:
%    Electrodogram  - electric current values per channel across time
%
% Outputs:
%    ConvertedMatrix - 2-by-N matrix with electric current in µA across time
%    ElectrodesUsed - position of the stimulating electrodes (1-16)
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

Electrodes = zeros(length(Electrodogram),4); 
ElectrodesUsed = zeros(length(Electrodogram),4);

for i = 1:length(Electrodes)
    
    Peaks = find(Electrodogram(i,:));
    
    % if no stimulation, leave column empty
    if isempty(Peaks) == 1 
        Electrodes(i,:) = 0;
        
    % if one electrode is active
    elseif length(Peaks) == 1 
        Electrodes(i,1) = Electrodogram(i,Peaks);
        
    % if one channel is active
    elseif length(Peaks) == 2 
        Order = diff(Peaks);
        % check the order to correctly place the currents
        if Order(1) == 1 
            Electrodes(i,1:2) = Electrodogram(i,Peaks);
        else
            % first channel active with only one electrode
            Electrodes(i,1) = Electrodogram(i,Peaks(1));
            % second channel active with only one electrode
            Electrodes(i,3) = Electrodogram(i,Peaks(2)); 
            ElectrodesUsed(i,1) = Peaks(1); ElectrodesUsed(i,3) = Peaks(2);
        end
    
    % if three electrodes are active
    elseif length(Peaks) == 3 
        Order = diff(Peaks);
        % check the order to correctly place the currents
        if Order(1) == 1 
            % second channel active with only one electrode
            Electrodes(i,1:3) = Electrodogram(i,Peaks); 
            ElectrodesUsed(i,1:3) = Peaks;
        else
            % first channel active with only one electrode
            Electrodes(i,2:4) = Electrodogram(i,Peaks);
            ElectrodesUsed(i,2:4) = Peaks;
        end
        
    % if all four electrodes are active    
    else
        Electrodes(i,:) = Electrodogram(i,Peaks); 
        ElectrodesUsed(i,:) = Peaks;
    end
end

% add individual currents to a channel
ConvertedMatrix = [Electrodes(:,1)+Electrodes(:,2) ...
                                       Electrodes(:,3)+Electrodes(:,4)]';
ElectrodesUsed = [(ElectrodesUsed(:,1)+ElectrodesUsed(:,2))/2 ...
                            (ElectrodesUsed(:,3)+ElectrodesUsed(:,4))/2];
ElectrodesUsed(find(ElectrodesUsed == 0.5)) = 1;

% eof