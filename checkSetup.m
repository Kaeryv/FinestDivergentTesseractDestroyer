function checkSetup(TFSF,Index,cbox)
    fig = figure;
        set(fig,'Name','Preview of the setup about to be computed, press enter to begin','MenuBar','none',...
            'NumberTitle','off');
    contour(Index,[0.5 0.5],'k');
    hold on
    rectangle('Position',[cbox.NPML cbox.NPML cbox.ny-2*cbox.NPML cbox.nx-2*cbox.NPML],'FaceColor','none','LineStyle',':');
    rectangle('Position',[TFSF.ny_a TFSF.nx_a TFSF.ny_b-TFSF.ny_a TFSF.nx_b-TFSF.nx_a],'FaceColor','none','LineStyle',':');
    text(cbox.NPML,cbox.NPML/2,'Perfectly matched layer');
%    text(TFSF.ny_a,TFSF.nx_b-(TFSF.nx_b-TFSF.nx_a)/30,'Total field');
    caxis([-1 1]);
    drawnow
end