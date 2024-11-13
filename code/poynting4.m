function poynting4( name, freq)

chemin = 'null';
    if(nargin <1);
        % Like, no arguments
        disp('Error : Please, enter a sim ID string');
        pause
    elseif(nargin <3)
        chemin = ['results/' name '/'];
        if(~exist(chemin,'dir'))
            disp(['Could not find the results @ ' chemin]);
            pause
        else
            load(['results/' name '/session.mat']);
            chemin_p = [ chemin 'Poynting/'];
            if(~exist(chemin_p,'dir'))
                disp('Could not find poynting vectors for the sim. Do not forget to specify cmpt poynting in input.');
                pause
            end        
        end
    end
    figure
    Index = dlmread([chemin 'IndexMap.cheese']);


    
    poynting_x = -DFT.Ez(1:end-1,1:end-1,:).*conj(DFT.Hy(:,1:end-1,:));
    %poynting_x = zeros(size(poynting_x));
    
 
    poynting_y = DFT.Ez(1:end-1,1:end-1,:).*conj(DFT.Hx(1:end-1,:,:));
    %poynting_y = zeros(size(poynting_y));
    norm_poynting = abs(sqrt(poynting_x.^2+poynting_y.^2));
    imagesc(real(norm_poynting(:,:,freq)));
    hold on
    axisX = 1:5:cbox.nx-1;
    axisY = 1:5:cbox.ny-1;
    [poynting_y]=(downresolve(poynting_y(:,:,freq),axisX, axisY));
    [poynting_x]=(downresolve(poynting_x(:,:,freq),axisX, axisY));
    poynting_x =real(10*poynting_x/mean(mean(abs(poynting_x)))); 
    poynting_y =real(10*poynting_y/mean(mean(abs(poynting_y)))); 
    quiver(axisY,axisX,poynting_y,poynting_x,'k');
    contour(Index,[0.5 0.5],'g');
    colormap hot
    end