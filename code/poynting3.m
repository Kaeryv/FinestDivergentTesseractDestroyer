function [ha] =poynting3( name, wavelength)
%VIEWPOINTING Displays the poynting vectors map
%   This version of viewPointing is ultimate
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
    if(strcmp(source.method,'TFSF'))
        TFSF = source.TFSF;
    else
        TFSF = cbox.Domain;
    end
    disp(cbox.dx);
    % +++ Setup some gui stuff
    fig = figure;
    set(fig,'Name','Most epic matlab poynting visualizer',...
        'NumberTitle','off','Color',[0.1 0.15 0.15],...
        'units','normalized','outerposition',[0 0.1 1 0.8]);
        
    wl_field = uicontrol('Parent',fig,'Style','edit',...
        'String','200','Units','normalized', ...
        'Position',[0.0 0.0 0.1 0.04],'Visible','on',...
        'BackgroundColor','w');
    wl_confirm=uicontrol('Parent',fig,'Style','pushbutton',...
        'String','Search','Units','normalized', ...
        'Position',[0.1 0.0 0.1 0.04],'Visible','on',...
        'BackgroundColor','w');
    wl_pick=uicontrol('Parent',fig,'Style','pushbutton',...
        'String','Pick from spectrum','Units','normalized', ...
        'Position',[0.2 0.0 0.1 0.04],'Visible','on',...
        'BackgroundColor','w');
   
    % +++ Load epsilon data for displying the structure
    Index = dlmread([chemin 'IndexMap.cheese']);

    
    % +++ A callback to send render request when the button is pressed
    wl_confirm.Callback = @(es,ed) ...
        render(Index, str2double(get(wl_field,'String')),params,DFT,TFSF,cbox);
    % +++ A callback to pick wavelength from spectrum
    wl_pick.Callback = @(es,ed) ...
        pick_wl(name,Index,params,DFT,TFSF,...
        cbox,fig);
    
    % +++ Manage the argin possible wavelength
    if(nargin>1)
        % A wavelength is specified
        set(wl_field,'String',num2str(wavelength));
    else
        set(wl_field,'String',num2str(300));
    end
    
%     [ha,~] = tight_subplot(3,2,[.02 .00],[.05 .05],[.05 .05]);
%     axes(ha(1));    render(Index, 200,params,DFT,TFSF,cbox);
%     axes(ha(2));    
%     axes(ha(3));    render(Index, 300,params,DFT,TFSF,cbox);
%     axes(ha(5));    render(Index, 500,params,DFT,TFSF,cbox);
    
 

%     render(Index, 800,params,DFT,TFSF,cbox);
%     movie(name,Index,axisX,axisY,params,DFT,TFSF,cbox,STEPS,instant_poynting_x,instant_poynting_y,K,fig);

end

function render(Index, wl,params,DFT,TFSF,cbox)
    persistent poynting_x poynting_y 
    if(isempty(poynting_x))
        poynting_x = -DFT.Ez(1:end-1,2:end,:).*conj(DFT.Hy(:,1:end-1,:));
        poynting_y = DFT.Ez(1:end-1,1:end-1,:).*conj(DFT.Hx(1:end-1,:,:));
    end
    % +++ Let's find the closest angular frequency we computed in the sim
    disp(['Showing closest wavelength to: ' num2str(wl) 'nm']);
    [~, wl_ind] = min(abs((params.profile.wavelength/1e-9)-wl));
    

    norm_poynting = (sqrt(poynting_x.^2+poynting_y.^2));
    norm_poynting = abs(norm_poynting);
%     norm_poynting=sqrt(abs(DFT.Ez));
   %  norm_poynting=sqrt(abs(DFT.Hx(1:end-1,:,:).^2+DFT.Hy(:,1:end-1,:).^2));
    contourf(flipud(norm_poynting(:,:,wl_ind)),10);
    white_hot
% colormap hot
    hold on
    caxis([0 max(max(norm_poynting(:,:,wl_ind)))]);
    % +++ Create the subsampling axes ...
    % ++ Because it is more clear to display less arrows, bigger arrows
    % ++ that each represents one macrocell's poynting vector.
    axisX = 1:20:cbox.nx-1;
    axisY = 1:20:cbox.ny-1;
    % ++ Now computing the downresolve
    d_poynting_y=(downresolve(poynting_y(:,:,wl_ind),axisX, axisY));
    d_poynting_x=(downresolve(poynting_x(:,:,wl_ind),axisX, axisY));
%     d_poynting_y=(downresolve(DFT.Hy(:,1:end-1,wl_ind),axisX, axisY));
%     d_poynting_x=(downresolve(DFT.Hx(1:end-1,:,wl_ind),axisX, axisY));
    % ++ Now we divide the magnitudes by the mean magnitude
    d_poynting_x =real(10*d_poynting_x/mean(mean(abs(d_poynting_x)))); 
    d_poynting_y =real(10*d_poynting_y/mean(mean(abs(d_poynting_y)))); 
    nice_quiver(axisY,axisX,flipud(d_poynting_y),-flipud(d_poynting_x));
 
    contour(Index,[0.5 0.5],'g','EdgeColor',[0,0.5,0.1],'LineWidth',2);
    axis equal tight
    axis off
    rectangle('Position',[cbox.NPML cbox.NPML cbox.ny-2*cbox.NPML cbox.nx-2*cbox.NPML],'FaceColor','none','LineStyle',':','EdgeColor','w');
    rectangle('Position',[TFSF.ny_a TFSF.nx_a TFSF.ny_b-TFSF.ny_a+2 TFSF.nx_b-TFSF.nx_a],'FaceColor','none','LineStyle',':','EdgeColor','w');
%     title(['Poynting map for \lambda = ' num2str(params.profile.wavelength(wl_ind)/1e-9) ' nm'],'Color','w','FontName','Times');
end

function pick_wl(name,Index,params,DFT,TFSF,cbox,fig)
    fig2 = fourrierAnalyse(name);
    
    for e = params.profile.wavelength
        disp('Map disponible');
        hold on
        plot([e e]/1e-9,[0 1],'k:');
        drawnow
    end
    
    set(fig,'outerposition',[0 0.1 0.5 0.8])
    set(fig2,'units','normalized','outerposition',[0.5 0.1 0.5 0.8])
   
    while(1==1)
        set(0,'CurrentFigure',fig2);
        hold on
        try
            [lambdouille,~] = ginput(1);
        catch
            disp('Picker closed');
            break
        end
     

        set(0,'CurrentFigure',fig);
        render(Index, lambdouille,params,DFT,TFSF,cbox);
        
    end
    if(ishandle(fig2))
        close(fig2);
    end
end


