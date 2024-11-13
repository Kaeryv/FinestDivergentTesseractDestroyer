    axisX = 1:16:Nx;
    axisY = 1:16:Ny;
% figure
poynting_x = -Ep(:,:,3).*conj(Hp(:,:,2));
poynting_y = Ep(:,:,3).*conj(Hp(:,:,1));
norm_p = abs(sqrt(poynting_x.^2+ poynting_y.^2));
% norm_p = abs(Hp(:,:,2));
hold on
[cc,ch]= contourf(flipud(norm_p),6);
caxis([0 max(max(norm_p))]);
d_poynting_y=-(downresolve(Sp(:,:,1),axisX, axisY));
d_poynting_x=(downresolve(Sp(:,:,2),axisX, axisY));
% ++ Now we divide the magnitudes by the mean magnitude
%     d_poynting_x =real(10*d_poynting_x/mean(mean(abs(d_poynting_x)))); 
%     d_poynting_y =real(10*d_poynting_y/mean(mean(abs(d_poynting_y)))); 
qq=nice_quiver(axisX,axisY,flipud(d_poynting_x), flipud(d_poynting_y));

rr = rectangle('Position',[Nx/2-dia/deltax/2,Ny/2-dia/deltax/2,dia/deltax,dia/deltay],'Curvature',[1 1],'EdgeColor',[0,0.5,0.1])
line([Nx-10,(Nx-10)-dia/deltax/2],[10,10],'LineWidth',2)
text((Nx-10)-50,15,'150nm','FontSize',12,'Color','w');
set(rr,'LineWidth',2)
axis equal tight
axis off
white_hot