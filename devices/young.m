function [ Index ] = bragg(nx,ny,r,c, nHigh, slab_width, dx,d)
%BRAGG Create a 'bragg' structure from nHigh, nLow and d1,d2
%   Specify the index map size, the width contrast, the index contrast and
%   the slab total width

    Index = zeros(nx,ny);
    d1 = d;
    d2 = d*(1+r);
    
    d1_n = ceil(d1/dx);
    d2_n = ceil(d2/dx);
    
    n1 = nHigh;
    n2 = nHigh/c;
    
    % ++ Slab total depth in gridcells
    slab_width_n = ceil(slab_width/dx);
    % ++ Number of layer pairs
    layers = floor(slab_width_n/(d1_n+d2_n));
    % Position of the slab (centered)
    cell_x_start =  ceil((nx-slab_width_n)/2);
    cell_x_end   =  ceil((nx+slab_width_n)/2);
    disp(layers);
    % ++ High indice everywhere
    Index(cell_x_start:cell_x_end,:)=1;
    
    % Low index
    for i = 0:layers
        Index(cell_x_start+d2_n+i*(d2_n+d1_n):cell_x_start+d2_n+i*(d2_n+d1_n)+d1_n,:)=0;
    end
    pcolor(Index);
    shading interp
end

