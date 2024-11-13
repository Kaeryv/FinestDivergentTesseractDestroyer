hold on
R_err = 1e-16;

m = 4;
eta = 1;
dx = 1.4424e-09;

sigma_max = -(m+1)*log(R_err)/2/eta/dx;

npml = 100;

pml = 0:npml;

sigma_x = ones(size(pml)); %*(1-pml/npml).^m;

test = area(686-pml,sigma_x);



% hold on 
% x = 0:461;
% 
% plot(461-x,0.01+1./(0.3*x));