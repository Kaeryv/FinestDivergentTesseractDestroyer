function [fig,reflec]=fourrierAnalyse(name)
    if(nargin==1)
        load(['results/' name '/session.mat']);
        
    else
        disp('Error : Specify result identifier.');
    end
constants
    if(strcmp(source.type,'TFSF'))
        TFSF = source.TFSF;
    else
        TFSF = cbox.Domain;
    end
% +++ Secure old results
% fig=figure; 
% set(fig,'Name','DFT results',...
%         'NumberTitle','off','Color',[0.1 0.15 0.15]);
hold on

% +++ Get spectrums
[src,front,back,left_in, left_out,right_in, right_out,total] = ...
    spectrums( ...
    DFT,TFSF);

% +++ Display results
    wavelength = c0./DFT.frequency*10^9;
    plot(wavelength,(real(src)+real(front))./real(src),'b-','LineWidth',2);
    plot(wavelength,real(back)./real(src),'r-','LineWidth',2);
    plot(wavelength,real(src)./real(src),'k-','LineWidth',2);
    plot(wavelength,-(real(left_in))./(real(src)),'g-','LineWidth',2);
    plot(wavelength,-(real(left_out))./(real(src)),'g-','LineWidth',2);
    plot(wavelength,(real(right_in))./(real(src)),'y--','LineWidth',2);
    plot(wavelength,(real(right_out))./(real(src)),'y--','LineWidth',2);
    plot(wavelength,(total)./(real(src)),'k:','LineWidth',2);
    set(gca,'XColor','w','YColor','w');
    axis([min(wavelength) 1000 -0.4 +1.05]);
    title('BRUTUS :: Integrated poynting vectors @ different measurement surfaces','Color','w');
    xlabel('wavelength [nm]');
    ylabel('Norm. Content [No unit]');
    legend('Front plane','Back Plane','Source','Lateral Planes','Check (Must be flat-zero or energy got lost)','Location','southwest');
    sum((real(left_in))./(real(src))) + sum((real(right_in))./(real(src)))
reflec = (real(src)+real(front))./real(src);    
end


