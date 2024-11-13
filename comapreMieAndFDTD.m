
[ DFT,Index,params,cbox,TFSF ] = getMap('compareMIE/FDTD_relative');

wl_ind = 3;
%% FDTD
figure
axisX = 1:12:cbox.nx-1;
axisY = 1:12:cbox.ny-1;

poynting_x = -DFT.Ez(1:end-1,2:end,:).*conj(DFT.Hy(:,1:end-1,:));
poynting_y = DFT.Ez(1:end-1,1:end-1,:).*conj(DFT.Hx(1:end-1,:,:));


norm_poynting_FDTD = (sqrt(poynting_x.^2+poynting_y.^2));
norm_poynting_FDTD = abs(norm_poynting_FDTD(:,:,wl_ind));
norm_poynting_FDTD = norm_poynting_FDTD/max(max(norm_poynting_FDTD));
imagesc((norm_poynting_FDTD));

hold on
caxis([0 1]);

d_poynting_y=(downresolve(poynting_y(:,:,wl_ind),axisX, axisY));
d_poynting_x=(downresolve(poynting_x(:,:,wl_ind),axisX, axisY));

contour(Index,[0.5 0.5],'g');
colormap hot

%% MIE
figure
poynting_x = -Ep(:,:,3).*conj(Hp(:,:,2));
poynting_y = Ep(:,:,3).*conj(Hp(:,:,1));
norm_poynting_MIE = abs(sqrt(poynting_x.^2+ poynting_y.^2));
norm_poynting_MIE = norm_poynting_MIE/max(max(norm_poynting_MIE));
imagesc(norm_poynting_MIE);
hold on
caxis([0 1]);
contour(Index,[0.5 0.5],'g');
colormap hot

%% DIFFERENCE
figure 
hold on

diff = abs(norm_poynting_MIE(2:end,2:end)-norm_poynting_FDTD(47:564,47:564));
diff= (diff+fliplr(diff))*0.5;
imagesc(norm_poynting_MIE(2:end,2:end));
contour(100*((diff./norm_poynting_MIE(2:end,2:end))),[0 6],'w--');
max(sum(diff))
caxis([0 1])
colorbar
contour(Index(47:564,47:564),[0.5 0.5],'g');
colormap hot

