%% Etude des modes d'une sphère diélectrique
% Le script lance une série de simulations pour un ensemble de valeurs du
% rayon des sphères

clear all
clc; format short;
addpath('code');

    prefix = 'rdv';

    nm = 1e-9;
    % +++ General Options

        params.name = [prefix '/cair100/'];
    params.SAVE_CNST            =   50; ... Frequency of movie record in frames
    params.computeSpectrum      =   'on';  ... Creates and save DFT [Bool]
    params.NFREQ                =   500;...Frequency sampling    
    params.profile.s            =   'on';   
    params.profile.wavelength   =   [100 200 250 300 340 400 450 500 600 700 800 900 1000 1100 ]*nm;
    params.computePoynting      =   'off';    
    params.TIME_MULT            =   1.0;... Manual simTIme adjustment
    params.gpuAcceleration      =   'off';
% +++ Computational box parameters
    cbox.pml                 =   'auto';
    cbox.NLAM                =   20;
    cbox.buffer              =   [100 100 100 100]*nm; ... Space between PML and TFSF
    cbox.size                =   [1200 1200]*nm; ... Space for the device
    cbox.material            =   0;
% +++ Source - specific parameters
    source.type = 'gaussian';
    source.fmax = 2e+15;    % 100 nm
    source.method = 'TFSF';
    
    
% +++ Define used materials
    Materials(1,:) = [1.0 1.0 0.0];         % Air 
    Materials(2,:) = [1.52^2 1.0 0.0];      % Some glass
% +++ Device - specific options
    devices(1).type = 'slab';
    devices(1).depth = 300*nm;
    devices(1).position.x = 600*nm;
    devices(1).material = 1;
    
    n_spheres = 50;
    r_spheres = 40*nm;
    for s = 2:n_spheres+1
        devices(s).type = 'die_sphere';
        devices(s).radius = r_spheres;
        devices(s).material  = 0;
        devices(s).position.s = 'fixed';
        devices(s).position.x = devices(1).position.x+(rand()-0.5)*devices(1).depth;
        devices(s).position.y = r_spheres+rand()*(cbox.size(2)-2*r_spheres);
    end
%     
   % save('nano_pattern.mat','devices');
    
%     V_slab = devices(1).depth*cbox.size(2);
%     V_spheres = n_spheres*pi*r_spheres^2;
%     disp(['Perfect filling factor is ' num2str(V_spheres/V_slab)])
    % devices(1).type = 'rectangle';
    % devices(1).depth = 100*nm;
%     devices(1).width = 100*nm;
%     devices(1).material = 1;
%     devices(1).position.x = 300*nm;
%     devices(1).position.y = 300*nm;
%     
%     devices(2).type = 'die_sphere';
%     devices(2).radius = 100*nm;
%     devices(2).material  = 1;
%     devices(2).position.s = 'centered';
%     devices(2).position.x = 500*nm;
%     devices(2).position.y = 500*nm;
%     
%     devices(3).type = 'die_sphere';
%     devices(3).material  = 1;
%     devices(3).radius = 100*nm;
%     devices(3).position.s = 'fixed';
%     devices(3).position.x = 400*nm;
%     devices(3).position.y = 450*nm;
%     devices(4).type = 'die_sphere';
%     devices(4).material  = 1;
%     devices(4).radius = 100*nm;
%     devices(4).position.s = 'fixed';
%     devices(4).position.x = 400*nm;
%     devices(4).position.y = 750*nm;

%     devices(1).type = 'die_sphere';
%     devices(1).radius = 50*nm;
%     devices(1).material  = 1;
%     devices(1).position.s = 'fixed';
%     devices(1).position.x = 300*nm;
%     devices(1).position.y = 100*nm;
%     devices(2).type = 'die_sphere';
%     devices(2).radius = 50*nm;
%     devices(2).material  = 1;
%     devices(2).position.s = 'fixed';
%     devices(2).position.x = 300*nm;
%     devices(2).position.y = 400*nm;
% +++ Let's run this !
    


    output = main(params.name,cbox,devices,Materials,source,params);

    
    % +++ Show the results
%     viewMovie(output);