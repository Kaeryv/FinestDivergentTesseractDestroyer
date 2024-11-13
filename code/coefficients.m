
function [cf,cf1] = coefficients(Index,cbox, params,Materials,nMaterials,dt)
        global c0;
    % +++ PML constants
        ka_max = 1; m = 4; 
        R_err = 1e-16; 
        eta = sqrt(Materials(1,2)/Materials(1,1));
        dy = cbox.dx;

    % +++ Mainstream coefficients
        K_a(1:nMaterials) = (2/c0*Materials(1:nMaterials,1) - ...
        Materials(1:nMaterials,3)*dt)./(2/c0*Materials(1:nMaterials,1) + ...
        Materials(1:nMaterials,3)*dt);
        
        K_b(1:nMaterials) = 2/c0*Materials(1:nMaterials,1)./ ...
        (2/c0*Materials(1:nMaterials,1) + Materials(1:nMaterials,3)*dt);

        cf.a = K_a(Index(2:cbox.nx-1,2:cbox.ny-1)+1);                                                 
        cf.b = K_b(Index(2:cbox.nx-1,2:cbox.ny-1)+1);


    % +++ Allocate coefficients
        cf.Fz_1 = zeros(cbox.ny,1);   cf.Fz_2 = zeros(cbox.ny,1);   
        cf.Ez_1 = zeros(cbox.nx,1);   cf.Ez_2 = zeros(cbox.nx,1);   
        cf.Gx_1 = zeros(cbox.ny-1,1); cf.Gx_2 = zeros(cbox.ny-1,1);
        cf.Hx_1 = zeros(cbox.nx,1);   cf.Hx_2 = zeros(cbox.nx,1);   
        cf.Gy_1 = zeros(cbox.nx-1,1); cf.Gy_2 = zeros(cbox.nx-1,1); 
        cf.Hy_1 = zeros(cbox.ny,1);   cf.Hy_2 = zeros(cbox.ny,1);

    % +++ Define free space
        cf.Fz_1(:) = 1.0;        cf.Fz_2(:) = dt;
        cf.Ez_1(:) = 1.0;        cf.Ez_2(:) = 1.0*c0;
        cf.Gx_1(:) = 1.0;        cf.Gx_2(:) = dt/dy;
        cf.Hx_1(:) = 1.0*c0;     cf.Hx_2(:) = 1.0*c0;
        cf.Gy_1(:) = 1.0;        cf.Gy_2(:) = dt/cbox.dx;
        cf.Hy_1(:) = 1.0*c0;     cf.Hy_2(:) = 1.0*c0;


    % +++ Along x-axis
    % ++ constants
        sigma_max = -(m+1)*log(R_err)/(2*eta*cbox.NPML*cbox.dx);
        sigma_x = sigma_max*((cbox.NPML-(1:cbox.NPML)+1)/cbox.NPML).^m;
%        sigma_x = sigma_max*ones(size(sigma_x));
        ka_x = 1+(ka_max-1)*((cbox.NPML-(1:cbox.NPML)+1)/cbox.NPML).^m;
    % ++ define
        cf.Ez_1(1:cbox.NPML) = (2*ka_x/c0-sigma_x*dt)./(2*((1/c0))*ka_x+sigma_x*dt);
        cf.Ez_1(end-(1:cbox.NPML)+1) = cf.Ez_1(1:cbox.NPML);
        cf.Ez_2(1:cbox.NPML) = 2./(2*ka_x/c0 + sigma_x*dt);
        cf.Ez_2(end-(1:cbox.NPML)+1) = cf.Ez_2(1:cbox.NPML);
        cf.Hx_1(1:cbox.NPML) = (2*ka_x/c0+sigma_x*dt)/(2*((1/c0))*((1/c0)));
        cf.Hx_1(end-(1:cbox.NPML)+1) = cf.Hx_1(1:cbox.NPML);
        cf.Hx_2(1:cbox.NPML) = (2*((1/c0))*ka_x-sigma_x*dt)/(2*((1/c0))*((1/c0)));
        cf.Hx_2(end-(1:cbox.NPML)+1) = cf.Hx_2(1:cbox.NPML);
    
    % ++ constants
        sigma_x = sigma_max*((cbox.NPML-(1:cbox.NPML)+0.5)/cbox.NPML).^m;
        ka_x = 1+(ka_max-1)*((cbox.NPML-(1:cbox.NPML)+0.5)/cbox.NPML).^m;
    % ++ define
        cf.Gy_1(1:cbox.NPML) = (2*((1/c0))*ka_x-sigma_x*dt)./(2*((1/c0))*ka_x+sigma_x*dt);
        cf.Gy_1(end-(1:cbox.NPML)+1) = cf.Gy_1(1:cbox.NPML);
        cf.Gy_2(1:cbox.NPML) = 2*((1/c0))*dt./(2*((1/c0))*ka_x+sigma_x*dt)/cbox.dx;
        cf.Gy_2(end-(1:cbox.NPML)+1) = cf.Gy_2(1:cbox.NPML);

    % +++ Along y-axis
    % ++ constants
        sigma_max = -(m+1)*log(R_err)/(2*eta*cbox.NPML*dy); 
        sigma_y = sigma_max*((cbox.NPML-(1:cbox.NPML)+1)/cbox.NPML).^m;
        ka_y = 1+(ka_max-1)*((cbox.NPML-(1:cbox.NPML)+1)/cbox.NPML).^m;
    % ++ define
        cf.Fz_1(1:cbox.NPML) = (2*((1/c0))*ka_y-sigma_y*dt)./(2*((1/c0))*ka_y+sigma_y*dt);
        cf.Fz_1(end-(1:cbox.NPML)+1) = cf.Fz_1(1:cbox.NPML);
        cf.Fz_2(1:cbox.NPML) = 2*((1/c0))*dt./(2*((1/c0))*ka_y+sigma_y*dt);
        cf.Fz_2(end-(1:cbox.NPML)+1) = cf.Fz_2(1:cbox.NPML);
        cf.Hy_1(1:cbox.NPML) = (2*((1/c0))*ka_y+sigma_y*dt)/(2*((1/c0))*((1/c0)));
        cf.Hy_1(end-(1:cbox.NPML)+1) = cf.Hy_1(1:cbox.NPML);
        cf.Hy_2(1:cbox.NPML) = (2*((1/c0))*ka_y-sigma_y*dt)/(2*((1/c0))*((1/c0)));
        cf.Hy_2(end-(1:cbox.NPML)+1) = cf.Hy_2(1:cbox.NPML);

    % ++ constants
        sigma_y = sigma_max*((cbox.NPML-(1:cbox.NPML)+0.5)/cbox.NPML).^m;
        ka_y = 1+(ka_max-1)*((cbox.NPML-(1:cbox.NPML)+0.5)/cbox.NPML).^m;
    % ++ define
        cf.Gx_1(1:cbox.NPML) = (2*((1/c0))*ka_y-sigma_y*dt)./(2*((1/c0))*ka_y+sigma_y*dt);
        cf.Gx_1(end-(1:cbox.NPML)+1) = cf.Gx_1(1:cbox.NPML);
        cf.Gx_2(1:cbox.NPML) = 2*((1/c0))*dt./(2*((1/c0))*ka_y+sigma_y*dt)/dy;
        cf.Gx_2(end-(1:cbox.NPML)+1) = cf.Gx_2(1:cbox.NPML);

    % +++ Vectorize it all
        cf.Fz_1 = repmat(cf.Fz_1(2:cbox.ny-1)',cbox.nx-2,1); cf.Fz_2 = repmat(cf.Fz_2(2:cbox.ny-1)',cbox.nx-2,1);
        cf.Ez_1 = repmat(cf.Ez_1(2:cbox.nx-1),1,cbox.ny-2);  cf.Ez_2 = repmat(cf.Ez_2(2:cbox.nx-1),1,cbox.ny-2);
        cf.Gx_1 = repmat(cf.Gx_1(1:cbox.ny-1)',cbox.nx,1);   cf.Gx_2 = repmat(cf.Gx_2(1:cbox.ny-1)',cbox.nx,1);
        cf.Hx_1 = repmat(cf.Hx_1(1:cbox.nx),1,cbox.ny-1);    cf.Hx_2 = repmat(cf.Hx_2(1:cbox.nx),1,cbox.ny-1);
        cf.Gy_1 = repmat(cf.Gy_1(1:cbox.nx-1),1,cbox.ny);    cf.Gy_2 = repmat(cf.Gy_2(1:cbox.nx-1),1,cbox.ny);
        cf.Hy_1 = repmat(cf.Hy_1(1:cbox.ny)',cbox.nx-1,1);   cf.Hy_2 = repmat(cf.Hy_2(1:cbox.ny)',cbox.nx-1,1);

        
    cf.M0 = (reshape(Materials(Index(2:cbox.nx-1,2:cbox.ny-1)+1,1),cbox.nx-2,[]));
    cf.M2 = (reshape(Materials(Index(1:cbox.nx,1:cbox.ny-1)+1,2),cbox.nx,[]));
    cf.M3 = (reshape(Materials(Index(1:cbox.nx-1,1:cbox.ny)+1,2),[],cbox.ny));

    
    cf1.Gy_1 = cf.Gy_1(:,cbox.NPML+2);
    cf1.Gy_2 = cf.Gy_2(:,cbox.NPML+2);
    cf1.Hy_1 = cf.Hy_1(:,cbox.NPML+2);
    cf1.Hy_2 = cf.Hy_2(:,cbox.NPML+2);
    cf1.M3 = cf.M3(:,cbox.NPML+2);
    
    cf1.a = cf.a(:,cbox.NPML+2);
    cf1.b = cf.b(:,cbox.NPML+2);
    cf1.Ez_1 = cf.Ez_1(:,cbox.NPML+2);
    cf1.Ez_2 = cf.Ez_2(:,cbox.NPML+2);
    cf1.Fz_1 = cf.Fz_1(:,cbox.NPML+2);
    cf1.Fz_2 = cf.Fz_2(:,cbox.NPML+2);
    cf1.M0 = cf.M0(:,cbox.NPML+2);
    
    if(strcmp(params.gpuAcceleration, 'on'))
        cf.M0 = gpuArray(cf.M0);
        cf.M2 = gpuArray(cf.M2);
        cf.M3 = gpuArray(cf.M3);

        cf.Fz_1 = gpuArray(cf.Fz_1);    cf.Fz_2 = gpuArray(cf.Fz_2);
        cf.Ez_1 = gpuArray(cf.Ez_1);    cf.Ez_2 = gpuArray(cf.Ez_2);
        cf.Gx_1 = gpuArray(cf.Gx_1);    cf.Gx_2 = gpuArray(cf.Gx_2);
        cf.Hx_1 = gpuArray(cf.Hx_1);    cf.Hx_2 = gpuArray(cf.Hx_2);
        cf.Gy_1 = gpuArray(cf.Gy_1);    cf.Gy_2 = gpuArray(cf.Gy_2);
        cf.Hy_1 = gpuArray(cf.Hy_1);    cf.Hy_2 = gpuArray(cf.Hy_2);
        
        cf.a = gpuArray(cf.a);
        cf.b = gpuArray(cf.b);
    else
        % do nothing
    end
    
  

end
