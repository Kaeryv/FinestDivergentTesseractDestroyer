function viewMovie1D(name)

chemin = ['results/' name '/'];

load(['results/' name '/session.mat']);
figure
title('1D FDTD auxillary grid');
colormap jet
TFSF = cbox.Domain;
axis([0 cbox.nx -1 1]);
hold on
plot([TFSF.nx_a,TFSF.nx_a],[-1 1],'k:');
plot([TFSF.nx_b,TFSF.nx_b],[-1 1],'k:');
text(TFSF.nx_a,1,'TFSF plane');
dynCurve = plot(NaN,NaN);
set(dynCurve,'XData',1:cbox.nx+1);

v = VideoWriter('movie1D.avi');
    open(v);

for T=params.SAVE_CNST:params.SAVE_CNST:STEPS/4
    if(~mod(T,1))
        pause(0.1);
        
        load([ chemin 'Ez' num2str(T) '.mat']);
        set(dynCurve,'YData',Ez_1D);
        drawnow
        writeVideo(v,getframe(gcf));
    end
end
close (v)