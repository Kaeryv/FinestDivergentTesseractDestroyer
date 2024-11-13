function [str_simID] = main(str_simID, cbox, devices,Materials,source,params)
    global c0 
    addpath('devices');

    disp('============ Finest Divergent Tesseract Destroyer v1.4 ==============');
    
    stor_fldr = ['results/' str_simID '/'];
    stor_pytg_fldr = [stor_fldr 'Poynting/'];
    
    % +++ Creating directory for it
    if(~exist (stor_fldr,'dir'))
        disp(['Creating new results output @ ~/' stor_fldr]);
        mkdir(stor_fldr);
        if(strcmp(params.computePoynting, 'on'))
            mkdir(stor_pytg_fldr);
            params.CMPT_POYNTING = 1;
        end
    else
        disp(['Using old results base @ ~/' stor_fldr]);
        if(strcmp(params.computePoynting,'on'))
            if(~exist (stor_pytg_fldr,'dir'))
                disp('Adding poynting output.');
                mkdir(stor_pytg_fldr);
                
            end
            params.CMPT_POYNTING=1;
        end
    end
    if(strcmp(params.computeSpectrum,'on'))
        params.COMPUTE_DFT =   1;
    else
        params.COMPUTE_DFT =   0;
    end
    % +++ Load physical constants
    disp('>> Loading physical constants.');
    constants;
    
   
    % +++ Materials
    nMaterials= size(Materials,1);
  

    nHigh = sqrt(max(Materials(:,1))); % We get the most refringent material index    
    
    % +++ Processing settings
    
    if(strcmp(cbox.pml,'auto')) 
        cbox.NPML = 20;
    else
        cbox.NPML = cbox.pml;
    end
    
    lam0 = c0/source.fmax;          % Shortest wavelength
    cbox.dx = lam0/nHigh/cbox.NLAM;      % Spatial resolution
    cbox.dy =cbox.dx;
    cbox.L = cbox.size+2*cbox.NPML*cbox.dx;
    cbox.L = cbox.L + [cbox.buffer(1)+cbox.buffer(2) cbox.buffer(3)+cbox.buffer(4)];
    
    cbox.nx=ceil(cbox.L(1)/cbox.dx);
    cbox.ny=ceil(cbox.L(2)/cbox.dy);
    dt = ( 1/c0/sqrt( 1/(cbox.dx^2) + 1/(cbox.dy^2) ) )*0.99;
%     dt = ( 1/c0/sqrt( 1/(cbox.dx^2) + 1/(cbox.dy^2) ) )*1.0;
    cbox.dt = dt;
    if( min(cbox.buffer/cbox.dx) < lam0/2)
        disp('Warning : The TFSF source is very close to PML');
        pause
    end

   
    % +++ We get the incident wavelet
    [ Ez_src, Hy_src,STEPS ] = wave( cbox.dx, dt, source,params);
    
    str_STEPS = num2str(STEPS);
    % +++ DFT-related thingies
    DFT.frequency = linspace(2.7e+14,source.fmax,params.NFREQ); 
    % +++ DFT Kernel
    K = exp(-1i*2*pi*dt*DFT.frequency);

    % +++ Compute domain borders
    Domain.nx_a = round(cbox.buffer(1)/cbox.dx)+cbox.NPML;
    Domain.nx_b = round((cbox.L(1)-cbox.buffer(2))/cbox.dx)-cbox.NPML;
    Domain.ny_a = round(cbox.buffer(3)/cbox.dy)+cbox.NPML;
    Domain.ny_b = round((cbox.L(2)-cbox.buffer(4))/cbox.dy)-cbox.NPML;
    
     switch source.method
        case 'TFSF'
            disp('>> Setting up TFSF boundaries.');
            % ++ Define TFSF boundaries positions as compute domain borders
            source.TFSF = Domain;      
            disp('>> Setting up DFT planes.');
            % ++ Position of the DFT contour (external input-script hybrid-thingy)
            DFT = DFT_planes(DFT,source.TFSF);
            source.HARD = 0;
        case 'hard'
            source.HARD = 1;
            if(strcmp(source.position.s,'centered'))
                source.position.x = round(cbox.nx/2);
                source.position.y = round(cbox.ny/2);
            elseif(strcmp(source.position.s,'fixed'))
                source.position.x = cbox.NPML+round(source.position.x/cbox.dx);
                source.position.y = cbox.NPML+round(source.position.y/cbox.dy);
            end
            DFT.x_a = cbox.NPML+5;         
            DFT.x_b = cbox.nx-cbox.NPML-5;     
            DFT.y_a = cbox.NPML+5;              
            DFT.y_b = cbox.ny-cbox.NPML-5;      
     end
    
    


    % +++ Size of the DFT contour from the boundaries
    DFT.horiz = DFT.y_b-DFT.y_a;
    DFT.verti = DFT.x_b-DFT.x_a;
    % +++ DFT Vectors
    % ++ Back
    DFT.back_Ez     = zeros(DFT.horiz+1,params.NFREQ);
    DFT.back_Hy     = zeros(DFT.horiz+1,params.NFREQ);
    % ++ Source
    DFT.src_Ez      = zeros(1,params.NFREQ);
    DFT.src_Hy      = zeros(1,params.NFREQ);
    % ++ Front ( aka reflected in a way, backscattered for some )
    DFT.front_Ez    = zeros(DFT.horiz+1,params.NFREQ);
    DFT.front_Hy    = zeros(DFT.horiz+1,params.NFREQ);
    % ++ The sides
    DFT.right_Ez    = zeros(DFT.verti+1,params.NFREQ);
    DFT.right_Hx    = zeros(DFT.verti+1,params.NFREQ);
    DFT.left_Ez     = zeros(DFT.verti+1,params.NFREQ);
    DFT.left_Hx     = zeros(DFT.verti+1,params.NFREQ);

    % +++ DFT Maps
    if(strcmp(params.profile.s,'on'))
        params.COMPUTE_PROFILE = 1;
        params.profile.length = length(params.profile.wavelength);
        params.profile.angularf = 2*pi*c0./params.profile.wavelength;
        DFT.Ez = zeros(cbox.nx,cbox.ny,params.profile.length);
        DFT.Hy = zeros(cbox.nx-1,cbox.ny,params.profile.length);
        DFT.Hx = zeros(cbox.nx,cbox.ny-1,params.profile.length);
%         DFT.Ez_1D = zeros(cbox.nx+1,params.profile.length);
%         DFT.Hy_1D = zeros(cbox.nx,params.profile.length);
        
    else 
         params.COMPUTE_PROFILE = 0;
    end

    disp('Filling geometry matrix.');
    % +++ Initializing to computebox material
    Index = ones(cbox.nx,cbox.ny)*cbox.material;
    % +++ Fill geometry matrix 
    for device = devices
        switch(device.type)
            case 'slab'
                Index = slab(Index,cbox,device,Domain);
            case 'rectangle'
                Index = rect(Index,cbox,device,Domain);
            case 'die_sphere'
                Index = sphere(Index,cbox,device,Domain);
            case 'bragg'
                Index = bragg(cbox,device);
        end
    end
    
    % +++ Indices for 1D FDTD
    Index1D = Index(:,1);   % We take as the 1D index as the index just at one edge of the cbox
    ER1D = transpose(Materials(Index(DFT.x_a:  DFT.x_b,1)+1,1)); % For measurements in the slab
        disp('>> Setting up DFT planes.');
    
    %%% TODO REWRITE SECTION
    %%% =============================================

        fields1.Ez = zeros(cbox.nx+1,1); 
        fields1.Hy = zeros(cbox.nx,1);
    % Allocate 2D arrays
    % TM physical and auxiliary fields
    if(strcmp(params.gpuAcceleration,'on'))
        fields2.Ez = gpuArray.zeros(cbox.nx,cbox.ny); 
        fields2.Hx = gpuArray.zeros(cbox.nx,cbox.ny-1); 
        fields2.Hy = gpuArray.zeros(cbox.nx-1,cbox.ny);
        
    else
        fields2.Ez = zeros(cbox.nx,cbox.ny); 
        fields2.Hx = zeros(cbox.nx,cbox.ny-1); 
        fields2.Hy = zeros(cbox.nx-1,cbox.ny);
        % Pre-allocate 1D fields for TF/SF interface 

    end

    %%% ==============================================
    
    
    progress = waitbar(0, 'Generating update coefficients.');
    % +++ Generate update coefficients
    disp('>> Generating update coefficients.');
    [cf,cf1] = coefficients(Index,cbox, params,Materials,nMaterials,dt);
    
    checkSetup(Domain,Index,cbox);
    pause
    % +++ Let's start a war
    totalTime = tic;
   % figure
    for T = 1:STEPS
        % ++ Update the 1D incident fields
        fields1 = update1D_renew(fields1,dt,cbox,Ez_src(T),Hy_src(T),Index1D,Materials,cf1,params);
        % ++ Update the device space field
        fields2 = update2D(fields2, fields1,Index,cbox, source,cf,dt,Materials,params);
        
        % ++ Update profiling DFT for choosen frequencies
        if(params.COMPUTE_PROFILE > 0)
            % ++ Getting fields from GPU
            Ez_host = gather(fields2.Ez);
            Hx_host = gather(fields2.Hx);
            Hy_host = gather(fields2.Hy);

%             % Getting Scattered field
%             for j= source.TFSF.ny_a+1: source.TFSF.ny_b+1            
%                Ez_host( source.TFSF.nx_a+1: source.TFSF.nx_b+1,j)=Ez_host( source.TFSF.nx_a+1: source.TFSF.nx_b+1,j)- (fields1.Ez( source.TFSF.nx_a+1: source.TFSF.nx_b+1));
%                Hy_host( source.TFSF.nx_a+1: source.TFSF.nx_b,j)=Hy_host( source.TFSF.nx_a+1: source.TFSF.nx_b,j)-(fields1.Hy( source.TFSF.nx_a: source.TFSF.nx_b-1));
%             end     
%        
%             
            for nf=1:params.profile.length
                thisKernelE = exp(-1i*params.profile.angularf(nf)*dt).^(T);
                thisKernelH = exp(-1i*params.profile.angularf(nf)*dt).^(T+0.5);    
                DFT.Ez(:,:,nf) = DFT.Ez(:,:,nf) + Ez_host .* thisKernelE;
                DFT.Hy(:,:,nf) = DFT.Hy(:,:,nf) + Hy_host .* thisKernelH;
                DFT.Hx(:,:,nf) = DFT.Hx(:,:,nf) + Hx_host .* thisKernelH;
            end
           
        end

        % ++ Update DFT probes 
        if(params.COMPUTE_DFT > 0 )
            % ++ We allow some subsampling while we respect Shannon's law
            % This explains why we put a mod of T here as a second rule
            % ++ Bringing back vectors from GPU if needed
            Ez_host = gather(fields2.Ez);
            Hx_host = gather(fields2.Hx);
            Hy_host = gather(fields2.Hy);
            
            % ++ Building the T kernel for E and H, given the grid phase
            % shift !
            thisKernelE = (K.^(T));
            thisKernelH = (K.^(T+0.5));
         
            % ++ Updating probes
            DFT.left_Hx=DFT.left_Hx+Hx_host(DFT.x_a:DFT.x_b,DFT.y_a)*thisKernelH;
            DFT.left_Ez=DFT.left_Ez+Ez_host(DFT.x_a:DFT.x_b,DFT.y_a)*thisKernelE;
            DFT.right_Ez=DFT.right_Ez+Ez_host(DFT.x_a:DFT.x_b,DFT.y_b)*thisKernelE;
            DFT.right_Hx=DFT.right_Hx+Hx_host(DFT.x_a:DFT.x_b,DFT.y_b)*thisKernelH;
            
            DFT.back_Ez = DFT.back_Ez + transpose(Ez_host(DFT.x_b,DFT.y_a:DFT.y_b)) *thisKernelE;
            DFT.back_Hy = DFT.back_Hy + transpose(Hy_host(DFT.x_b,DFT.y_a:DFT.y_b)) *thisKernelH;
            DFT.front_Ez = DFT.front_Ez + transpose(Ez_host(DFT.x_a,DFT.y_a:DFT.y_b)) *thisKernelE;
            DFT.front_Hy = DFT.front_Hy + transpose(Hy_host(DFT.x_a,DFT.y_a:DFT.y_b)) *thisKernelH;
            
            DFT.src_Ez =DFT.src_Ez+ Ez_src(T)*thisKernelE;
            DFT.src_Hy =DFT.src_Hy+ Hy_src(T)*thisKernelH;
        end
   
        
        
        
        if(~mod(T,params.SAVE_CNST))         
            Ez_host = gather(fields2.Ez);
            
%             % Getting Scattered field
%             for j= source.TFSF.ny_a+1: source.TFSF.ny_b+1            
%                Ez_host( source.TFSF.nx_a+1: source.TFSF.nx_b+1,j)=Ez_host( source.TFSF.nx_a+1: source.TFSF.nx_b+1,j)- (fields1.Ez( source.TFSF.nx_a+1: source.TFSF.nx_b+1));
%             end     
            %Hx_host = gather(fields2.Hx);
            %Hy_host = gather(fields2.Hy);   
            Ez_1D = fields1.Ez;
            %Hy = fields1.Hy;
            disp(['Saving Ez id:' str_simID ' at step ' num2str(T) ' over ' num2str(STEPS)]);
            % ++ Dumping Ez
            save([ stor_fldr 'Ez' num2str(T) '.mat'],'Ez_host','Ez_1D','-v7.3');
            time_spent_per_iter = toc(totalTime)/T;
            waitbar(T/STEPS,progress,[ num2str(time_spent_per_iter*(STEPS-T)) ' seconds left.']);
        elseif(params.SAVE_CNST==0&&~mod(T,100))
            advance = T/STEPS;
            str_time = num2str(T);
            disp(['Sim id:' str_simID ' Iteration ' str_time ' over ' str_STEPS ]);
            time_spent_per_iter = toc(totalTime)/T;
            waitbar(T/STEPS,progress,[ num2str(time_spent_per_iter*(STEPS-T)) ' seconds left.']);
        end
        
    end
    waitbar(1.0,progress,['Mission complete in' num2str(toc(totalTime)) ' seconds !']);
    disp(['Elapsed time (minutes) : ' num2str(toc(totalTime)) ' seconds']);
    % +++ Dumping epsilon
    dlmwrite(['results/' str_simID '/IndexMap.cheese'],Index);
    % +++ Saving session
    cbox.Domain = Domain;
    save(['results/' str_simID '/session.mat'],'source','cbox','params','STEPS','DFT','devices','K','Materials','-v7.3');
    % +++ Finished !
    close(progress);
    
    cbox.dx
    
end
