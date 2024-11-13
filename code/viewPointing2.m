function  viewPointing2( name )
%VIEWPOINTING Displays the poynting vectors map
%   This version of viewPointing iterated over frequencies instead of time

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
            chemin_p = [ chemin 'Poynting/'];
            if(~exist(chemin_p,'dir'))
                disp('Could not find poynting vectors for the sim. Do not forget to specify cmpt poynting in input.');
                pause
            end        
        end
    end

    [instant_poynting_x,instant_poynting_y]=loadFields(params,STEPS,chemin_p,TFSF);
    fig = figure;
    set(fig,'Name','Most epic matlab poynting visualizer','MenuBar','none',...
        'NumberTitle','off','Color',[0.1 0.15 0.15]);
    wl_field = uicontrol('Parent',fig,'Style','edit',...
        'String','200','Units','normalized', ...
        'Position',[0.0 0.0 0.1 0.04],'Visible','on',...
        'BackgroundColor','r');
    wl_confirm=uicontrol('Parent',fig,'Style','pushbutton',...
        'String','Search','Units','normalized', ...
        'Position',[0.1 0.0 0.1 0.04],'Visible','on',...
        'BackgroundColor','w');
   
    % +++ Load epsilon data
    ER = dlmread([chemin 'IndexMap.cheese']);
    ER(1,1)=1.001; % Ensure we don't get warnings spam even for uniform epsilon
    
    axisX = 1:5:cbox.nx-1;
    axisY = 1:5:cbox.ny-1;
    
     wl_confirm.Callback = @(es,ed) ...
         render(ER, str2double(get(wl_field,'String')),...
         axisX,axisY,params,DFT,TFSF,cbox,STEPS,...
         instant_poynting_x,instant_poynting_y,K);
    render(ER, 300,axisX,axisY,params,DFT,TFSF,cbox,STEPS,instant_poynting_x,instant_poynting_y,K);
    
    
end

function render(ER, wl,axisX,axisY,params,DFT,TFSF,cbox,STEPS,instant_poynting_x,instant_poynting_y,K)
    % ++ Let's find the closest angular frequency we computed in the sim
    disp(['Showing closest wavelength to: ' num2str(wl) 'nm']);
    c0=300000000;
    f = (c0/(wl*1e-9));
    [~, wl_ind] = min(abs(DFT.frequency-f));
    
    
    poynting_x_int = zeros(length(cbox.nx),length(cbox.ny));
    poynting_y_int = zeros(length(cbox.nx),length(cbox.ny));
    TT = 1;
    for T=params.SAVE_CNST:params.SAVE_CNST:STEPS
        poynting_x_int = poynting_x_int + real(instant_poynting_x(:,:,TT).*(K(wl_ind)^T));
        poynting_y_int = poynting_y_int + real(instant_poynting_y(:,:,TT).*(K(wl_ind)^T));
        TT=TT+1;   
    end
    norm_poynting  = real(sqrt(poynting_x_int.^2 + poynting_y_int.^2));
    
    hold off
    imagesc(real(norm_poynting)); 
    hold on
    quiver(axisX,axisY,poynting_x_int(axisX),poynting_y_int(axisY));
    contour(ER,[0.5 0.5],'w');
    colormap hot
    rectangle('Position',[cbox.NPML cbox.NPML cbox.ny-2*cbox.NPML cbox.nx-2*cbox.NPML],'FaceColor','none','LineStyle',':');
    rectangle('Position',[TFSF.ny_a TFSF.nx_a TFSF.ny_b-TFSF.ny_a+2 TFSF.nx_b-TFSF.nx_a],'FaceColor','none','LineStyle',':');
end

function [instant_poynting_x,instant_poynting_y]=loadFields(params,STEPS,chemin_p,TFSF)
    progress = waitbar(0, 'Loading fields from filesystem.');
    TT=1;
    for T=params.SAVE_CNST:params.SAVE_CNST:STEPS
        load([chemin_p 'S' num2str(T) '.mat']);
        for j= TFSF.ny_a+1:TFSF.ny_b+1
            PointingX(TFSF.nx_a+1:TFSF.nx_b,j)=(PointingX(TFSF.nx_a+1:TFSF.nx_b,j))+PointingSource(TFSF.nx_a+1:TFSF.nx_b);
        end
        instant_poynting_x(:,:,TT) = PointingX;
        instant_poynting_y(:,:,TT) = PointingY;
        TT=TT+1;
        waitbar(T/STEPS,progress);
    end
    close(progress);
end