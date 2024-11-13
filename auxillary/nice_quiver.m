function [ qq ] = nice_quiver( x, y, u, v )
    norm = u.^2+v.^2;
    seuil = max(mean(norm))/100;
    selection = norm<seuil;
    u(selection) = nan;
    v(selection) = nan;
    u=15*u./sqrt(norm);
    v=15*v./sqrt(norm);
    qq=quiver(x,y,u,v,'Color','w');

    set(qq,'AlignVertexCenters', 'on','AutoScaleFactor',2.0,'AutoScale','off','LineWidth',2,'MaxHeadSize',0.4)
    return
end

