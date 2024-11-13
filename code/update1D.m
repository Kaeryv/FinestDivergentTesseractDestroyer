function [ fields1 ] = update1D( fields1,dt,cbox,Ez_src,Hy_src,Index1D,Material,cf,params)
%UPDATE1D Summary of this function goes here
%   Detailed explanation goes here
    % +++ Update 1D fields
    persistent H1 H2 H3 E1 E2 E3 nx_src_1D;
    
    global c0;
    if(isempty(H1))
        E1=0;E2=0;E3=0;
        H1=0;H2=0;
        nx_src_1D = 4;
    end
    
    fields1.Hy(1) = fields1.Hy(1)+(dt/cbox.dx/((1/c0)))*(fields1.Ez(1)-E3); %OK
    for i=2:cbox.nx
        fields1.Hy(i) = fields1.Hy(i)+(dt/cbox.dx/((1/c0)))*(fields1.Ez(i)-fields1.Ez(i-1)); %OK
    end
    fields1.Hy(nx_src_1D+1)=fields1.Hy(nx_src_1D+1)-(dt/cbox.dx/((1/c0)))*Ez_src;
    H3=H2;H2=H1;H1=fields1.Hy(cbox.nx);
    
    for i=1:cbox.nx-1
        fields1.Ez(i)=fields1.Ez(i)+(dt/cbox.dx/(((1/c0))*Material(Index1D(i)+1,1)))*(fields1.Hy(i+1)-fields1.Hy(i));
    end
    fields1.Ez(cbox.nx)=fields1.Ez(cbox.nx)+(dt/cbox.dx/(((1/c0))*Material(Index1D(cbox.nx)+1,1)))*(H3-fields1.Hy(cbox.nx));
    fields1.Ez(nx_src_1D)=fields1.Ez(nx_src_1D)-(dt/cbox.dx/(((1/c0))*Material(Index1D(nx_src_1D)+1,1)))*Hy_src;
    
    E3=E2;E2=E1;E1=fields1.Ez(1);

end

