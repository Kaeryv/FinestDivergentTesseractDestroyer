function viewMovie(name)
    global Mp5Player
    Mp5Player.playing = 1;
    Mp5Player.chemin = 'null';
    if(nargin <1);
        % Like, no arguments
        disp('Error : Please, enter a sim ID string');
        pause
        return
    elseif(nargin <2)
        chemin = ['results/' name '/'];
        if(~exist(chemin,'dir'))
            disp(['Could not find the results @ ' chemin]);
            pause
            return
        else
            load(['results/' name '/session.mat']);
        end
    end
    
    
   
    fig = figure;
    set(fig,'Name','Most epic matlab video player',...
        'NumberTitle','off','Color',[0.1 0.15 0.15]);
    colormap(redblue);
    % +++ Load epsilon data
    ER = dlmread([chemin 'IndexMap.cheese']);
    ER(1,1)=1.001; % Ensure we don't get warnings spam
    
    if(strcmp(source.type,'TFSF'))
        Domain = source.TFSF;
    else
        Domain = cbox.Domain;
    end
    
    Mp5Player.slider = uicontrol('Parent',fig,'Style','slider',...
        'Units','normalized','Position',[0.3,0,0.7,0.05],...
                  'value',0, 'min',0, 'max',1);

    Mp5Player.slider.Callback = @(es,ed) ... 
        render(ceil(1+es.Value*STEPS/params.SAVE_CNST)*params.SAVE_CNST,...
        chemin,ER,cbox.NPML,Domain,cbox.nx,cbox.ny); 
    set(Mp5Player.slider,'BackgroundColor',[.3 .4 .4]);
    Mp5Player.mTextBox = uicontrol('style','text','Units','normalized',...
        'Position',[0.1,0,0.2,0.05],'FontName','Courrier',...
        'FontWeight','bold','ForegroundColor','w', 'BackgroundColor',[0.1 0.15 0.15]);
    
    Mp5Player.Button1=uicontrol('Parent',fig,'Style','pushbutton',...
        'String','Stop','Units','normalized', ...
        'Position',[0.0 0.0 0.1 0.05],'Visible','on',...
        'BackgroundColor','r');
    Mp5Player.Button1.Callback = @(es,ed) cb_button1(); 

    Mp5Player.time=params.SAVE_CNST;
    
%     v = VideoWriter('whispering_out.avi');
%     open(v);
    
    while ishandle(fig)
        pause(0.01);
        if(Mp5Player.playing)
            if(~mod(Mp5Player.time,10))           
                try
                    render(Mp5Player.time,chemin,ER,cbox.NPML,Domain,cbox.nx,cbox.ny);
%                     axis equal tight
%                     writeVideo(v,getframe(gcf));
                    set(Mp5Player.slider,'value',Mp5Player.time/STEPS);
                    set(Mp5Player.mTextBox,'String',['Frame ' num2str(Mp5Player.time) ' over ' num2str(STEPS)]);
                   
                catch
                    fprintf('Closed by UI control\n')
                    return
                end
            end
            Mp5Player.time=Mp5Player.time+params.SAVE_CNST;
            if(Mp5Player.time>STEPS)
                Mp5Player.playing=0;
            end
        end
    end
%     subplot(2,2,1)
%     render(390,chemin,ER,cbox.NPML,Domain,cbox.nx,cbox.ny);
%         subplot(2,2,3)
%     render(640,chemin,ER,cbox.NPML,Domain,cbox.nx,cbox.ny);
%         subplot(2,2,2)
%     render(880,chemin,ER,cbox.NPML,Domain,cbox.nx,cbox.ny);
%             subplot(2,2,4)
%     render(1000,chemin,ER,cbox.NPML,Domain,cbox.nx,cbox.ny);
%         
%     close (v);
    

end

function render(time_set,chemin,ER,pml,Domain,Nx,Ny)
        global Mp5Player
        persistent oldmax
        if(isempty(oldmax))
            oldmax = 0.0;
        end
        Mp5Player.time = time_set;
        % Loading frame from file ( Choosed ram over speed, no need for
        % pause like follows ^^
        load([ chemin 'Ez' num2str(Mp5Player.time) '.mat']);     
        hold off
        contourf(ER,[0.5 0.5],'FaceColor','y');  % Dielectric
        hold on
        
        zemax = mean(mean(abs(Ez_host)));
        oldmax = max([oldmax, zemax]);
        imagesc((real(Ez_host)),'AlphaData',abs(Ez_host)/oldmax/5);
        
        
        set(gca,'XColor','w','YColor','w');
        rectangle('Position',[pml pml Ny-2*pml Nx-2*pml],'FaceColor','none','LineStyle',':','EdgeColor','k');
        rectangle('Position',[Domain.ny_a Domain.nx_a Domain.ny_b-Domain.ny_a Domain.nx_b-Domain.nx_a],'FaceColor','none','LineStyle',':','EdgeColor','k');
        text(pml,pml/2,'Perfectly matched layer','Color','k');
        text(Domain.ny_a,Domain.nx_b-(Domain.nx_b-Domain.nx_a)/30,'Total field','Color','k');
        caxis([-oldmax,oldmax]);
        drawnow
end

function render1D(time_set,chemin,ER,pml,Domain,Nx,Ny)
        global Mp5Player
        persistent oldmax
        if(isempty(oldmax))
            oldmax = 0.0;
        end
        Mp5Player.time = time_set;
        % Loading frame from file ( Choosed ram over speed, no need for
        % pause like follows ^^
        load([ chemin 'Ez' num2str(Mp5Player.time) '.mat']);     
        hold off      
        plot(real(Ez_host(:,round(Ny/2))));
        
        
        set(gca,'XColor','w','YColor','w');
        axis([0 Nx -0.5 0.5]);
        drawnow
end

function cb_button1()
    global Mp5Player
    if(Mp5Player.playing)
        set(Mp5Player.Button1,'String','Play');
        set(Mp5Player.Button1,'BackgroundColor','g');
    else
        set(Mp5Player.Button1,'String','Stop');
        set(Mp5Player.Button1,'BackgroundColor','r');
    end
    Mp5Player.playing =~Mp5Player.playing;
    
    return
end
