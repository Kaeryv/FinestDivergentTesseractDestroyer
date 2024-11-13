function [ pointing_x,pointing_y,axisX,axisY ] = getPointing( Ez,Hx,Hy,Nx,Ny,rythmx,rythmy )
%GETPOINTING Returns sub-sampled-if-asked pointing vectors map
%   Just computes the rotational for the two vectors components, returns 2
%   maps of the components plus a couple of vectors containing the sampling
%   positions.
    switch nargin
        case 5
            pointing_x = -Ez(1:Nx-1,:).*Hy;
            pointing_y = +Ez(:,1:Ny-1).*Hx;
        case 7
            % +++ We create sub-sampling axis
            axisX = 1:rythmx:Nx-1;
            axisY = 1:rythmy:Ny-1;
            % +++ Pointing is E'xH
            pointing_x = -conj(Ez(axisX,axisY)).*Hy(axisX,axisY);
            pointing_y = +conj(Ez(axisX,axisY)).*Hx(axisX,axisY);
    end
    
end

