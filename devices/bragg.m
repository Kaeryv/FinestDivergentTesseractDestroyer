function [ Index ] = bragg(cbox, device)
%BRAGG Create a 'bragg' structure from nHigh, nLow and d1,d2
%   Specify the index map size, the width contrast, the index contrast and
%   the slab total width

    Index = zeros(cbox.nx,cbox.ny);
    d1 =  device.slab_width;
    d2 = d1*(1+device.r);
    
    d1_n = ceil(d1/cbox.dx);
    d2_n = ceil(d2/cbox.dx);
    
   
    
    % ++ Slab total depth in gridcells
    slab_width_n = ceil(device.width/cbox.dx);
    % ++ Number of layer pairs
    layers = floor(slab_width_n/(d1_n+d2_n));
    % Position of the slab (centered) and extent
    cell_x_start =  ceil((cbox.nx-slab_width_n)/2);
    cell_x_end   =  ceil((cbox.nx+slab_width_n)/2);
    
    % ++ High indice everywhere
    Index(cell_x_start:cell_x_end,:)=1;
    
    % Low index
    for i = 0:layers
        Index(cell_x_start+d2_n+i*(d2_n+d1_n):cell_x_start+d2_n+i*(d2_n+d1_n)+d1_n,:)=0;
    end
end

