function [fields2] = update2D(fields2, fields1,Index,cbox, source,cf,dt,Materials,params)
    persistent Fz Tz Gx Gy TFSF
    global c0;
    if(isempty(Fz))
        if(strcmp(params.gpuAcceleration, 'on'))
            Fz = gpuArray.zeros(cbox.nx,cbox.ny); 
            Tz = gpuArray.zeros(cbox.nx,cbox.ny);   
            Gx = gpuArray.zeros(cbox.nx,cbox.ny-1); 
            Gy = gpuArray.zeros(cbox.nx-1,cbox.ny);
        else
            Fz = zeros(cbox.nx,cbox.ny); 
            Tz = zeros(cbox.nx,cbox.ny);   
            Gx = zeros(cbox.nx,cbox.ny-1); 
            Gy = zeros(cbox.nx-1,cbox.ny);
        end
        if(strcmp(source.method, 'TFSF'))
            TFSF = source.TFSF;
        end
    end
    
    Fz_r = Fz(2:cbox.nx-1,2:cbox.ny-1);
    Tz_r = Tz(2:cbox.nx-1,2:cbox.ny-1);
    Fz(2:cbox.nx-1,2:cbox.ny-1) = cf.Fz_1.*Fz(2:cbox.nx-1,2:cbox.ny-1) + cf.Fz_2.*( (fields2.Hy(2:cbox.nx-1,2:cbox.ny-1) - ...
                        fields2.Hy(1:cbox.nx-2,2:cbox.ny-1))/cbox.dx - (fields2.Hx(2:cbox.nx-1,2:cbox.ny-1) - ...
                        fields2.Hx(2:cbox.nx-1,1:cbox.ny-2))/cbox.dy );
    Tz(2:cbox.nx-1,2:cbox.ny-1) = cf.a.*Tz(2:cbox.nx-1,2:cbox.ny-1) + ...
                        cf.b.*( Fz(2:cbox.nx-1,2:cbox.ny-1) - Fz_r);
    fields2.Ez(2:cbox.nx-1,2:cbox.ny-1) = cf.Ez_1.*fields2.Ez(2:cbox.nx-1,2:cbox.ny-1) + ...
                        cf.Ez_2.*( Tz(2:cbox.nx-1,2:cbox.ny-1) - Tz_r )./cf.M0;                   
    if(source.HARD<1)    
        %% +++ Total Field-Scattered field consistency relations for Ez        
        fields2.Ez(TFSF.nx_a+1,TFSF.ny_a+1:TFSF.ny_b+1) = fields2.Ez(TFSF.nx_a+1,TFSF.ny_a+1:TFSF.ny_b+1) - ...
        c0*dt./(Materials(Index(TFSF.nx_a+1,TFSF.ny_a+1:TFSF.ny_b+1)+1,1)'*cbox.dx)*fields1.Hy(TFSF.nx_a);
        fields2.Ez(TFSF.nx_b+1,TFSF.ny_a+1:TFSF.ny_b+1) = fields2.Ez(TFSF.nx_b+1,TFSF.ny_a+1:TFSF.ny_b+1) + ...
        c0*dt./(Materials(Index(TFSF.nx_b+1,TFSF.ny_a+1:TFSF.ny_b+1)+1,1)'*cbox.dx)*fields1.Hy(TFSF.nx_b+1);
    else
        fields2.Ez(source.position.x,source.position.y) = fields2.Ez(source.position.x,source.position.y)+ c0*dt./(Materials(Index(source.position.x,source.position.y)+1,1)'*cbox.dx)*fields1.Hy(source.position.x);
    end

    %% Calculate Hx total field
    Gx_r = Gx(1:cbox.nx,1:cbox.ny-1);
    Gx(1:cbox.nx,1:cbox.ny-1) = cf.Gx_1.*Gx(1:cbox.nx,1:cbox.ny-1) - ...
                      cf.Gx_2.*( fields2.Ez(1:cbox.nx,2:cbox.ny)-fields2.Ez(1:cbox.nx,1:cbox.ny-1) );
    fields2.Hx(1:cbox.nx,1:cbox.ny-1) = fields2.Hx(1:cbox.nx,1:cbox.ny-1) + (cf.Hx_1.*Gx(1:cbox.nx,1:cbox.ny-1) - cf.Hx_2.*Gx_r)./cf.M2;

    %% Calculate Hy total field 
    Gy_r = Gy(1:cbox.nx-1,1:cbox.ny);
    Gy(1:cbox.nx-1,1:cbox.ny) = cf.Gy_1.*Gy(1:cbox.nx-1,1:cbox.ny) + ...
                      cf.Gy_2.*(fields2.Ez(2:cbox.nx,1:cbox.ny)-fields2.Ez(1:cbox.nx-1,1:cbox.ny));
    fields2.Hy(1:cbox.nx-1,1:cbox.ny) = fields2.Hy(1:cbox.nx-1,1:cbox.ny) + ...
                      (cf.Hy_1.*Gy(1:cbox.nx-1,1:cbox.ny) - cf.Hy_2.*Gy_r)./cf.M3;
    
    if(source.HARD<1)             
        %% +++ Total Field-Scattered field consistency relations for H        
        % ++ fields2.Hx
        fields2.Hx(TFSF.nx_a+1:TFSF.nx_b+1,TFSF.ny_a) = fields2.Hx(TFSF.nx_a+1:TFSF.nx_b+1,TFSF.ny_a) + ...
        dt./(((1/c0))*cbox.dy*Materials(Index(TFSF.nx_a+1:TFSF.nx_b+1,TFSF.ny_a)+1,2)).*fields1.Ez(TFSF.nx_a+1:(TFSF.nx_b+1));
        fields2.Hx(TFSF.nx_a+1:TFSF.nx_b+1,TFSF.ny_b+1) = fields2.Hx(TFSF.nx_a+1:TFSF.nx_b+1,TFSF.ny_b+1) - ...
        dt./(((1/c0))*cbox.dy*Materials(Index(TFSF.nx_a+1:TFSF.nx_b+1,TFSF.ny_b+1)+1,2)).*fields1.Ez(TFSF.nx_a+1:(TFSF.nx_b+1));
 
        % ++ fields2.Hy
        fields2.Hy(TFSF.nx_a,TFSF.ny_a+1:TFSF.ny_b+1) = fields2.Hy(TFSF.nx_a,TFSF.ny_a+1:TFSF.ny_b+1) - ...
        dt./(((1/c0))*cbox.dx*Materials(Index(TFSF.nx_a,TFSF.ny_a+1:TFSF.ny_b+1)+1,2)')*fields1.Ez(TFSF.nx_a+1);
        fields2.Hy(TFSF.nx_b+1,TFSF.ny_a+1:TFSF.ny_b+1) = fields2.Hy(TFSF.nx_b+1,TFSF.ny_a+1:TFSF.ny_b+1) + ...
        dt./(((1/c0))*cbox.dx*Materials(Index(TFSF.nx_b+1,TFSF.ny_a+1:TFSF.ny_b+1)+1,2)')*fields1.Ez(TFSF.nx_b+1);
    end
end