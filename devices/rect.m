function [ Index ] = rect(Index,box,device,TFSF)
%DEVICE Summary of this function goes here
%   Detailed explanation goes here
    % PARAMETERS
    slab_width_n = ceil(device.width/box.dx);
    slab_depth_n = ceil(device.depth/box.dx);
    % Position of the slab (centered)
    cell_x_start =  round(device.position.x/box.dx) - ceil((slab_depth_n)/2);
    cell_x_end   =  round(device.position.x/box.dx) + ceil((slab_depth_n)/2);
    
    cell_y_start =  round(device.position.y/box.dx) - ceil((slab_width_n)/2);
    cell_y_end   =  round(device.position.y/box.dx) + ceil((slab_width_n)/2);
    
    

    Index(TFSF.nx_a+(cell_x_start:cell_x_end),TFSF.ny_a+(cell_y_start:cell_y_end)) = device.material; 
end

