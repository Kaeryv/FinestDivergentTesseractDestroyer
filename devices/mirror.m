function [ Index ] = mirror(nx,ny,slab_width,radius,dx)
%MIRROR Summary of this function goes here
%   Detailed explanation goes here
    Index = zeros(nx,ny);
    
    
    % PARAMETERS
    slab_width_n = ceil(slab_width/dx);
    % Position of the slab (centered)
    cell_x_start =  ceil((nx-slab_width_n)/2);
    cell_x_end   =  ceil((nx+slab_width_n)/2);
    
    Index(cell_x_start:cell_x_end,:)=0;
    
    
    spheresRadius   = ceil(radius/dx);    % Gridcells
    
  
    x = nx/2;
    y=ny/2;
    for i=0:nx
        for j=0:ny
            if((i-x)^2+(j-y)^2<=spheresRadius^2 && (i-x)<0)
                Index(i,j)=2;
            end
        end
    end
end

