function output = tellme(name)
    chemin = 'null';
    if(nargin <1);
        % Like, no arguments
        disp('Error : Please, enter a sim ID string');
    elseif(nargin <2)
        chemin = ['results/' name '/'];
        if(~exist(chemin,'dir'))
            disp(['Could not find the results @ ' chemin]);
            pause
        else
            load(['results/' name '/session.mat']);
            
            disp('=== Simulation summary ===');
            disp('Device: ');
            disp(devices(2));
            disp('Parameters');
            disp(params);
            disp('Griding');
            disp(cbox);
        
        end
    end
    

end