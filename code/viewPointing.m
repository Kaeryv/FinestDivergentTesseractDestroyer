function viewPoynting(name)
    global Mp5Player
    
    subsampling = 5;
    
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
    end
    
    
    % +++ Create the subsampling axes ...
    % ++ Because it is more clear to display less arrows, bigger arrows
    % ++ that each represents one macrocell's poynting vector.
    axisX = cbox.NPML:subsampling:cbox.nx-cbox.NPML;
    axisY = cbox.NPML:subsampling:cbox.ny-cbox.NPML;

    
    fig = figure;
    set(fig,'Name','Most epic matlab video player','MenuBar','none',...
        'NumberTitle','off','Color',[0.1 0.15 0.15]);
    colormap hot
    % +++ Load epsilon data
    ER = dlmread([chemin 'IndexMap.cheese']);
    ER(1,1)=1.001; % Ensure we don't get warnings spam
    Mp5Player.slider = uicontrol('Parent',fig,'Style','slider',...
        'Units','normalized','Position',[0.3,0,0.7,0.05],...
                  'value',0, 'min',0, 'max',1);

    Mp5Player.slider.Callback = @(es,ed) ... 
        render(ceil(1+es.Value*STEPS/params.SAVE_CNST)*params.SAVE_CNST,...
        chemin_p,ER,cbox.NPML,TFSF,cbox.nx,cbox.ny,axisX,axisY); 
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
    
    Mp5Player.inc_corr_toggle = uicontrol('Style', 'togglebutton','Units','normalized', 'String', 'TF/SF',...
        'Position', [0.0 0.1 0.1 0.05]);
    Mp5Player.inc_corr_toggle.Callback = @(es,ed) ... 
        render(-1,...
        chemin_p,ER,cbox.NPML,TFSF,cbox.nx,cbox.ny,axisX,axisY); 
    
    while ishandle(fig)
        pause(0.01);
        if(Mp5Player.playing)
            if(~mod(Mp5Player.time,5))           
                try
                    render(Mp5Player.time,chemin_p,ER,cbox.NPML,TFSF,cbox.nx,cbox.ny,axisX,axisY);
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
end

function render(time_set,chemin_p,ER,pml,TFSF,Nx,Ny,axisX,axisY)
        global Mp5Player
        if(time_set>0)
            Mp5Player.time = time_set;
        end
        % Loading frame from file ( Choosed ram over speed, no need for
        % pause like follows ^^
        
        load([chemin_p 'S' num2str(Mp5Player.time) '.mat']);
        % ++ Substract incident field
        if(get(Mp5Player.inc_corr_toggle,'Value')>0)
            for j= TFSF.ny_a+1:TFSF.ny_b+1
                PointingX(TFSF.nx_a+1:TFSF.nx_b,j)=(PointingX(TFSF.nx_a+1:TFSF.nx_b,j))+PointingSource(TFSF.nx_a+1:TFSF.nx_b);
            end
        end
 
       
   
        norm_poynting  = abs(sqrt(PointingX.^2 + PointingY.^2));
    
        hold off
        imagesc(real(norm_poynting)); 
        hold on
        p_y_i_d = downresolve(PointingY, axisX, axisY);
        p_x_i_d = downresolve(PointingX, axisX, axisY);
        p_i_n = abs(sqrt(p_y_i_d.^2+p_x_i_d.^2));
        p_y_i_d(p_i_n<1e-9) =[NaN];
        p_y_i_d=p_y_i_d./p_i_n;
        p_x_i_d=p_x_i_d./p_i_n;


 
        quiver(axisX,axisY,p_y_i_d,p_x_i_d,'Color','w','autoScaleFactor',0.5,'AlignVertexCenters','on');
        contour(ER,[0.5 0.5],'g');  % Dielectric
        set(gca,'XColor','w','YColor','w');
        rectangle('Position',[pml pml Ny-2*pml Nx-2*pml],'FaceColor','none','LineStyle',':','EdgeColor','w');
        if(get(Mp5Player.inc_corr_toggle,'Value')<1)
            rectangle('Position',[TFSF.ny_a TFSF.nx_a TFSF.ny_b-TFSF.ny_a TFSF.nx_b-TFSF.nx_a],'FaceColor','none','LineStyle',':','EdgeColor','w','LineWidth',3);
            text(TFSF.ny_a,TFSF.nx_b-(TFSF.nx_b-TFSF.nx_a)/30,'Total field','Color','w');
        end
        text(pml,pml/2,'Perfectly matched layer','Color','w');
        
        caxis([0 1]);
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
