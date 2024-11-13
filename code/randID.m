function [id] = randID()
% +++ Generating simulation Identifier
    simulationID = 1000000+ceil(1000000*rand()*rand());
    id = num2str(simulationID);
end