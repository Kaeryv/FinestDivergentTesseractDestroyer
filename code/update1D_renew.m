function [ fields1 ] = update1D_renew( fields1,dt,cbox,Ez_src,Hy_src,Index1D,Material,cf,params)
%UPDATE1D Summary of this function goes here
%   Detailed explanation goes here
    % +++ Update 1D fields
 persistent Fz Tz Gy
    global c0;
    if(isempty(Fz))
        
            Fz = zeros(cbox.nx,1); 
            Tz = zeros(cbox.nx,1);             
            Gy = zeros(cbox.nx-1,1);

    end
    nx_src = cbox.NPML+1;


    Gy_r = Gy(1:cbox.nx-1);
    Gy(1:cbox.nx-1) = cf.Gy_1.*Gy(1:cbox.nx-1) + ...
                      cf.Gy_2.*(fields1.Ez(2:cbox.nx)-fields1.Ez(1:cbox.nx-1));
    fields1.Hy(1:cbox.nx-1) = fields1.Hy(1:cbox.nx-1) + ...
                      (cf.Hy_1.*Gy(1:cbox.nx-1) - cf.Hy_2.*Gy_r)./cf.M3;
    fields1.Hy(nx_src+1)=fields1.Hy(nx_src+1)-(dt/cbox.dx*c0)*Ez_src;



    Fz_r = Fz(2:cbox.nx-1);
    Tz_r = Tz(2:cbox.nx-1);
    Fz(2:cbox.nx-1) = cf.Fz_1.*Fz(2:cbox.nx-1) + cf.Fz_2.*( (fields1.Hy(2:cbox.nx-1) - fields1.Hy(1:cbox.nx-2))/cbox.dx);
    Tz(2:cbox.nx-1) = cf.a.*Tz(2:cbox.nx-1) + cf.b.*(Fz(2:cbox.nx-1) - Fz_r);
    
    fields1.Ez(2:cbox.nx-1) = cf.Ez_1.*fields1.Ez(2:cbox.nx-1) +  cf.Ez_2.*( Tz(2:cbox.nx-1) - Tz_r )./cf.M0;      
    
    fields1.Ez(nx_src)=fields1.Ez(nx_src)-(dt/cbox.dx/(Material(Index1D(nx_src)+1,1))*c0)*Hy_src;
end

