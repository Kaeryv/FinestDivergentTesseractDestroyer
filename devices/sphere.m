function [ Index ] = sphere(Index,box,device,TFSF)
%SPHERE This function adds a sphere to the specified position
%   Detailed explanation goes here
    nRadius   = device.radius/box.dx;    % Gridcells but no need for round
    if(strcmp(device.position.s,'centered'))
        x = box.nx/2;
        y = box.ny/2;
    elseif(strcmp(device.position.s,'fixed'))
        x = TFSF.nx_a+device.position.x/box.dx;
        y = TFSF.ny_a+device.position.y/box.dx;
    else
        disp('Uncorrectly specified sphere position !');
    end
    for i=1:box.nx
        for j=1:box.ny
            if((i-x)^2+(j-y)^2<=nRadius^2)
                Index(i,j) = device.material;
            end
        end
    end
    
    return

end



