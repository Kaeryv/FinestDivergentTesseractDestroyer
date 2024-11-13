function [ DFT,Index,params,cbox,TFSF ] = getMap( name, wavelength )
%GETMAP Summary of this function goes here
%   Detailed explanation goes here
    addpath auxillary
    chemin = 'null';
   
    if(nargin <1);
        % Like, no arguments
        disp('Error : Please, enter a sim ID string');
        pause
    elseif(nargin <2)
        chemin = ['results/' name '/'];
        if(~exist(chemin,'dir'))
            disp(['Could not find the results @ ' chemin]);
            pause
        else
            load(['results/' name '/session.mat']);          
        end
    end
    Index = dlmread([chemin 'IndexMap.cheese']);
        if(strcmp(source.method,'TFSF'))
        TFSF = source.TFSF;
    else
        TFSF = cbox.Domain;
    end
    return

end

