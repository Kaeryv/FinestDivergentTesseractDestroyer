function [ Index ] = slab(Index,box,device,TFSF)
%DEVICE Summary of this function goes here
%   Detailed explanation goes here
    % PARAMETERS
    slab_depth_n = ceil(device.depth/box.dx);
    % Position of the slab (centered)
    cell_x_start =  round(device.position.x/box.dx) - ceil((slab_depth_n)/2);
    cell_x_end   =  round(device.position.x/box.dx) + ceil((slab_depth_n)/2);
    disp(device);
    Index(TFSF.nx_a+cell_x_start:TFSF.nx_a+cell_x_end,:) = device.material; 
end

