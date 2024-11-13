function [ output_args ] = plotCriticalCone( device, params, cbox,Materials )
%PLOTCRITICALCONE Summary of this function goes here
%   Detailed explanation goes here

    if(strcmp(device.type,'slab'))

        x_start = cbox.NPML+cbox.buffer(1)/cbox.dx+device.position.x/cbox.dx;
        y_start = cbox.ny/2;
        crit_angle = asin(Materials(cbox.material+1)/ Materials(device.material+1));
        hold on
        size([x_start, (x_start+100)])
        plot([x_start, (x_start+100)],[y_start, y_start+sin(crit_angle)*(100)],'w');
        axis equal
    end

end

